class Proyecto {
  final int id;
  final String nombre;
  final String descripcion;
  final int userId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double presupuesto;
  final String prioridad;
  final String categoria;
  final double avance;
  final String? comentarios; 
  final DateTime? fechaEntrega;
  final int clienteId;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.userId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.presupuesto,
    required this.prioridad,
    required this.categoria,
    required this.avance,
    this.comentarios,
    this.fechaEntrega,
    required this.clienteId,
  });

  // Método de fábrica para crear un proyecto a partir de un JSON
  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      userId: json['user_id'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      presupuesto: json['presupuesto'].toDouble(),
      prioridad: json['prioridad'],
      categoria: json['categoria'],
      avance: json['avance'].toDouble(),
      comentarios: json['comentarios'],
      fechaEntrega: json['fecha_entrega'] != null
          ? DateTime.parse(json['fecha_entrega'])
          : null,
      clienteId: json['cliente_id'],
    );
  }

  // Método para convertir el objeto Proyecto a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'user_id': userId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'presupuesto': presupuesto,
      'prioridad': prioridad,
      'categoria': categoria,
      'avance': avance,
      'comentarios': comentarios,
      'fecha_entrega': fechaEntrega?.toIso8601String(),
      'cliente_id': clienteId,
    };
  }
}
