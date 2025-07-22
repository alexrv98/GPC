import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_view_model.dart';
import '../models/cliente_model.dart';

class ClienteViewModel extends ChangeNotifier {
  List<Cliente> clientes = [];
  bool _clientesCargados = false;
  Cliente? clienteActual;

  // Método para obtener la lista de clientes
  Future<void> obtenerClientes(String? token) async {
    if (!_clientesCargados && token != null) {
      final response = await http.get(
        Uri.parse('$baseURL/clienteslist'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        clientes = data.map((json) => Cliente.fromJson(json)).toList();
        _clientesCargados = true;
        notifyListeners();
      } else {
        throw Exception('Error al obtener clientes: ${response.body}');
      }
    }
  }

  // Método para forzar la recarga de clientes
  Future<void> recargarClientes(String? token) async {
    _clientesCargados = false;
    await obtenerClientes(token);
  }

// Método para crear un cliente
  Future<bool> crearCliente(String? token, Cliente cliente) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/clientes'),
        headers: {
          'Authorization': token!,
          'Content-Type':
              'application/json', 
        },
        body:
            jsonEncode(cliente.toJson()), 
      );

      print(
          'Respuesta de la API al crear cliente: ${response.body}'); 

      if (response.statusCode == 201) {
        await recargarClientes(token); 
        return true;
      } else {
        throw Exception('Error al crear el cliente: ${response.body}');
      }
    } catch (e) {
      print('Excepción al crear cliente: $e');
      rethrow; 
    }
  }

  // Método para editar un cliente

  Future<bool> editarCliente(String? token, int id, Cliente cliente) async {
    try {
      final response = await http.put(
        Uri.parse('$baseURL/clientes/$id'),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json', 
        },
        body: jsonEncode(cliente.toJson()), 
      );

      print(
          'Respuesta de la API al editar cliente: ${response.body}'); 

      if (response.statusCode == 200) {
        await recargarClientes(token); 
        return true;
      } else {
        throw Exception('Error al editar el cliente: ${response.body}');
      }
    } catch (e) {
      print('Excepción al editar cliente: $e');
      rethrow;
    }
  }

  // Método para eliminar un cliente
  Future<bool> eliminarCliente(String? token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseURL/clientes/$id'),
      headers: {'Authorization': token!},
    );

    if (response.statusCode == 200) {
      await recargarClientes(token);
      return true;
    } else {
      throw Exception('Error al eliminar el cliente: ${response.body}');
    }
  }

  // Método para obtener un cliente específico
  Future<void> obtenerClienteEspecifico(String? token, int id) async {
    final response = await http.get(
      Uri.parse('$baseURL/clientes/view/$id'),
      headers: {'Authorization': token!},
    );

    if (response.statusCode == 200) {
      clienteActual = Cliente.fromJson(json.decode(response.body));
      notifyListeners();
    } else {
      throw Exception('Error al obtener el cliente: ${response.body}');
    }
  }
}
