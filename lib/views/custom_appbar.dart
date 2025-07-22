import 'package:flutter/material.dart';

AppBar customAppBar() {
  return AppBar(
    title: Text('', style: TextStyle(color: Colors.white)),
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
  );
}
