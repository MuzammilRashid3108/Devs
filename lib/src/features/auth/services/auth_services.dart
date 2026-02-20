import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../profile/data/user-service.dart';
import '../../profile/domain/user_model.dart';

class AuthService {
  final _auth        = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _userService  = UserService();

  // ── Current user stream (listen in app root) ──────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Current user (sync) ───────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Google Sign In ────────────────────────────────────────────────────────
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken:     gAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user     = userCred.user;
      if (user == null) return null;

      // Create Firestore doc only if new user
      final isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      if (isNew) {
        await _userService.createUserDoc(AppUser(
          uid:       user.uid,
          username:  user.displayName ?? 'Coder${user.uid.substring(0, 4)}',
          email:     user.email ?? '',
          avatar:    '🧑‍💻',
          bio:       '',
          country:   '',
          xp:        0,
          streak:    0,
          mmr:       1000,
          createdAt: DateTime.now(),
        ));
      }
      return user;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  // ── Email Sign Up ─────────────────────────────────────────────────────────
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email:    email,
        password: password,
      );
      final user = userCred.user;
      if (user == null) return AuthResult.error('Signup failed');

      // Create Firestore user doc
      await _userService.createUserDoc(AppUser(
        uid:       user.uid,
        username:  username,
        email:     email,
        avatar:    '🧑‍💻',
        bio:       '',
        country:   '',
        xp:        0,
        streak:    0,
        mmr:       1000,
        createdAt: DateTime.now(),
      ));

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    }
  }

  // ── Email Sign In ─────────────────────────────────────────────────────────
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email:    email,
        password: password,
      );
      final user = userCred.user;
      if (user == null) return AuthResult.error('Login failed');
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    }
  }

  // ── Phone Auth — Send OTP ─────────────────────────────────────────────────
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
        onVerificationCompleted?.call();
      },
      verificationFailed: (e) => onError(e.message ?? 'OTP Failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // ── Phone Auth — Verify OTP ───────────────────────────────────────────────
  Future<AuthResult> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode:        smsCode,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) return AuthResult.error('Verification failed');
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('OTP Verify Error: $e');
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_friendlyError(e.code));
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Friendly error messages ───────────────────────────────────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'too-many-requests':    return 'Too many attempts. Please try again later.';
      default:                     return 'Something went wrong. Please try again.';
    }
  }
}

// ── Result wrapper — replaces nullable User? ─────────────────────────────────
class AuthResult {
  final User? user;
  final String? error;
  bool get isSuccess => error == null;

  const AuthResult._({this.user, this.error});
  factory AuthResult.success(User? user) => AuthResult._(user: user);
  factory AuthResult.error(String msg)   => AuthResult._(error: msg);
}