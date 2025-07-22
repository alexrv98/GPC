import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tarea_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'VerTareaView.dart';
import 'EditarTareaView.dart';
import 'AgregarTareaView.dart';
import 'drawer_widget.dart';

class TareasView extends StatefulWidget {
  final String userName;
  final String userEmail;

  TareasView({required this.userName, required this.userEmail});

  @override
  _TareasViewState createState() => _TareasViewState();
}

class _TareasViewState extends State<TareasView> {
  String? selectedUserId;
  bool _isLoadingUsuarios = true;

  @override
  void initState() {
    super.initState();
    final tareaViewModel = Provider.of<TareaViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    // Cargar tareas y usuarios al inicializar la vista
    _cargarDatosIniciales(tareaViewModel, userViewModel);
  }

  Future<void> _cargarDatosIniciales(
      TareaViewModel tareaViewModel, UserViewModel userViewModel) async {
    try {
      if (tareaViewModel.tareas.isEmpty && !tareaViewModel.isLoading) {
        await tareaViewModel.obtenerTareas(userViewModel.token!);
      }
      await userViewModel.obtenerUsuarios(userViewModel.token);
    } catch (e) {
      print("Error al cargar los datos iniciales: $e");
    } finally {
      setState(() {
        _isLoadingUsuarios = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tareaViewModel = Provider.of<TareaViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    // Lista de usuarios para el filtro
    final usuarios = userViewModel.usuarios;

    // Filtrar tareas según el usuario seleccionado
    final tareasFiltradas = selectedUserId == null
        ? tareaViewModel.tareas
        : tareaViewModel.tareas.where((tarea) {
            return tarea.asignadoId.toString() == selectedUserId;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas', style: TextStyle(color: Colors.white)),
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
      body: _isLoadingUsuarios
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1F2B40),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedUserId,
                          hint: Text('Filtrar por usuario asignado'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          items: usuarios.map((user) {
                            return DropdownMenuItem<String>(
                              value: user.id.toString(),
                              child: Text(user.nombre),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUserId = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AgregarTareaView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 78, 158, 78),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          padding: EdgeInsets.all(7.0),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: tareaViewModel.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1F2B40),
                            ),
                          )
                        : tareasFiltradas.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay tareas disponibles',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await tareaViewModel
                                      .recargarTareas(userViewModel.token!);
                                },
                                child: ListView.builder(
                                  itemCount: tareasFiltradas.length,
                                  itemBuilder: (context, index) {
                                    final tarea = tareasFiltradas[index];
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
                                            color:
                                                Color.fromRGBO(79, 175, 178, 1),
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
                                          style: TextStyle(
                                              color: Colors.grey[800]),
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
                                                                tareaId:
                                                                    tarea.id),
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
                                                            EditarTareaView(
                                                                tareaId:
                                                                    tarea.id),
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
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            '¿Seguro de eliminar?',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          content: Text(
                                                              'Esta acción no se puede deshacer. ¿Desea continuar?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false),
                                                              child: Text(
                                                                  'Cancelar'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true),
                                                              child: Text(
                                                                'Eliminar',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
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
                                                              userViewModel
                                                                  .token!,
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
