import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Import para usar FilteringTextInputFormatter
import '../viewmodels/cliente_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../models/cliente_model.dart';

class EditarClienteView extends StatefulWidget {
  final int clienteId;
  final String userName;
  final String userEmail;

  EditarClienteView({
    required this.clienteId,
    required this.userName,
    required this.userEmail,
  });

  @override
  _EditarClienteViewState createState() => _EditarClienteViewState();
}

class _EditarClienteViewState extends State<EditarClienteView> {
  final _formKey = GlobalKey<FormState>();
  late String nombreEmpresa;
  late String rfc;
  String? telefono;
  String? emailContacto;
  String? encargadoNombre;
  String? encargadoEmail;
  String? encargadoTelefono;

  // Controladores para los campos de texto
  final TextEditingController direccionController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  List<String> addressSuggestions = [];
  final String hereApiKey = 'XmFCfcUcYJ9IcWj8KvNmHNFyvqdqYlYtWmtuu7wYFKE';

  @override
  void initState() {
    super.initState();
    _cargarCliente();
  }

  Future<void> _cargarCliente() async {
    final clienteViewModel =
        Provider.of<ClienteViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final token = userViewModel.token;

    if (token != null) {
      setState(() {
        isLoading = true;
      });
      try {
        await clienteViewModel.obtenerClienteEspecifico(
            token, widget.clienteId);
        final cliente = clienteViewModel.clienteActual!;

        setState(() {
          nombreEmpresa = cliente.nombreEmpresa;
          rfc = cliente.rfc;
          telefono = cliente.telefono;
          emailContacto = cliente.emailContacto;
          encargadoNombre = cliente.encargadoNombre;
          encargadoEmail = cliente.encargadoEmail;
          encargadoTelefono = cliente.encargadoTelefono;
          direccionController.text = cliente.direccion ?? '';
        });
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
  }

  Future<void> _fetchAddressSuggestions(String query) async {
    final String url =
        'https://autocomplete.search.hereapi.com/v1/autocomplete?q=$query&apiKey=$hereApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> suggestions = decodedResponse['items'];

        setState(() {
          addressSuggestions = suggestions.map((item) {
            return item['address']['label'] as String;
          }).toList();
        });
      } else {
        throw Exception('Error al obtener sugerencias: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching address suggestions: $e');
    }
  }

  Future<void> _guardarCambios() async {
    final clienteViewModel =
        Provider.of<ClienteViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final token = userViewModel.token;

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final cliente = Cliente(
          id: widget.clienteId,
          nombreEmpresa: nombreEmpresa,
          rfc: rfc,
          direccion: direccionController.text,
          telefono: telefono,
          emailContacto: emailContacto,
          encargadoNombre: encargadoNombre,
          encargadoEmail: encargadoEmail,
          encargadoTelefono: encargadoTelefono,
        );

        final success = await clienteViewModel.editarCliente(
            token, widget.clienteId, cliente);
        if (success) {
          Navigator.pop(context);
        } else {
          setState(() {
            errorMessage = 'Error al editar el cliente';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cliente', style: TextStyle(color: Colors.white)),
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField('Nombre de la Empresa', nombreEmpresa,
                              (value) {
                            nombreEmpresa = value!;
                          }),
                          _buildTextField('RFC', rfc, (value) {
                            rfc = value!;
                          }),
                          _buildAddressField(),
                          _buildTextField('Teléfono', telefono, (value) {
                            telefono = value;
                          }),
                          _buildTextField('Correo Electrónico', emailContacto,
                              (value) {
                            emailContacto = value;
                          }),
                          _buildTextField('Encargado', encargadoNombre,
                              (value) {
                            encargadoNombre = value;
                          }),
                          _buildTextField('Email del Encargado', encargadoEmail,
                              (value) {
                            encargadoEmail = value;
                          }),
                          _buildTextField(
                              'Teléfono del Encargado', encargadoTelefono,
                              (value) {
                            encargadoTelefono = value;
                          }),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _guardarCambios,
                            child: Text('Guardar Cambios',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1F2B40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String? initialValue, ValueChanged<String?> onChanged) {
    bool isPhoneField = label.contains("Teléfono");
    bool isEmailField = label.contains("Correo") || label.contains("Email");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhoneField
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ]
            : [],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          if (isPhoneField && value.length != 10) {
            return 'El teléfono debe tener 10 dígitos';
          }
          if (isEmailField && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Ingrese un email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: direccionController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _fetchAddressSuggestions(value);
            }
          },
          decoration: InputDecoration(
            labelText: 'Dirección',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (addressSuggestions.isNotEmpty)
          ...addressSuggestions.map((suggestion) {
            return ListTile(
              title: Text(suggestion),
              onTap: () {
                setState(() {
                  direccionController.text = suggestion;
                  addressSuggestions = [];
                });
              },
            );
          }).toList(),
      ],
    );
  }
}
