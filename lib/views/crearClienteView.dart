import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../viewmodels/cliente_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'package:flutter/services.dart';

import '../models/cliente_model.dart';

class CrearClienteView extends StatefulWidget {
  @override
  _CrearClienteViewState createState() => _CrearClienteViewState();
}

class _CrearClienteViewState extends State<CrearClienteView> {
  final _formKey = GlobalKey<FormState>();
  late String nombreEmpresa;
  late String rfc;
  String? direccion;
  String? telefono;
  String? emailContacto;
  String? encargadoNombre;
  String? encargadoEmail;
  String? encargadoTelefono;

  final TextEditingController _direccionController = TextEditingController();
  List<String> addressSuggestions = [];
  final String hereApiKey = 'XmFCfcUcYJ9IcWj8KvNmHNFyvqdqYlYtWmtuu7wYFKE';

  bool isLoading = false;
  String errorMessage = '';

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

  Future<void> _guardarCliente() async {
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
          id: 0,
          nombreEmpresa: nombreEmpresa,
          rfc: rfc,
          direccion: direccion,
          telefono: telefono,
          emailContacto: emailContacto,
          encargadoNombre: encargadoNombre,
          encargadoEmail: encargadoEmail,
          encargadoTelefono: encargadoTelefono,
        );

        final success = await clienteViewModel.crearCliente(token, cliente);
        if (success) {
          Navigator.pop(context);
        } else {
          setState(() {
            errorMessage = 'Error al crear el cliente';
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
        title: Text('Crear Cliente', style: TextStyle(color: Colors.white)),
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
                          _buildTextField('Nombre de la Empresa', '', (value) {
                            nombreEmpresa = value!;
                          }),
                          _buildTextField('RFC', '', (value) {
                            rfc = value!;
                          }),
                          _buildAddressField(),
                          _buildPhoneNumberField('Teléfono', (value) {
                            telefono = value;
                          }),
                          _buildEmailField('Correo Electrónico', (value) {
                            emailContacto = value;
                          }),
                          _buildTextField('Encargado', '', (value) {
                            encargadoNombre = value;
                          }),
                          _buildEmailField('Email del Encargado', (value) {
                            encargadoEmail = value;
                          }),
                          _buildPhoneNumberField('Teléfono del Encargado',
                              (value) {
                            encargadoTelefono = value;
                          }),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _guardarCliente,
                            child: Text('Crear Cliente',
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

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _direccionController,
          decoration: InputDecoration(
            labelText: 'Dirección',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _fetchAddressSuggestions(value);
            } else {
              setState(() {
                addressSuggestions.clear();
              });
            }
          },
        ),
        if (addressSuggestions.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: addressSuggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(addressSuggestions[index]),
                onTap: () {
                  setState(() {
                    _direccionController.text = addressSuggestions[index];
                    direccion = addressSuggestions[index];
                    addressSuggestions.clear();
                  });
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String initialValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
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
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField(String label, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        onChanged: onChanged,
        keyboardType: TextInputType.emailAddress,
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
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Por favor, introduce un correo válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneNumberField(String label, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        onChanged: onChanged,
        keyboardType: TextInputType.number,
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
          if (value.length != 10) {
            return 'El número de teléfono debe tener 10 dígitos';
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly
        ], // Solo permite números
      ),
    );
  }
}
