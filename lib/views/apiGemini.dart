import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'drawer_widget.dart';

class GeminiAPIService {
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  final String _apiKey = 'AIzaSyA7tTCES9oOvQIKtPlkkBA7Q-9t83vCVdk';

  Future<String> generateContent(String prompt) async {
    final response = await http.post(
      Uri.parse('$_apiUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      try {
        var data = json.decode(response.body);
        if (data != null &&
            data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'] ??
              'No se generó texto.';
        } else {
          return 'Respuesta inválida de la API.';
        }
      } catch (e) {
        return 'Error al procesar la respuesta: $e';
      }
    } else {
      return 'Error en la solicitud: ${response.statusCode}';
    }
  }
}

class GeminiPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  GeminiPage({required this.userName, required this.userEmail});

  @override
  _GeminiPageState createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _chatMessages = [];
  bool _isLoading = false;

  Future<void> _onGenerateButtonPressed() async {
    String prompt = _controller.text.trim();
    if (prompt.isNotEmpty) {
      setState(() {
        _chatMessages.add("Tú: $prompt");
        _isLoading = true;
      });
      _controller.clear();

      try {
        String result = await GeminiAPIService().generateContent(prompt);
        setState(() {
          _chatMessages.add("Gemini: $result");
        });
      } catch (e) {
        setState(() {
          _chatMessages.add("Error: $e");
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini IA', style: TextStyle(color: Colors.white)),
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
      drawer: CustomDrawer(
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/gemini2.png', // Imagen decorativa
                          height: 50,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '¿Con qué puedo ayudarte?',
                          style: TextStyle(
                            fontSize: 25,
                            color: Color(0xFF1F2B40),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      bool isUserMessage =
                          _chatMessages[index].startsWith("Tú:");
                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: isUserMessage
                                ? Color(0xFFD1E5FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border:
                                Border.all(color: Color(0xFF44525B), width: 1),
                          ),
                          child: Text(
                            _chatMessages[index],
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF3FA5E4)),
                  onPressed: _onGenerateButtonPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
