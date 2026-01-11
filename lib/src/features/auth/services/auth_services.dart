import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //Google Auth

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    // Step 1: Start Google sign in
    final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
    if (gUser == null) return null; // User cancelled

    // Step 2: Google auth details
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Step 3: Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Step 4: Login to Firebase
    UserCredential userCred = await _auth.signInWithCredential(credential);

    return userCred.user;
  }

  // ===============================
  // EMAIL + PASSWORD SIGN UP
  // ===============================
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCred.user;
    } on FirebaseAuthException catch (e) {
      print("Email Signup Error: ${e.message}");
      return null;
    }
  }

  // ===============================
  // EMAIL + PASSWORD LOGIN
  // ===============================
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCred.user;
    } on FirebaseAuthException catch (e) {
      print("Email Login Error: ${e.message}");
      return null;
    }
  }

  // ===============================
  // PHONE AUTH - SEND OTP
  // ===============================
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function()? onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (onVerificationCompleted != null) {
          onVerificationCompleted();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "OTP Failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // ===============================
  // PHONE AUTH - VERIFY OTP
  // ===============================
  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);

      return userCred.user;
    } catch (e) {
      print("OTP Verify Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
