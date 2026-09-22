import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

const String _kGenericError = 'Something went wrong. Please try again.';
const String _kServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
);

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(const AuthUnknown()) {
    _sub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;
  bool _googleInitialized = false;

  void _onAuthChanged(User? user) {
    if (user == null) {
      emit(const Unauthenticated());
    } else {
      emit(_fromUser(user));
    }
  }

  Authenticated _fromUser(User user) {
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    return Authenticated(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      signInMethod: isGoogle ? 'Google' : 'Email',
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(errorMessage: _messageFor(e)));
    } catch (_) {
      emit(const Unauthenticated(errorMessage: _kGenericError));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthLoading());
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(errorMessage: _messageFor(e)));
    } catch (_) {
      emit(const Unauthenticated(errorMessage: _kGenericError));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        emit(const Unauthenticated(errorMessage: _kGenericError));
        return;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(const Unauthenticated());
      } else {
        emit(const Unauthenticated(errorMessage: _kGenericError));
      }
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(errorMessage: _messageFor(e)));
    } catch (_) {
      emit(const Unauthenticated(errorMessage: _kGenericError));
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: _kServerClientId.isEmpty ? null : _kServerClientId,
    );
    _googleInitialized = true;
  }

  Future<String?> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return 'Enter your email first.';
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found for this email.';
      }
      return _messageFor(e);
    } catch (_) {
      return _kGenericError;
    }
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google sign-out errors; Firebase sign-out still runs.
    }
    await _auth.signOut();
  }

  void clearError() {
    final s = state;
    if (s is Unauthenticated && s.errorMessage != null) {
      emit(const Unauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

String _messageFor(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Wrong email or password.';
    case 'invalid-email':
      return 'Enter a valid email.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'weak-password':
      return 'Password must be at least 6 characters.';
    case 'network-request-failed':
      return 'No internet connection.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    case 'user-disabled':
      return 'This account has been disabled.';
    default:
      return _kGenericError;
  }
}
