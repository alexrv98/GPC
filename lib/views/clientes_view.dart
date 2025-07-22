import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cliente_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'crearClienteView.dart';
import 'editarClienteView.dart';
import 'VerClienteView.dart';
import 'drawer_widget.dart';

class ClientesView extends StatefulWidget {
  final String userName;
  final String userEmail;

  ClientesView({required this.userName, required this.userEmail});

  @override
  _ClientesViewState createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {
  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    final clienteViewModel =
        Provider.of<ClienteViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (clienteViewModel.clientes.isEmpty && userViewModel.token != null) {
      await clienteViewModel.obtenerClientes(userViewModel.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clienteViewModel = Provider.of<ClienteViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clientes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1F2B40),
        elevation: 3,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/GPCHD.png'),
            ),
          ),
        ],
      ),
      drawer:
          CustomDrawer(userName: widget.userName, userEmail: widget.userEmail),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearClienteView()),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Agregar Cliente',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1F2B40),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Encabezados
            Container(
              color: Color(0xFFF5F5F5),
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Empresa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2B40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'RFC',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2B40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Ver',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2B40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Editar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2B40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Eliminar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2B40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Contenido
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await clienteViewModel.recargarClientes(userViewModel.token);
                },
                child: clienteViewModel.clientes.isEmpty
                    ? ListView(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('No hay clientes disponibles'),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: clienteViewModel.clientes.length,
                        itemBuilder: (context, index) {
                          final cliente = clienteViewModel.clientes[index];
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(cliente.nombreEmpresa),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(cliente.rfc),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: Icon(Icons.visibility,
                                            color: Colors.blueAccent),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VerClienteView(
                                                clienteId: cliente.id,
                                                userName: widget.userName,
                                                userEmail: widget.userEmail,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.orangeAccent),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditarClienteView(
                                                clienteId: cliente.id,
                                                userName: widget.userName,
                                                userEmail: widget.userEmail,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Confirmar eliminación'),
                                                content: Text(
                                                    '¿Desea eliminar este cliente?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child: Text('Eliminar'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmed == true) {
                                            await clienteViewModel
                                                .eliminarCliente(
                                                    userViewModel.token,
                                                    cliente.id);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
