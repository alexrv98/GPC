import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'openid',
      'email',
      'profile',
      calendar.CalendarApi.calendarScope,
    ],
  );

  Future<http.Client?> _getHttpClient() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;

    if (accessToken == null) {
      print("Error: El token de acceso no está disponible.");
      return null;
    }

    // Crear las credenciales usando solo el accessToken
    final credentials = auth.AccessCredentials(
      auth.AccessToken(
          'Bearer', accessToken, DateTime.now().add(Duration(hours: 1))),
      null, // El refreshToken no es necesario
      ['https://www.googleapis.com/auth/calendar'],
    );

    // Crear un cliente autenticado para usar con las APIs de Google
    final client = auth.authenticatedClient(http.Client(), credentials);
    return client;
  }

  Future<void> addEventToCalendar(String taskName, String taskDeadline) async {
    final client = await _getHttpClient();
    if (client == null) return;

    var calendarApi = calendar.CalendarApi(client);
    var event = calendar.Event(
      summary: taskName,
      start: calendar.EventDateTime(
        dateTime: DateTime.parse(taskDeadline),
        timeZone: "GMT-5",
      ),
      end: calendar.EventDateTime(
        dateTime: DateTime.parse(taskDeadline).add(Duration(hours: 1)),
        timeZone: "GMT-5",
      ),
    );

    try {
      await calendarApi.events.insert(event, "primary");
      print("Evento agregado al calendario de Google.");
    } catch (e) {
      print("Error al agregar evento al calendario: $e");
    }
  }
}
