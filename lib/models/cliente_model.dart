class Cliente {
  final int id;
  final String nombreEmpresa;
  final String rfc;
  final String? direccion;
  final String? telefono;
  final String? emailContacto;
  final String? encargadoNombre;
  final String? encargadoEmail;
  final String? encargadoTelefono;

  Cliente({
    required this.id,
    required this.nombreEmpresa,
    required this.rfc,
    this.direccion,
    this.telefono,
    this.emailContacto,
    this.encargadoNombre,
    this.encargadoEmail,
    this.encargadoTelefono,
  });

  // Método para deserializar JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombreEmpresa: json['nombre_empresa'],
      rfc: json['rfc'],
      direccion: json['direccion'],
      telefono: json['telefono']?.toString(), // Convertir a String si es int
      emailContacto: json['email_contacto'],
      encargadoNombre: json['encargado_nombre'],
      encargadoEmail: json['encargado_email'],
      encargadoTelefono: json['encargado_telefono']
          ?.toString(), // Convertir a String si es int
    );
  }

  // Método para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_empresa': nombreEmpresa,
      'rfc': rfc,
      'direccion': direccion,
      'telefono': telefono ?? '', // Convertir nulos a cadenas vacías
      'email_contacto': emailContacto ?? '',
      'encargado_nombre': encargadoNombre ?? '',
      'encargado_email': encargadoEmail ?? '',
      'encargado_telefono': encargadoTelefono ?? '',
    };
  }
}
