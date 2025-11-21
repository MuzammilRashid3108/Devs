import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Step 1: Start Google sign in
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) return null;

      // Step 2: Google auth details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Step 3: Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Step 4: Login to Firebase
      UserCredential userCred =
      await _auth.signInWithCredential(credential);

      return userCred.user;
    } catch (e) {
      print("Google Auth Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
