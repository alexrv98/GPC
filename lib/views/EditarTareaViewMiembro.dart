import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarea_model.dart';
import '../viewmodels/tarea_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/proyecto_view_model.dart';

class EditarTareaViewMiembro extends StatefulWidget {
  final int tareaId;

  EditarTareaViewMiembro({required this.tareaId});

  @override
  _EditarTareaViewState createState() => _EditarTareaViewState();
}

class _EditarTareaViewState extends State<EditarTareaViewMiembro> {
  final _formKey = GlobalKey<FormState>();
  late Tarea? tarea;
  String nombre = '';
  String estado = '';
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  int? asignadoId;
  int? proyectoId;

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarTarea();
  }

  Future<void> _cargarTarea() async {
    final tareaViewModel = Provider.of<TareaViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      tarea = await tareaViewModel.obtenerTarea(
          widget.tareaId, userViewModel.token!);

      if (tarea == null) {
        setState(() {
          errorMessage = 'No se encontró la tarea';
        });
        return;
      }

      setState(() {
        nombre = tarea?.nombre ?? '';
        estado = tarea?.estado ?? '';
        if (tarea?.fechaLimite != null) {
          fechaSeleccionada = tarea!.fechaLimite;
          horaSeleccionada = TimeOfDay.fromDateTime(tarea!.fechaLimite);
        }
        asignadoId = tarea?.asignadoId;
        proyectoId = tarea?.proyectoId;
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

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final tareaViewModel =
          Provider.of<TareaViewModel>(context, listen: false);
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);

      try {
        String fechaHoraLimite = '';
        if (fechaSeleccionada != null && horaSeleccionada != null) {
          final fecha = DateFormat('yyyy-MM-dd').format(fechaSeleccionada!);
          final hora = DateFormat('HH:mm:ss').format(
            DateTime(0, 1, 1, horaSeleccionada!.hour, horaSeleccionada!.minute),
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

        await tareaViewModel.actualizarTarea(
            widget.tareaId, tareaData, userViewModel.token!);
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Color(0xFF1F2B40),
        iconTheme: IconThemeData(color: Colors.white),
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
                          initialValue: nombre,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEAF2F7),
                            labelText: 'Nombre de la tarea',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          readOnly: true,
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: estado.isNotEmpty ? estado : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEAF2F7),
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
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEAF2F7),
                            labelText: 'Fecha Límite',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          controller: TextEditingController(
                            text: fechaSeleccionada != null
                                ? '${DateFormat('yyyy-MM-dd').format(fechaSeleccionada!)}'
                                : '',
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEAF2F7),
                            labelText: 'Hora Límite',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          controller: TextEditingController(
                            text: horaSeleccionada != null
                                ? horaSeleccionada!.format(context)
                                : '',
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: asignadoId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEAF2F7),
                            labelText: 'Asignado a',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          onChanged: null,
                          items: Provider.of<UserViewModel>(context)
                              .usuarios
                              .map((user) => DropdownMenuItem<int>(
                                    value: user.id,
                                    child: Text(user.nombre),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: proyectoId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEAF2F7),
                            labelText: 'Proyecto',
                            labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF1F2B40)),
                            ),
                          ),
                          onChanged: null,
                          items: Provider.of<ProyectoViewModel>(context)
                              .proyectos
                              .map((proyecto) => DropdownMenuItem<int>(
                                    value: proyecto['id'],
                                    child: Text(proyecto['nombre']),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _guardarCambios,
                            child: Text('Guardar Cambios',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1F2B40),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
