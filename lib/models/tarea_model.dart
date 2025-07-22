class Tarea {
  final int id;
  final String nombre;
  final String estado;
  final DateTime fechaLimite;
  final int asignadoId;
  final int proyectoId;

  Tarea({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.fechaLimite,
    required this.asignadoId,
    required this.proyectoId,
  });

  // Constructor para crear una instancia desde un JSON
  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      nombre: json['nombre'],
      estado: json['estado'],
      fechaLimite: DateTime.parse(json['fecha_limite']), // Convertir a DateTime
      asignadoId: json['asignado_id'],
      proyectoId: json['proyecto_id'],
    );
  }

  // Si necesitas convertirlo de nuevo a JSON (por ejemplo, para enviarlo a la API):
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
      'fecha_limite':
          fechaLimite.toIso8601String(), // Convierte DateTime a String
      'asignado_id': asignadoId,
      'proyecto_id': proyectoId,
    };
  }
}
