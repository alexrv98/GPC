import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'viewmodels/terms_view_model.dart';
import 'viewmodels/user_view_model.dart';
import 'viewmodels/proyecto_view_model.dart';
import 'viewmodels/cliente_view_model.dart';
import 'viewmodels/tarea_view_model.dart';
import 'views/terms_view.dart';
import 'views/login_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TermsViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ProyectoViewModel()),
        ChangeNotifierProvider(create: (_) => TareaViewModel()),
        ChangeNotifierProvider(create: (_) => ClienteViewModel()),
      ],
      child: MaterialApp(
        home: FutureBuilder(
          future: checkTermsAccepted(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.data == true) {
              return LoginView();
            } else {
              return TermsView();
            }
          },
        ),
        routes: {
          '/login': (context) => LoginView(),
        },
      ),
    );
  }

  Future<bool> checkTermsAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasAcceptedTerms') ?? false;
  }
}
