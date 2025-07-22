import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cliente_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'drawer_widget.dart';

class VerClienteView extends StatefulWidget {
  final int clienteId;
  final String userName;
  final String userEmail;

  VerClienteView({
    required this.clienteId,
    required this.userName,
    required this.userEmail,
  });

  @override
  _VerClienteViewState createState() => _VerClienteViewState();
}

class _VerClienteViewState extends State<VerClienteView> {
  @override
  void initState() {
    super.initState();
    _obtenerCliente();
  }

  Future<void> _obtenerCliente() async {
    final clienteViewModel =
        Provider.of<ClienteViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final token = userViewModel.token;

    if (token != null) {
      await clienteViewModel.obtenerClienteEspecifico(token, widget.clienteId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clienteViewModel = Provider.of<ClienteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Cliente', style: TextStyle(color: Colors.white)),
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
      drawer:
          CustomDrawer(userName: widget.userName, userEmail: widget.userEmail),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: clienteViewModel.clienteActual == null
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF1F2B40)))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Título con color de fondo ajustado
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF1F2B40),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                            ),
                          ),
                          padding: EdgeInsets.all(20),
                        ),
                        SizedBox(height: 20),
                        // Información del Cliente
                        _buildDetailRow('Nombre de la Empresa',
                            clienteViewModel.clienteActual?.nombreEmpresa),
                        _buildDetailRow(
                            'RFC', clienteViewModel.clienteActual?.rfc),
                        _buildDetailRow('Dirección',
                            clienteViewModel.clienteActual?.direccion),
                        _buildDetailRow('Teléfono',
                            clienteViewModel.clienteActual?.telefono),
                        _buildDetailRow('Correo Electrónico',
                            clienteViewModel.clienteActual?.emailContacto),
                        _buildDetailRow('Encargado',
                            clienteViewModel.clienteActual?.encargadoNombre),
                        _buildDetailRow('Email del Encargado',
                            clienteViewModel.clienteActual?.encargadoEmail),
                        _buildDetailRow('Teléfono del Encargado',
                            clienteViewModel.clienteActual?.encargadoTelefono),
                        SizedBox(height: 20),
                        // Botón de regreso
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Volver',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1F2B40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 16.0), // Agregado padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2B40),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value ?? 'No disponible',
            style: TextStyle(fontSize: 16, color: Color(0xFF1F2B40)),
          ),
          Divider(color: Colors.grey[400]),
        ],
      ),
    );
  }
}
