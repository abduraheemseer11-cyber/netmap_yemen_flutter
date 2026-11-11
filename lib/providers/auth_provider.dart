import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  User? user;
  bool busy = false;
  String? errorKey; // key into S.t()

  AuthProvider() {
    user = _auth.currentUser; // persisted session also works offline
    _auth.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String pass) =>
      _run(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: pass));

  Future<bool> register(String email, String pass) =>
      _run(() => _auth.createUserWithEmailAndPassword(email: email.trim(), password: pass));

  Future<void> signOut() => _auth.signOut();

  Future<bool> _run(Future<dynamic> Function() action) async {
    busy = true;
    errorKey = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      errorKey = switch (e.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-email' => 'err_credentials',
        'email-already-in-use' => 'err_exists',
        'weak-password' => 'err_weak',
        'network-request-failed' => 'err_network',
        _ => 'err_generic',
      };
      return false;
    } catch (_) {
      errorKey = 'err_generic';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
