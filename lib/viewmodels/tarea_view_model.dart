import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/tarea_model.dart';
import 'user_view_model.dart';

class TareaViewModel extends ChangeNotifier {
  List<Tarea> _tareas = [];
  bool _obtenerTareas = false;

  List<Tarea> get tareas => _tareas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const String apiUrl = '$baseURL/tareas';

  void clearTareas() {
    tareas.clear(); // Borra las tareas en memoria
    notifyListeners();
  }

  // Método para forzar la recarga de clientes
  Future<void> recargarTareas(String token) async {
    _obtenerTareas = false;
    await obtenerTareas(token);
  }

// Método para forzar la recarga de clientes
  Future<void> recargarTareasMiembro(String token) async {
    _obtenerTareas = false;
    await obtenerMisTareas(token);
  }

  // Método para obtener todas las tareas
  Future<void> obtenerTareas(String token) async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': token},
      );
      print('Estado de respuesta: ${response.statusCode}');
      print('Respuesta de la API: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['tareas'];
        _tareas = data.map((json) => Tarea.fromJson(json)).toList();
        _obtenerTareas = true;
      } else {
        throw Exception('Error al obtener tareas');
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Método para obtener las tareas asignadas al usuario autenticado
  Future<void> obtenerMisTareas(String token) async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final response = await http.get(
        Uri.parse('$baseURL/misTareas'),
        headers: {'Authorization': token},
      );
      print('Estado de respuesta: ${response.statusCode}');
      print('Respuesta de la API: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['tareas'];
        _tareas = data.map((json) => Tarea.fromJson(json)).toList();
        _obtenerTareas = true;
      } else {
        throw Exception('Error al obtener tareas asignadas');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Tarea?> obtenerTarea(int tareaId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$tareaId'),
        headers: {'Authorization': token},
      );

      print('Estado de respuesta: ${response.statusCode}');
      print('Respuesta de la API: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Tarea.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Tarea no encontrada');
      } else {
        throw Exception('Error al obtener la tarea');
      }
    } catch (e) {
      print('Error al obtener la tarea: $e');
    }
  }

  Future<void> eliminarTarea(
      int tareaId, String token, BuildContext context) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$tareaId'),
      headers: {'Authorization': token},
    );
    if (response.statusCode == 200) {
      _tareas.removeWhere((tarea) => tarea.id == tareaId);
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("No tienes suficientes permisos para eliminar la tarea"),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  // Método para crear una nueva tarea
  Future<void> crearTarea(Map<String, dynamic> tareaData, String token) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode(tareaData),
    );
    if (response.statusCode == 201) {
      final tarea = Tarea.fromJson(json.decode(response.body));
      _tareas.add(tarea);
      notifyListeners();
    } else {
      throw Exception('Error al crear tarea');
    }
  }

  // Método para actualizar una tarea existente
  Future<void> actualizarTarea(
      int tareaId, Map<String, dynamic> tareaData, String token) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$tareaId'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode(tareaData),
    );
    if (response.statusCode == 200) {
      final updatedTarea = Tarea.fromJson(json.decode(response.body));
      final index = _tareas.indexWhere((tarea) => tarea.id == tareaId);
      if (index != -1) {
        print('Respuesta de la API al editar: ${response.body}');

        _tareas[index] = updatedTarea;
        notifyListeners();
      }
    } else {
      throw Exception('Error al actualizar tarea');
    }
  }
}
