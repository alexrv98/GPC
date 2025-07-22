import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/terms_view_model.dart';

class TermsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Términos y Condiciones')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      height: 1.5, // Establecer el interlineado a 2
                    ),
                    children: [
                      TextSpan(
                        text:
                            '''Con fundamento en los artículos 2, 3, 15 y 16 de la Ley Federal de Protección de Datos Personales en Posesión de los Particulares, hacemos de su conocimiento que ''',
                      ),
                      TextSpan(
                        text: 'FORA Software Developer Group, S.A. de C.V.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ''', con domicilio en la Ciudad de México, en lo sucesivo ''',
                      ),
                      TextSpan(
                        text: 'FORA',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ''', es responsable del tratamiento de sus datos personales y del uso que se les dé, así como de su protección. La información personal que se recabe a través de la aplicación móvil "Gestor de Proyectos Colaborativo" (GPC) será utilizada para las siguientes finalidades:\n\n''',
                      ),
                      TextSpan(
                        text:
                            '·         Control y registro de los usuarios que participan en los proyectos dentro de la plataforma GPC.\n\n',
                      ),
                      TextSpan(
                        text:
                            '·         Creación y gestión de proyectos y tareas asignadas dentro de los equipos de trabajo.\n\n',
                      ),
                      TextSpan(
                        text:
                            '·         Notificación de avances, fechas límite y actualizaciones relacionadas con los proyectos.\n\n',
                      ),
                      TextSpan(
                        text:
                            '·         Asignación de roles de usuario dentro de los equipos (administrador, miembro).\n\n',
                      ),
                      TextSpan(
                        text:
                            '·         Actualización y mantenimiento de la base de datos de usuarios y proyectos.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Para cumplir con estas finalidades, FORA podría requerir, total o parcialmente, los siguientes datos personales:\n\n',
                      ),
                      TextSpan(
                        text: '·         Nombre completo\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '·         Correo electrónico\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '·         Contraseña (almacenada de forma cifrada)\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '·         Rol en los proyectos (administrador, miembro)\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '·         Información sobre los proyectos y tareas asignadas (nombre del proyecto, descripción, fecha límite, etc)\n\n',
                      ),
                      TextSpan(
                        text:
                            'Los datos personales son información que identifica o puede identificar a una persona. ',
                      ),
                      TextSpan(
                        text:
                            'FORA no solicita ni tratará datos personales sensibles (como creencias religiosas, filosóficas, afiliación sindical, estado de salud, o preferencias sexuales) para el funcionamiento de esta aplicación.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify, // Justificar el texto
                ),
              ),
            ),
            Consumer<TermsViewModel>(
              builder: (context, termsViewModel, child) {
                return ElevatedButton(
                  onPressed: () async {
                    await termsViewModel.acceptTerms();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Aceptar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
