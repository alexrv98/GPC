import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import 'login_view.dart';

class VerifyCardView extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  VerifyCardView(
      {required this.name, required this.email, required this.password});

  @override
  _VerifyCardViewState createState() => _VerifyCardViewState();
}

class _VerifyCardViewState extends State<VerifyCardView> {
  final TextEditingController _creditCardController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificación de Tarjeta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Para completar el registro, ingresa tu tarjeta de crédito para verificar que la cuenta te pertenece. No se realizará ningún cargo.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _creditCardController,
                decoration: InputDecoration(
                  labelText: 'Número de Tarjeta',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final creditCard = _creditCardController.text;

                      // Llamar al método de registro que incluye la verificación de tarjeta
                      await userViewModel.register(
                        widget.name,
                        widget.email,
                        widget.password,
                        creditCard,
                      );

                      if (userViewModel.errorMessage == null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(userViewModel.errorMessage!)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(236, 160, 61, 1),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Verificar y Registrar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
