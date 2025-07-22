import 'package:flutter/material.dart';
import '../viewmodels/proyecto_view_model.dart';
import '../viewmodels/cliente_view_model.dart'; // Importa el ViewModel de Cliente
import '../models/cliente_model.dart'; // Asegúrate de importar tu modelo de Cliente

class EditarProyectoView extends StatefulWidget {
  final String? token;
  final int proyectoId;

  EditarProyectoView({
    required this.token,
    required this.proyectoId,
  });

  @override
  _EditarProyectoViewState createState() => _EditarProyectoViewState();
}

class _EditarProyectoViewState extends State<EditarProyectoView> {
  final _formKey = GlobalKey<FormState>();
  late ProyectoViewModel _proyectoViewModel;
  late ClienteViewModel _clienteViewModel; // Instancia del ViewModel de Cliente

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _presupuestoController;
  late TextEditingController _prioridadController;
  late TextEditingController _categoriaController;
  late TextEditingController _avanceController;
  late TextEditingController _comentariosController;
  late TextEditingController _clienteIdController;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  DateTime? _fechaEntrega;

  bool isLoading = false;
  String errorMessage = '';
  Cliente? _clienteSeleccionado; // Variable para el cliente seleccionado

  @override
  void initState() {
    super.initState();
    _proyectoViewModel = ProyectoViewModel();
    _clienteViewModel =
        ClienteViewModel(); // Inicializa el ViewModel de Cliente
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _presupuestoController = TextEditingController();
    _prioridadController = TextEditingController();
    _categoriaController = TextEditingController();
    _avanceController = TextEditingController();
    _comentariosController = TextEditingController();
    _clienteIdController = TextEditingController();
    _cargarDatosProyecto();
    _cargarClientes(); // Cargar la lista de clientes
  }

  Future<void> _cargarDatosProyecto() async {
    try {
      await _proyectoViewModel.obtenerProyecto(
          widget.token, widget.proyectoId.toString());
      final proyecto = _proyectoViewModel.proyectoActual;
      if (proyecto != null) {
        setState(() {
          _nombreController.text = proyecto['nombre'] ?? '';
          _descripcionController.text = proyecto['descripcion'] ?? '';
          _presupuestoController.text = proyecto['presupuesto'].toString();
          _prioridadController.text = proyecto['prioridad'] ?? '';
          _categoriaController.text = proyecto['categoria'] ?? '';
          _avanceController.text = proyecto['avance'].toString();
          _comentariosController.text = proyecto['comentarios'] ?? '';
          _clienteIdController.text = proyecto['cliente_id'].toString();
          _fechaInicio = DateTime.parse(proyecto['fecha_inicio']);
          _fechaFin = DateTime.parse(proyecto['fecha_fin']);
          _fechaEntrega = proyecto['fecha_entrega'] != null
              ? DateTime.parse(proyecto['fecha_entrega'])
              : null;

          // Si el cliente existe, lo asignamos, si no, asignamos un cliente vacío
          _clienteSeleccionado = _clienteViewModel.clientes.isNotEmpty &&
                  _clienteViewModel.clientes.any((cliente) =>
                      cliente.id == int.tryParse(_clienteIdController.text))
              ? _clienteViewModel.clientes.firstWhere(
                  (cliente) =>
                      cliente.id == int.tryParse(_clienteIdController.text),
                )
              : null; // Aquí asignamos null si no se encuentra el cliente
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar el proyecto: $e';
      });
    }
  }

  Future<void> _cargarClientes() async {
    try {
      await _clienteViewModel.obtenerClientes(widget.token);
      setState(() {
        // Cliente vacío con valores predeterminados
        Cliente clienteVacio = Cliente(
          id: 0, // id falso
          nombreEmpresa: 'No seleccionado',
          rfc: '',
          direccion: '',
          telefono: '',
          emailContacto: '',
          encargadoNombre: '',
          encargadoEmail: '',
          encargadoTelefono: '',
        );

        // Si no se encuentra el cliente, asignamos el cliente vacío
        _clienteSeleccionado = _clienteViewModel.clientes.firstWhere(
          (cliente) => cliente.id == int.tryParse(_clienteIdController.text),
          orElse: () => clienteVacio, // Asignar el cliente vacío
        );
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los clientes: $e';
      });
    }
  }

  Future<void> _editarProyecto() async {
    if (!_formKey.currentState!.validate()) return;

    final clienteId = _clienteSeleccionado?.id;
    if (clienteId == null || clienteId <= 0) {
      setState(() {
        errorMessage = 'Cliente no válido';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final editadoConExito = await _proyectoViewModel.editarProyecto(
        widget.token,
        widget.proyectoId,
        _nombreController.text,
        _descripcionController.text,
        _fechaInicio!,
        _fechaFin!,
        double.tryParse(_presupuestoController.text) ?? 0.0,
        _prioridadController.text,
        _categoriaController.text,
        double.tryParse(_avanceController.text) ?? 0.0,
        _comentariosController.text.isEmpty
            ? null
            : _comentariosController.text,
        _fechaEntrega,
        clienteId,
      );

      if (editadoConExito) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDatePicker(
      String label, DateTime? selectedDate, Function(DateTime) onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Color(0xFF1F2B40), fontSize: 16),
          ),
          SizedBox(height: 4),
          InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  onDateChanged(pickedDate);
                });
              }
            },
            child: IgnorePointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: selectedDate == null
                      ? 'Seleccionar fecha'
                      : selectedDate.toLocal().toString().split(' ')[0],
                  labelStyle: TextStyle(color: Color(0xFF1F2B40)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    selectedDate == null ? '$label es obligatorio' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int? maxLines, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF1F2B40)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '$label es obligatorio' : null,
      ),
    );
  }

  Widget _buildClienteDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<Cliente>(
        decoration: InputDecoration(
          labelText: 'Seleccionar Cliente',
          labelStyle: TextStyle(color: Color(0xFF1F2B40)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: _clienteSeleccionado,
        onChanged: (Cliente? cliente) {
          setState(() {
            _clienteSeleccionado = cliente;
          });
        },
        items: _clienteViewModel.clientes.map((cliente) {
          return DropdownMenuItem<Cliente>(
            value: cliente,
            child: Text(cliente.nombreEmpresa), // Usa 'nombreEmpresa' aquí
          );
        }).toList(),
        validator: (value) => value == null ? 'Cliente es obligatorio' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Proyecto', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F2B40),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                _buildTextField('Nombre del Proyecto', _nombreController),
                _buildTextField(
                    'Descripción del Proyecto', _descripcionController,
                    maxLines: 4),
                _buildDatePicker('Fecha de Inicio', _fechaInicio, (newDate) {
                  _fechaInicio = newDate;
                }),
                _buildDatePicker('Fecha de Fin', _fechaFin, (newDate) {
                  _fechaFin = newDate;
                }),
                _buildDatePicker('Fecha de Entrega', _fechaEntrega, (newDate) {
                  _fechaEntrega = newDate;
                }),
                _buildTextField('Presupuesto', _presupuestoController,
                    keyboardType: TextInputType.number),
                _buildTextField('Prioridad', _prioridadController),
                _buildTextField('Categoría', _categoriaController),
                _buildTextField('Avance', _avanceController,
                    keyboardType: TextInputType.number),
                _buildTextField('Comentarios', _comentariosController,
                    maxLines: 3),
                _buildClienteDropdown(), // Agrega el dropdown del cliente
                isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1F2B40)))
                    : ElevatedButton(
                        onPressed: _editarProyecto,
                        child: Text('Guardar cambios',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1F2B40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
