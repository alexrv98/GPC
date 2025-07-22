import 'package:flutter/material.dart';
import '../viewmodels/user_view_model.dart';

class CrearUsuarioView extends StatefulWidget {
  final String token;

  CrearUsuarioView({required this.token});

  @override
  _CrearUsuarioViewState createState() => _CrearUsuarioViewState();
}

class _CrearUsuarioViewState extends State<CrearUsuarioView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _rol = '';
  bool isLoading = false;
  String errorMessage = '';

  final List<String> _roles = ['Administrador', 'Miembro'];
  final Map<String, String> _rolApiMapping = {
    'Administrador': 'admin',
    'Miembro': 'miembro',
  };

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final userViewModel = UserViewModel();
    try {
      String rolApi = _rolApiMapping[_rol] ?? 'miembro';
      bool success = await userViewModel.crearUsuario(
        widget.token,
        _nombreController.text,
        _emailController.text,
        _passwordController.text,
        rolApi,
      );

      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage = 'Error al crear el usuario';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1F2B40),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Imagen en un círculo a la derecha del AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20, // Tamaño del círculo
              backgroundImage: AssetImage('assets/images/GPCHD.png'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent, // Hacer transparente
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF1F2B40)),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor ingrese un nombre'
                      : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent, // Hacer transparente
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF1F2B40)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un correo electrónico';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Correo electrónico inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent, // Hacer transparente
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF1F2B40)),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _rol.isNotEmpty ? _rol : null,
                  onChanged: (newValue) {
                    setState(() {
                      _rol = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent, // Hacer transparente
                    labelText: 'Rol',
                    labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF1F2B40)),
                    ),
                  ),
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor seleccione un rol'
                      : null,
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1F2B40)))
                    : Column(
                        children: [
                          Center(
                            child: ElevatedButton(
                              onPressed: _crearUsuario,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 24.0),
                                child: Text('Crear Usuario',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1F2B40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          if (errorMessage.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                errorMessage,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
