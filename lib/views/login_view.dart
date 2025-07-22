import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import 'home_miembro.dart';
import 'terms_view.dart';
import 'home_view.dart';
import 'register_view.dart';
import '../viewmodels/terms_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _hasAcceptedTerms = false;
  bool _isButtonEnabled = true;
  int _remainingTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final termsViewModel =
          Provider.of<TermsViewModel>(context, listen: false);
      await termsViewModel.checkTermsAccepted();
      setState(() {
        _hasAcceptedTerms = termsViewModel.hasAcceptedTerms;
      });
      if (!_hasAcceptedTerms) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TermsView()),
        );
      }
    });
  }

  Future<void> _limpiarCacheYRecargar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TermsView()),
    );
  }

  Future<void> _limpiarDatos() async {
    await Provider.of<UserViewModel>(context, listen: false)
        .limpiadatos(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.05),
              Container(
                width: screenSize.width * 0.4,
                height: screenSize.width * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.fromRGBO(0, 31, 41, 0.666),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: CircleAvatar(
                    radius: screenSize.width * 0.2,
                    backgroundImage: AssetImage('assets/images/GPCHD.png'),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              TextField(
                controller: _contrasenaController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: screenSize.height * 0.02),
              if (!_hasAcceptedTerms)
                Row(
                  children: [
                    Checkbox(
                      value: _hasAcceptedTerms,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _hasAcceptedTerms = newValue!;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TermsView()),
                        );
                      },
                      child: Text(
                        'Acepto los términos y condiciones',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Ya has aceptado los términos y condiciones.',
                  style: TextStyle(color: Colors.green),
                ),
              SizedBox(height: screenSize.height * 0.02),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  return Column(
                    children: [
                      if (userViewModel.errorMessage != null)
                        Text(
                          userViewModel.errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      if (userViewModel.user != null)
                        Text(
                          '¡Login exitoso! Bienvenido, ${userViewModel.user!.nombre}!',
                          style: TextStyle(color: Colors.green),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  if (userViewModel.loading) {
                    return CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                              if (!_hasAcceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Debe aceptar los términos y condiciones para continuar.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final correo = _correoController.text;
                              final contrasena = _contrasenaController.text;
                              await userViewModel.login(correo, contrasena);

                              if (userViewModel.user != null) {
                                await userViewModel
                                    .resetIntentosFallidos(correo);
                                if (userViewModel.user!.rol == 'admin') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeView(
                                        userName: userViewModel.user!.nombre,
                                        userEmail: userViewModel.user!.email,
                                      ),
                                    ),
                                  );
                                } else if (userViewModel.user!.rol ==
                                    'miembro') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeViewMiembro(
                                        userName: userViewModel.user!.nombre,
                                        userEmail: userViewModel.user!.email,
                                      ),
                                    ),
                                  );
                                }
                              } else if (userViewModel.errorMessage != null &&
                                  userViewModel.errorMessage!.contains(
                                      'límite de intentos fallidos')) {
                                _isButtonEnabled = false;
                                _startTimer();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(236, 160, 61, 1),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.15,
                          vertical: screenSize.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Iniciar Sesión'),
                    );
                  }
                },
              ),

              /*Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height *
                        0.02), // Espaciado arriba
                child: ElevatedButton(
                  onPressed: () async {
                    await _limpiarCacheYRecargar();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fondo blanco
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.15,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: Color.fromRGBO(236, 160, 61, 1),
                          width: 2), // Borde color naranja
                    ),
                  ),
                  child: Text(
                    'Recargar para mostrar términos',
                    style: TextStyle(
                      color: Color.fromRGBO(236, 160, 61, 1), // Texto naranja
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ), */

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterBasicInfoView()),
                  );
                },
                child: Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      final result = await userViewModel.loginWithGoogle();
                      if (result && userViewModel.user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('¡Login con Google exitoso!')),
                        );

                        // Redirección según el rol del usuario
                        if (userViewModel.user!.rol == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeView(
                                userName: userViewModel.user!.nombre,
                                userEmail: userViewModel.user!.email,
                              ),
                            ),
                          );
                        } else if (userViewModel.user!.rol == 'miembro') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeViewMiembro(
                                userName: userViewModel.user!.nombre,
                                userEmail: userViewModel.user!.email,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Rol no reconocido.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error al iniciar sesión con Google.')),
                        );
                      }
                    },
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      height: 24,
                    ),
                    label: Text('Iniciar Sesión con Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.1,
                        vertical: screenSize.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
              if (!_isButtonEnabled)
                Text('Reintentar en: $_remainingTime segundos'),
              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _remainingTime = 10;
    _isButtonEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isButtonEnabled = true;
          String correo = _correoController.text;
          Provider.of<UserViewModel>(context, listen: false)
              .resetIntentosFallidos(correo);
        });
      }
    });
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
