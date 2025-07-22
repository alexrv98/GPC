import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/tarea_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/proyecto_view_model.dart';

class AgregarTareaView extends StatefulWidget {
  @override
  _AgregarTareaViewState createState() => _AgregarTareaViewState();
}

class _AgregarTareaViewState extends State<AgregarTareaView> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String estado = 'Pendiente';
  int? asignadoId;
  int? proyectoId;
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaSeleccionada ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        horaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final tareaViewModel = Provider.of<TareaViewModel>(context);
    final proyectoViewModel = Provider.of<ProyectoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Tarea', style: TextStyle(color: Colors.white)),
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
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nombre de la tarea',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          onChanged: (value) => setState(() => nombre = value),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor ingrese el nombre';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: estado,
                          decoration: InputDecoration(
                            labelText: 'Estado',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              estado = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor seleccione un estado';
                            }
                            return null;
                          },
                          items: ['Pendiente', 'En progreso', 'Completada']
                              .map((estado) => DropdownMenuItem<String>(
                                    value: estado,
                                    child: Text(estado),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Fecha Límite',
                                  labelStyle:
                                      TextStyle(color: Color(0xFF1F2B40)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Color(0xFF1F2B40)),
                                  ),
                                  hintText: 'Seleccionar fecha',
                                ),
                                controller: TextEditingController(
                                  text: fechaSeleccionada != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(fechaSeleccionada!)
                                      : '',
                                ),
                                onTap: _selectDate,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor ingrese la fecha límite';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: _selectDate,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Hora Límite',
                                  labelStyle:
                                      TextStyle(color: Color(0xFF1F2B40)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Color(0xFF1F2B40)),
                                  ),
                                  hintText: 'Seleccionar hora',
                                ),
                                controller: TextEditingController(
                                  text: horaSeleccionada != null
                                      ? horaSeleccionada!.format(context)
                                      : '',
                                ),
                                onTap: _selectTime,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor ingrese la hora límite';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.access_time),
                              onPressed: _selectTime,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: asignadoId,
                          decoration: InputDecoration(
                            labelText: 'Asignado a',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              asignadoId = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione un usuario';
                            }
                            return null;
                          },
                          items: userViewModel.usuarios.isNotEmpty
                              ? userViewModel.usuarios
                                  .map((user) => DropdownMenuItem<int>(
                                        value: user.id,
                                        child: Text(user.nombre),
                                      ))
                                  .toList()
                              : [
                                  DropdownMenuItem(
                                      value: null,
                                      child: Text("Cargando usuarios..."))
                                ],
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: proyectoId,
                          decoration: InputDecoration(
                            labelText: 'Proyecto',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              proyectoId = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione un proyecto';
                            }
                            return null;
                          },
                          items: proyectoViewModel.proyectos
                              .map((proyecto) => DropdownMenuItem<int>(
                                    value: proyecto['id'],
                                    child: Text(proyecto['nombre']),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                  errorMessage = '';
                                });

                                try {
                                  String fechaHoraLimite = '';
                                  if (fechaSeleccionada != null &&
                                      horaSeleccionada != null) {
                                    final fecha = DateFormat('yyyy-MM-dd')
                                        .format(fechaSeleccionada!);
                                    final hora = DateFormat('HH:mm:ss').format(
                                      DateTime(
                                        0,
                                        1,
                                        1,
                                        horaSeleccionada!.hour,
                                        horaSeleccionada!.minute,
                                      ),
                                    );
                                    fechaHoraLimite = '$fecha $hora';
                                  }

                                  Map<String, dynamic> tareaData = {
                                    'nombre': nombre,
                                    'estado': estado,
                                    'fecha_limite': fechaHoraLimite,
                                    'asignado_id': asignadoId,
                                    'proyecto_id': proyectoId,
                                  };

                                  await tareaViewModel.crearTarea(
                                    tareaData,
                                    userViewModel.token!,
                                  );

                                  Navigator.pop(context);
                                } catch (e) {
                                  setState(() {
                                    errorMessage = 'Error: ${e.toString()}';
                                  });
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                            child: Text(
                              'Agregar Tarea',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1F2B40),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
