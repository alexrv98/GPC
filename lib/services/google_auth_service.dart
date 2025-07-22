import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'openid',
      'email',
      'profile'
    ], // Asegúrate de que estos scopes estén presentes
  );

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      return googleUser;
    } catch (error) {
      print("Error durante el inicio de sesión: $error");
      return null;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    print("Usuario desconectado de Google.");
  }
}
