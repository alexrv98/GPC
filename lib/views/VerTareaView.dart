import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarea_model.dart';
import '../viewmodels/tarea_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/proyecto_view_model.dart';

class VerTareaView extends StatefulWidget {
  final int tareaId;

  VerTareaView({required this.tareaId});

  @override
  _VerTareaViewState createState() => _VerTareaViewState();
}

class _VerTareaViewState extends State<VerTareaView> {
  bool isLoading = true;
  String errorMessage = '';
  Tarea? tarea;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de Tarea',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Color(0xFF1F2B40), // Mismo color que la appBar de 'VerProyectoView'
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
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF1F2B40)))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
                    : tarea == null
                        ? Center(
                            child: Text(
                              'Tarea no encontrada',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Título con color de fondo ajustado
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1F2B40), // Azul oscuro
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(20),
                                ),
                                SizedBox(height: 20),
                                // Información de la tarea con padding adicional
                                _buildTareaInfo('Nombre', tarea!.nombre),
                                _buildTareaInfo('Estado', tarea!.estado),
                                _buildTareaInfo('Fecha Límite',
                                    tarea!.fechaLimite.toIso8601String()),

                                _buildTareaInfo(
                                    'Asignado a',
                                    Provider.of<UserViewModel>(context)
                                            .getUsuarioById(tarea!.asignadoId)
                                            ?.nombre ??
                                        'Desconocido'),
                                _buildTareaInfo(
                                    'Proyecto',
                                    Provider.of<ProyectoViewModel>(context)
                                            .getProyectoById(
                                                tarea!.proyectoId)?['nombre'] ??
                                        'Desconocido'),
                                SizedBox(height: 20),
                                // Botón de regreso
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Volver',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color(0xFF1F2B40), // Mismo color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
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

  // Widget para construir la información de la tarea con padding
  Widget _buildTareaInfo(String label, String value) {
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
            value,
            style: TextStyle(fontSize: 16, color: Color(0xFF1F2B40)),
          ),
          Divider(color: Colors.grey[400]),
        ],
      ),
    );
  }
}
