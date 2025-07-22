import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/proyecto_view_model.dart';
import 'verProyectoView.dart';
import 'crearProyectoView.dart';
import 'editarProyectoView.dart';
import 'drawer_widget.dart';

class HomeView extends StatefulWidget {
  final String userName;
  final String userEmail;

  HomeView({required this.userName, required this.userEmail});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
            // Fila para el buscador y el botón de agregar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: const Color.fromARGB(255, 158, 158, 158)),
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
                SizedBox(
                    width: 16), // Espacio entre el campo de búsqueda y el botón
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrearProyectoView(
                          token: userViewModel.token!,
                        ),
                      ),
                    );
                    if (result == true) {
                      await proyectoViewModel
                          .recargarProyectos(userViewModel.token);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 78, 158, 78), // Fondo del botón
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(40.0), // Bordes más redondeados
                    ),
                    padding: EdgeInsets.all(
                        7.0), // Menos padding para hacerlo más pequeño
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20, // Hacer el ícono más pequeño
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
                            child: ExpansionTile(
                              leading: Container(
                                alignment: Alignment.center,
                                width: 30, // Tamaño del círculo
                                height: 30, // Tamaño del círculo
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(
                                      236, 160, 61, 1), // Color del botón
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}', // Número del proyecto
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Ajusta el tamaño del texto
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
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.visibility,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VerProyectoView(
                                                proyectoId:
                                                    proyecto['id'].toString(),
                                                token: userViewModel.token!,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.orange),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditarProyectoView(
                                                token: userViewModel.token!,
                                                proyectoId: proyecto['id'],
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            await proyectoViewModel
                                                .recargarProyectos(
                                                    userViewModel.token);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  '¿Seguro de eliminar?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: Text(
                                                    'Se eliminará el proyecto y todo lo relacionado a él. ¿Desea continuar?'),
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
                                                    child: Text(
                                                      'Eliminar',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmed == true) {
                                            await proyectoViewModel
                                                .eliminarProyecto(
                                                    proyecto['id'],
                                                    userViewModel.token!);
                                            await proyectoViewModel
                                                .recargarProyectos(
                                                    userViewModel.token);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
