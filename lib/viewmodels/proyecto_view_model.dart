import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_view_model.dart';
import 'dart:convert';

class ProyectoViewModel extends ChangeNotifier {
  List<dynamic> proyectos = [];
  bool _proyectosCargados = false; 
  Map<String, dynamic>?
      proyectoActual; 

  // Método para obtener el nombre del proyecto por su ID
  dynamic getProyectoById(int id) {
    return proyectos.firstWhere((proyecto) => proyecto['id'] == id,
        orElse: () => null);
  }

  // Método para obtener la lista de proyectos admin
  Future<void> obtenerProyectos(String? token) async {
    if (!_proyectosCargados && token != null) {
      print('Token enviado en la solicitud: $token');

      final response = await http.get(
        Uri.parse('$baseURL/proyectoslist'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        proyectos = json.decode(response.body);
        print(proyectos);
        _proyectosCargados = true;
      } else {

        final mensajeError =
            json.decode(response.body)['message'] ?? 'Error desconocido';
        print('Error: Código de estado ${response.statusCode}');
        print('Mensaje de error de la API: $mensajeError');
        throw Exception(mensajeError);
      }
    }
  }

  // Método para forzar la recarga de proyectos, si es necesario en otro momento
  Future<void> recargarProyectos(String? token) async {
    _proyectosCargados = false;
    await obtenerProyectos(token);
    notifyListeners();
  }

  Future<bool> crearProyecto(
    String? token,
    String nombre,
    String descripcion,
    DateTime fechaInicio,
    DateTime fechaFin,
    double presupuesto,
    String prioridad,
    String categoria,
    double avance,
    String? comentarios,
    DateTime? fechaEntrega,
    int clienteId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseURL/proyectos'),
      headers: {'Authorization': token!},
      body: {
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'presupuesto': presupuesto.toString(),
        'prioridad': prioridad,
        'categoria': categoria,
        'avance': avance.toString(),
        'comentarios': comentarios,
        'fecha_entrega': fechaEntrega?.toIso8601String(),
        'cliente_id': clienteId.toString(),
      },
    );

    if (response.statusCode == 201) {
      await obtenerProyectos(
          token); 
      notifyListeners();
      return true;
    } else {
      throw Exception('Error al crear el proyecto: ${response.body}');
    }
  }

  Future<bool> editarProyecto(
    String? token,
    int proyectoId,
    String nombre,
    String descripcion,
    DateTime fechaInicio,
    DateTime fechaFin,
    double presupuesto,
    String prioridad,
    String categoria,
    double avance,
    String? comentarios,
    DateTime? fechaEntrega,
    int clienteId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseURL/proyectos/$proyectoId'),
      headers: {'Authorization': token!},
      body: {
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'presupuesto': presupuesto.toString(),
        'prioridad': prioridad,
        'categoria': categoria,
        'avance': avance.toString(),
        'comentarios': comentarios,
        'fecha_entrega': fechaEntrega?.toIso8601String(),
        'cliente_id': clienteId.toString(),
      },
    );

    if (response.statusCode == 200) {
      await obtenerProyectos(
          token); 
      notifyListeners();
      return true;
    } else {
      throw Exception('Error al editar el proyecto: ${response.body}');
    }
  }

  // Nuevo método para obtener los detalles de un proyecto específico
  Future<void> obtenerProyecto(String? token, String proyectoId) async {
    if (token == null) {
      throw Exception('Token no válido');
    }

    final response = await http.get(
      Uri.parse('$baseURL/proyectosview/$proyectoId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      proyectoActual = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Error al obtener el proyecto: ${response.body}');
    }
  }

  Future<void> eliminarProyecto(int proyectoId, String? token) async {
    if (token == null) {
      return Future.error('Token no válido');
    }

    final response = await http.delete(
      Uri.parse('$baseURL/proyectos/$proyectoId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      
      notifyListeners();
    } else {
      
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final errorMessage = responseBody['mensaje'] ??
          'No tienes permisos suficientes para eliminar este proyecto.';
      return Future.error(errorMessage);
    }
  }
}
