import 'package:flutter/material.dart';
import 'drawer_widget_miembro.dart'; // Asegúrate de importar tu Drawer personalizado

class NoPermissionsView extends StatelessWidget {
  final String userName;
  final String userEmail;

  NoPermissionsView({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceso Denegado', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F2B40), // Color similar al de la app
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Flecha de retroceso
          onPressed: () {
            Navigator.pop(context); // Regresa a la vista anterior
          },
        ),
      ),
      drawer: CustomDrawer(
          userName: userName, userEmail: userEmail), // Drawer personalizado
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/denegado1.png', // Asegúrate de tener esta imagen en tu carpeta de assets
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
                'Oops, no tienes permisos suficientes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2B40),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Contacta a un administrador para obtener los permisos necesarios.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
