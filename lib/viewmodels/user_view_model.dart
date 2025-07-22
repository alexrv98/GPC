import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/google_auth_service.dart';
import 'tarea_view_model.dart';

const String baseURL = 'https://apimovil.glarsa.com/public';
//192.168.1.74

class UserViewModel extends ChangeNotifier {
  List<UserModel> usuarios = [];
  bool _usersCargados = false;
  Map<String, dynamic>? userActual; // Para almacenar un usuario específico

  UserModel? getUsuarioById(int id) {
    try {
      return usuarios.firstWhere((usuario) => usuario.id == id);
    } catch (e) {
      return null;
    }
  }

  final GoogleAuthService _googleAuthService =
      GoogleAuthService(); // Instancia del servicio de Google

  UserModel? _user;
  String? _errorMessage;
  bool _loading = false;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get loading => _loading;

  bool isRegistered = false;
  String? _token; // Variable privada para almacenar el token.
  String? get token =>
      _token; // Getter para acceder al token desde fuera de la clase.

  // Métodos para cerrar sesión
  Future<void> logouts() async {
    await _googleAuthService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _user = null;

    final tareaViewModel = Provider.of<TareaViewModel>(context, listen: false);
    tareaViewModel.clearTareas();
    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Métodos para limpiar datos

  Future<void> limpiadatos(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Datos eliminados: ${prefs.getKeys()}');

    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Método de login

  Future<void> login(String correo, String contrasena) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    if (correo.isEmpty) {
      _errorMessage = 'El campo correo es obligatorio.';
      _loading = false;
      notifyListeners();
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(correo)) {
      _errorMessage = 'El formato del correo no es válido.';
      _loading = false;
      notifyListeners();
      return;
    }

    if (contrasena.isEmpty) {
      _errorMessage = 'La contraseña es obligatoria.';
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseURL/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': correo, 'password': contrasena}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('usuario')) {
          _user = UserModel.fromJson(responseData['usuario']);
          _token = _user!
              .token; // Aquí asignamos el token a la variable global _token
          print(
              'Token guardado: $_token'); // Imprime el token para confirmación.
        }
      } else {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        if (response.statusCode == 400) {
          if (errorResponse.containsKey('error')) {
            _errorMessage = errorResponse['error'];
          } else {
            _errorMessage = 'Correo o contraseña incorrectos.';
          }
        } else {
          _errorMessage = ' ${errorResponse['error'] ?? response.body}';
        }
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Método para restablecer intentos fallidos
  Future<void> resetIntentosFallidos(String correo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/reiniciar'),
        body: {
          'email': correo,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          _errorMessage = responseData['error'];
        } else {
          _errorMessage = null;
        }
      } else {
        _errorMessage = '';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> register(String nombre, String email, String password,
      String tarjetaCredito) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseURL/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'tarjeta_credito': tarjetaCredito,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _user = UserModel.fromJson(responseData['usuario']);
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['error'] ??
            'Error al registrar: el correo ya está en uso.';
      } else {
        _errorMessage = 'Error al registrar';
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
    } finally {
      _loading = false;
      isRegistered = true;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _user = null;
    notifyListeners(); // Notifica a los escuchas sobre los cambios
  }

  void resetRegistrationStatus() {
    isRegistered = false;
  }

  Future<bool> registerWithGoogle() async {
    print("Iniciando Google Sign-In...");

    await logouts(); // Asegúrate de que el usuario esté desconectad

    final googleUser = await _googleAuthService.signInWithGoogle();
    if (googleUser != null) {
      print("Usuario autenticado: ${googleUser.email}");
      final name = googleUser.displayName ?? 'Usuario de Google';
      final email = googleUser.email;

      await _registerGoogleUser(name, email);

      return true; // Retorna true si el registro fue exitoso
    } else {
      print("El usuario canceló el inicio de sesión.");
      return false; // Retorna false si no se autenticó
    }
  }

  Future<void> _registerGoogleUser(String name, String email) async {
    final url = Uri.parse('$baseURL/register-google');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      print("Usuario registrado con Google exitosamente");
    } else {
      print("Error al registrar usuario con Google: ${response.body}");
      throw Exception("Error en el registro con Google");
    }
  }

  Future<bool> loginWithGoogle() async {
    _loading = true;
    notifyListeners();
    await logouts();

    try {
      // Inicia sesión con Google
      final GoogleSignInAccount? googleUser =
          await _googleAuthService.signInWithGoogle();
      if (googleUser == null) {
        _loading = false;
        _errorMessage =
            'Error: Usuario no pudo iniciar sesión o canceló el proceso.';
        notifyListeners();
        return false;
      }

      // Obtiene el accessToken de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        _loading = false;
        _errorMessage = 'Error: No se pudo obtener el token de Google.';
        notifyListeners();
        return false;
      }

      // Verifica el correo electrónico en la API
      final email = googleUser.email;
      final response = await http.post(
        Uri.parse('$baseURL/verify-email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{'email': email}),
      );

      if (response.statusCode == 200) {
        // El correo existe, inicia sesión usando el accessToken
        final loginResponse = await http.post(
          Uri.parse('$baseURL/login-google'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$accessToken', // Enviar el accessToken de Google
          },
          body: jsonEncode(<String, String>{'token': accessToken}),
        );

        if (loginResponse.statusCode == 200) {
          final responseData = jsonDecode(loginResponse.body);
          print(
              "Respuesta de loginResponse: ${loginResponse.body}"); // Verifica si el JWT está presente aquí

// Accede correctamente al token JWT dentro del objeto 'user'
          _token = responseData['user']
              ['token']; // Ahora el token está en user['token']
          _user = UserModel.fromJson(responseData['user']);
          _errorMessage = null;
          print(
              "JWT de inicio de sesión con Google: $_token"); // Imprime el token JWT
          _loading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage =
              'Error al iniciar sesión con Google. Código: ${loginResponse.statusCode}';
        }
      } else {
        _errorMessage = response.statusCode == 404
            ? 'El correo no está registrado. Por favor regístrate.'
            : 'Error al verificar el correo. Código de error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error durante el proceso de inicio de sesión: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }

    return false;
  }

// Método para obtener la lista de usuarios
  Future<void> obtenerUsuarios(String? token) async {
    if (!_usersCargados && token != null) {
      final response = await http.get(
        Uri.parse('$baseURL/users'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificamos que 'users' contenga una lista
        if (data['users'] != null && data['users'] is List) {
          usuarios = (data['users'] as List)
              .map((userData) => UserModel.fromJson(userData))
              .toList();
          _usersCargados = true;
        } else {
          throw Exception(
              'Error: La respuesta no contiene una lista de usuarios');
        }
      } else {}
    }
  }

  // Método para forzar la recarga de usuarios
  Future<void> recargarUsuarios(String? token) async {
    _usersCargados = false;
    await obtenerUsuarios(token); // Llama al método de obtener usuarios
    notifyListeners(); // Notifica a los listeners para actualizar la UI
  }

  // Método para obtener un usuario específico por ID
  Future<void> obtenerUsuario(String? token, int userId) async {
    if (token == null) {
      throw Exception('Token no válido');
    }

    final response = await http.get(
      Uri.parse('$baseURL/users/$userId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Verificamos que 'data' sea un array (un solo usuario dentro de un array)
      if (data.isNotEmpty && data[0] != null) {
        userActual = data[0]; // Obtenemos el primer elemento del array
        notifyListeners(); // Notifica que el usuario fue cargado
      } else {
        throw Exception('Error: El usuario no fue encontrado en la respuesta');
      }
    } else {
      throw Exception('Error al obtener el usuario: ${response.body}');
    }
  }

  // Método para crear un usuario
  Future<bool> crearUsuario(String? token, String nombre, String email,
      String password, String rolApi) async {
    final response = await http.post(
      Uri.parse('$baseURL/users'),
      headers: {'Authorization': token!},
      body: {
        'nombre': nombre,
        'email': email,
        'password': password, // Añadir la contraseña aquí
        'rol': rolApi, // Enviar el rol mapeado para la API
      },
    );

    if (response.statusCode == 201) {
      await obtenerUsuarios(token); // Opcional: Recargar lista tras la creación
      notifyListeners();
      return true;
    } else {
      final data = json.decode(response.body);
      if (data['error'] != null) {
        throw Exception('Error al crear el usuario: ${data['error']}');
      } else {
        throw Exception('Error al crear el usuario: ${response.body}');
      }
    }
  }

  // Método para editar un usuario
  Future<bool> editarUsuario(String? token, int userId, String nombre,
      String email, String rol) async {
    final response = await http.put(
      Uri.parse('$baseURL/users/$userId'),
      headers: {'Authorization': token!},
      body: {'nombre': nombre, 'email': email, 'rol': rol},
    );

    if (response.statusCode == 200) {
      await obtenerUsuarios(token); // Opcional: Recargar lista tras la edición
      notifyListeners();
      return true;
    } else {
      final data = json.decode(response.body);
      if (data['error'] != null) {
        throw Exception('Error al editar el usuario: ${data['error']}');
      } else {
        throw Exception('Error al editar el usuario: ${response.body}');
      }
    }
  }

  // Método para eliminar un usuario
  Future<void> eliminarUsuario(int userId, String? token) async {
    if (token == null) {
      throw Exception('Token no válido');
    }

    final response = await http.delete(
      Uri.parse('$baseURL/users/$userId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        // Si la respuesta contiene información de éxito, la procesamos
        print(data['data']);
      }
      notifyListeners(); // Opcional: Actualizar UI tras la eliminación
    } else {
      final data = json.decode(response.body);
      if (data['error'] != null) {
        throw Exception('Error al eliminar el usuario: ${data['error']}');
      } else {
        throw Exception('Error al eliminar el usuario: ${response.body}');
      }
    }
  }
}
