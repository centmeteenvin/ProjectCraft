import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {

  static Future<void> loginGoogle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;


    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'email', 'https://www.googleapis.com/auth/contacts.readonly'
    ]);
    final GoogleSignInAccount? googleAccount = await googleSignIn.signInSilently();

    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await auth.signInWithCredential(credential);
    }
  }
}

