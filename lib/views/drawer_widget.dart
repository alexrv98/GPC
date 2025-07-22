import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'home_view.dart';
import 'view_usuarios.dart';
import 'tareas_view.dart';
import 'clientes_view.dart';
import 'VerTareasEnCalendarioView.dart';
import '../viewmodels/user_view_model.dart';
import 'apiGemini.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  CustomDrawer({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ClipPath(
        clipper: _TopRoundedClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1F2B40), // Fondo azul
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(
                  userEmail,
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 40.0,
                      color: Color(0xFF1F2B40),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1F2B40),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
              ),
              _createDrawerItem(
                context,
                icon: Icons.work,
                text: 'Proyectos',
                onTap: () => _navigateTo(context,
                    HomeView(userName: userName, userEmail: userEmail)),
              ),
              _createDrawerItem(
                context,
                icon: Icons.task,
                text: 'Tareas',
                onTap: () => _navigateTo(context,
                    TareasView(userName: userName, userEmail: userEmail)),
              ),
              _createDrawerItem(
                context,
                icon: Icons.calendar_month,
                text: 'Calendario de Tareas',
                onTap: () => _navigateTo(
                    context,
                    VerTareasEnCalendarioView(
                        userName: userName, userEmail: userEmail)),
              ),
              _createDrawerItem(
                context,
                icon: Icons.people,
                text: 'Clientes',
                onTap: () => _navigateTo(context,
                    ClientesView(userName: userName, userEmail: userEmail)),
              ),
              _createDrawerItem(
                context,
                icon: Icons.person,
                text: 'Usuarios',
                onTap: () => _navigateTo(context,
                    UsuariosView(userName: userName, userEmail: userEmail)),
              ),
              _createDrawerItem(
                context,
                icon: Icons.lightbulb,
                text: 'Pregunta a Gemini',
                onTap: () => _navigateTo(context,
                    GeminiPage(userName: userName, userEmail: userEmail)),
              ),
              Divider(thickness: 1, color: Colors.white38),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  // Llama al logout y reinicia la app
                  await Provider.of<UserViewModel>(context, listen: false)
                      .logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createDrawerItem(BuildContext context,
      {required IconData icon, required String text, required Function onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => onTap(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      tileColor: Color(0xFF1F2B40),
    );
  }

  void _navigateTo(BuildContext context, Widget view) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => view),
    );
  }
}

class _TopRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0); // Comienza en la esquina superior izquierda
    path.lineTo(0, size.height * 0.89); // Corta justo a la mitad del Drawer
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width,
        size.height * 0.89); // Curva en las esquinas superiores
    path.lineTo(size.width, 0); // Baja hasta la esquina superior derecha
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No es necesario volver a recortar
  }
}
