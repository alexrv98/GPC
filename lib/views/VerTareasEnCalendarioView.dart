import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/tarea_model.dart';
import 'drawer_widget.dart';
import '../viewmodels/tarea_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'verTareaView.dart';

class VerTareasEnCalendarioView extends StatefulWidget {
  final String userName;
  final String userEmail;

  VerTareasEnCalendarioView({required this.userName, required this.userEmail});

  @override
  _VerTareasEnCalendarioViewState createState() =>
      _VerTareasEnCalendarioViewState();
}

class _VerTareasEnCalendarioViewState extends State<VerTareasEnCalendarioView> {
  late Map<DateTime, List<Tarea>> _eventos;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _eventos = {};
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    final tareaViewModel = Provider.of<TareaViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    await tareaViewModel.obtenerTareas(userViewModel.token!);

    setState(() {
      _eventos = _groupTareasPorFecha(tareaViewModel.tareas);
    });
  }

  Map<DateTime, List<Tarea>> _groupTareasPorFecha(List<Tarea> tareas) {
    Map<DateTime, List<Tarea>> eventos = {};
    for (var tarea in tareas) {
      final fecha = DateTime(tarea.fechaLimite.year, tarea.fechaLimite.month,
          tarea.fechaLimite.day);
      if (eventos[fecha] == null) eventos[fecha] = [];
      eventos[fecha]!.add(tarea);
    }
    return eventos;
  }

  List<Tarea> _obtenerTareasDelDia(DateTime date) {
    return _eventos[DateTime(date.year, date.month, date.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Calendario de Tareas", style: TextStyle(color: Colors.white)),
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
      ),
      drawer:
          CustomDrawer(userName: widget.userName, userEmail: widget.userEmail),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _obtenerTareasDelDia,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF1F2B40),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2B40)),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Color(0xFF1F2B40)),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Color(0xFF1F2B40)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _obtenerTareasDelDia(_selectedDay ?? _focusedDay).isEmpty
                ? Center(
                    child: Text("No hay tareas para este día.",
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _obtenerTareasDelDia(_selectedDay ?? _focusedDay)
                        .length,
                    itemBuilder: (context, index) {
                      final tarea = _obtenerTareasDelDia(
                          _selectedDay ?? _focusedDay)[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 1.0),
                        child: Card(
                          color: Color.fromARGB(237, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 10,
                          child: ListTile(
                            title: Text(tarea.nombre,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2B40))),
                            subtitle: Text(
                              'Fecha límite: ${tarea.fechaLimite.toString().split(' ')[0]}',
                              style: TextStyle(color: Color(0xFF1F2B40)),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Color(0xFF1F2B40), size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VerTareaView(tareaId: tarea.id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
