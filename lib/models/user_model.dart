class UserModel {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String? token;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'] ?? '',
      rol: json['rol'],
      token: json['token'],
    );
  }
}
