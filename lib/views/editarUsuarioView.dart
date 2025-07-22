import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';

class EditarUsuarioView extends StatefulWidget {
  final String token;
  final int userId;
  final String nombreInicial;
  final String emailInicial;
  final String rolInicial;

  EditarUsuarioView({
    required this.token,
    required this.userId,
    required this.nombreInicial,
    required this.emailInicial,
    required this.rolInicial,
  });

  @override
  _EditarUsuarioViewState createState() => _EditarUsuarioViewState();
}

class _EditarUsuarioViewState extends State<EditarUsuarioView> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _email;
  late String _rol;

  // Enum con los roles de la base de datos
  final List<String> _roles = ['admin', 'miembro'];

  @override
  void initState() {
    super.initState();
    _nombre = widget.nombreInicial;
    _email = widget.emailInicial;
    _rol = widget.rolInicial;
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Usuario',
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
                Text(
                  'Editar Detalles del Usuario',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2B40),
                  ),
                ),
                SizedBox(height: 20),

                // Campo de entrada para el nombre
                TextFormField(
                  initialValue: _nombre,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nombre = value ?? '';
                  },
                ),
                SizedBox(height: 20),

                // Campo de entrada para el correo electrónico
                TextFormField(
                  initialValue: _email,
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
                  onSaved: (value) {
                    _email = value ?? '';
                  },
                ),
                SizedBox(height: 20),

                // Dropdown para selección de rol
                DropdownButtonFormField<String>(
                  value: _rol,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un rol';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _rol = value ?? '';
                  },
                ),
                SizedBox(height: 20),

                // Botón para guardar cambios
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();

                        try {
                          bool success = await userViewModel.editarUsuario(
                            widget.token,
                            widget.userId,
                            _nombre,
                            _email,
                            _rol,
                          );

                          if (success) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error al editar el usuario')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 24.0),
                      child: Text('Guardar Cambios',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
