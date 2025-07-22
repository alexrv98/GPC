import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tarea_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'VerTareaView.dart';
import 'drawer_widget_miembro.dart';
import 'EditarTareaViewMiembro.dart';
import 'denegacion.dart';

class TareasViewMiembro extends StatefulWidget {
  final String userName;
  final String userEmail;

  TareasViewMiembro({required this.userName, required this.userEmail});

  @override
  _TareasViewState createState() => _TareasViewState();
}

class _TareasViewState extends State<TareasViewMiembro> {
  @override
  void initState() {
    super.initState();
    final tareaViewModel = Provider.of<TareaViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (tareaViewModel.tareas.isEmpty && !tareaViewModel.isLoading) {
      tareaViewModel.obtenerMisTareas(userViewModel.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tareaViewModel = Provider.of<TareaViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F2B40),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoPermissionsView(
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Agregar tarea',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1F2B40),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final tareaViewModel =
                      Provider.of<TareaViewModel>(context, listen: false);
                  final userViewModel =
                      Provider.of<UserViewModel>(context, listen: false);
                  await tareaViewModel
                      .recargarTareasMiembro(userViewModel.token!);
                },
                child: tareaViewModel.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : tareaViewModel.tareas.isEmpty
                        ? ListView(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'No hay tareas disponibles',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: tareaViewModel.tareas.length,
                            itemBuilder: (context, index) {
                              final tarea = tareaViewModel.tareas[index];

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
                                    width: 30,
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
                                    tarea.nombre,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2B40),
                                    ),
                                  ),
                                  subtitle: Text(
                                    tarea.estado,
                                    style: TextStyle(color: Colors.grey[800]),
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
                                                      VerTareaView(
                                                          tareaId: tarea.id),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.orange),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditarTareaViewMiembro(
                                                          tareaId: tarea.id),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        '¿Seguro de eliminar?'),
                                                    content: Text(
                                                        'Esta acción no se puede deshacer. ¿Desea continuar?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: Text('Cancelar'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: Text(
                                                          'Eliminar',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirmed == true) {
                                                await tareaViewModel
                                                    .eliminarTarea(
                                                        tarea.id,
                                                        userViewModel.token!,
                                                        context);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
