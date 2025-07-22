import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/proyecto_view_model.dart';

class VerProyectoView extends StatefulWidget {
  final String proyectoId;
  final String? token;

  VerProyectoView({required this.proyectoId, required this.token});

  @override
  _VerProyectoViewState createState() => _VerProyectoViewState();
}

class _VerProyectoViewState extends State<VerProyectoView> {
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarProyecto();
  }

  Future<void> _cargarProyecto() async {
    final proyectoViewModel =
        Provider.of<ProyectoViewModel>(context, listen: false);
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await proyectoViewModel.obtenerProyecto(widget.token, widget.proyectoId);
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
        title: Text('Detalles del Proyecto',
            style: TextStyle(color: Colors.white)),
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
            child: Consumer<ProyectoViewModel>(
              builder: (context, proyectoViewModel, child) {
                final proyecto = proyectoViewModel.proyectoActual;

                if (isLoading) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF1F2B40)));
                }

                if (errorMessage.isNotEmpty) {
                  return Center(
                      child: Text(errorMessage,
                          style: TextStyle(color: Colors.red)));
                }

                if (proyecto == null) {
                  return Center(child: Text("Proyecto no encontrado"));
                }

                return SingleChildScrollView(
                  child: Column(
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
                      // Información del Proyecto con padding adicional
                      _buildProyectoInfo(
                          'Nombre', proyecto['nombre'] ?? 'Sin nombre'),
                      _buildProyectoInfo('Descripción',
                          proyecto['descripcion'] ?? 'Sin descripción'),
                      _buildProyectoInfo(
                          'Presupuesto', '\$${proyecto['presupuesto'] ?? 0.0}'),
                      _buildProyectoInfo(
                          'Prioridad', proyecto['prioridad'] ?? 'Baja'),
                      _buildProyectoInfo(
                          'Categoría', proyecto['categoria'] ?? 'General'),
                      _buildProyectoInfo(
                          'Avance', '${proyecto['avance'] ?? 0.0}%'),
                      _buildProyectoInfo('Comentarios',
                          proyecto['comentarios'] ?? 'Sin comentarios'),
                      _buildProyectoInfo(
                          'Fecha de Inicio',
                          proyecto['fecha_inicio'] != null
                              ? DateTime.parse(proyecto['fecha_inicio'])
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'No disponible'),
                      _buildProyectoInfo(
                          'Fecha de Fin',
                          proyecto['fecha_fin'] != null
                              ? DateTime.parse(proyecto['fecha_fin'])
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'No disponible'),
                      _buildProyectoInfo(
                          'Fecha de Entrega',
                          proyecto['fecha_entrega'] != null
                              ? DateTime.parse(proyecto['fecha_entrega'])
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'No disponible'),
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
                          elevation: 5,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Widget para construir la información del proyecto con padding
  Widget _buildProyectoInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
