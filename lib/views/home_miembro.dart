import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/proyecto_view_model.dart';
import 'denegacion.dart';
import 'drawer_widget_miembro.dart';

class HomeViewMiembro extends StatefulWidget {
  final String userName;
  final String userEmail;

  HomeViewMiembro({required this.userName, required this.userEmail});

  @override
  _HomeViewMiembroState createState() => _HomeViewMiembroState();
}

class _HomeViewMiembroState extends State<HomeViewMiembro> {
  String filter = "";

  @override
  Widget build(BuildContext context) {
    final proyectoViewModel = Provider.of<ProyectoViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Proyectos', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F2B40),
        elevation: 3,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      labelText: 'Buscar por nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        filter = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: proyectoViewModel.obtenerProyectos(userViewModel.token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1F2B40),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (proyectoViewModel.proyectos.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay proyectos disponibles',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  } else {
                    // Filtrar los proyectos por nombre
                    final proyectosFiltrados = proyectoViewModel.proyectos
                        .where((proyecto) => (proyecto['nombre'] ?? '')
                            .toLowerCase()
                            .contains(filter))
                        .toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        await proyectoViewModel
                            .recargarProyectos(userViewModel.token);
                      },
                      child: ListView.builder(
                        itemCount: proyectosFiltrados.length,
                        itemBuilder: (context, index) {
                          final proyecto = proyectosFiltrados[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                alignment: Alignment.center,
                                width: 30, // Tamaño del círculo
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(236, 160, 61, 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(
                                proyecto['nombre'] ?? 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2B40),
                                ),
                              ),
                              subtitle: Text(
                                proyecto['descripcion'] ?? 'Sin descripción',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              trailing: IconButton(
                                icon:
                                    Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NoPermissionsView(
                                        userName: widget.userEmail,
                                        userEmail: widget.userEmail,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
