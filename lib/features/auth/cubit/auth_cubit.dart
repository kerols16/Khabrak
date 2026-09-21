import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

const String _kGenericError = 'Something went wrong. Please try again.';
const String _kServerClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

// TEMP
const bool _kShowDebugErrorsOnScreen = true;

// TEMP
void _log(String message) {
  if (kDebugMode) debugPrint('[AUTH] $message');
}

// TEMP — extract the part after '@' for logging (never log the full email).
String _domain(String email) {
  final at = email.indexOf('@');
  if (at < 0 || at >= email.length - 1) return '';
  return email.substring(at + 1);
}

// TEMP — first 6 chars of a uid, for logging.
String _uidPrefix(String uid) =>
    uid.length <= 6 ? uid : uid.substring(0, 6);

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(const AuthUnknown()) {
    _log('cubit created'); // TEMP
    // Single source of truth: every successful sign-in flows through here.
    _sub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;
  Future<void>? _googleInit; // one-time lazy initialize()

  @override
  void onChange(Change<AuthState> change) {
    _log('state ${change.currentState.runtimeType} -> '
        '${change.nextState.runtimeType}'); // TEMP
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _log('cubit error ${error.runtimeType}: $error'); // TEMP
    super.onError(error, stackTrace);
  }

  void _onAuthChanged(User? user) {
    if (user == null) {
      _log('authStateChanges -> null'); // TEMP
      emit(const Unauthenticated());
    } else {
      final providers =
          user.providerData.map((p) => p.providerId).join(',');
      _log('authStateChanges -> user uid=${_uidPrefix(user.uid)} '
          'providers=$providers'); // TEMP
      emit(_fromUser(user));
    }
  }

  Authenticated _fromUser(User user) {
    final isGoogle =
        user.providerData.any((p) => p.providerId == 'google.com');
    return Authenticated(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      signInMethod: isGoogle ? 'Google' : 'Email',
    );
  }

  Future<void> signIn(String email, String password) async {
    _log('signIn start domain=${_domain(email)}'); // TEMP
    emit(const AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _log('signIn ok'); // TEMP
      // Success: the authStateChanges listener emits Authenticated.
    } on FirebaseAuthException catch (e) {
      _log('signIn FirebaseAuthException code=${e.code} '
          'message=${e.message}'); // TEMP
      emit(Unauthenticated(errorMessage: _messageFor(e)));
    } catch (e) {
      _log('signIn OTHER type=${e.runtimeType} $e'); // TEMP
      emit(const Unauthenticated(errorMessage: _kGenericError));
    }
  }

  Future<void> signUp(String email, String password) async {
    _log('signUp start domain=${_domain(email)}'); // TEMP
    emit(const AuthLoading());
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _log('signUp ok'); // TEMP
      // Success: the authStateChanges listener emits Authenticated.
    } on FirebaseAuthException catch (e) {
      _log('signUp FirebaseAuthException code=${e.code} '
          'message=${e.message}'); // TEMP
      emit(Unauthenticated(errorMessage: _messageFor(e)));
    } catch (e) {
      _log('signUp OTHER type=${e.runtimeType} $e'); // TEMP
      emit(const Unauthenticated(errorMessage: _kGenericError));
    }
  }

  Future<void> signInWithGoogle() async {
    String step = 'init'; // TEMP
    _log('google: tapped'); // TEMP
    _log('google: serverClientId set=${_kServerClientId.isNotEmpty}'); // TEMP

    emit(const AuthLoading());
    try {
      // -- Step: initialize -----------------------------------------------
      step = 'init'; // TEMP
      _log('google: initialize begin'); // TEMP
      try {
        await _ensureGoogleInitialized();
        _log('google: initialize done'); // TEMP
      } catch (e) {
        _log('google: initialize FAILED ${e.runtimeType} $e'); // TEMP
        rethrow;
      }

      // -- Step: authenticate ---------------------------------------------
      step = 'authenticate'; // TEMP
      _log('google: authenticate begin'); // TEMP
      final account = await GoogleSignIn.instance.authenticate();
      _log('google: authenticate done account=non-null'); // TEMP

      // -- Step: token ----------------------------------------------------
      step = 'token'; // TEMP
      final idToken = account.authentication.idToken;
      _log('google: idToken null=${idToken == null} '
          'length=${idToken?.length ?? 0}'); // TEMP
      if (idToken == null) {
        emit(Unauthenticated(
          errorMessage: _kShowDebugErrorsOnScreen
              ? 'G:$step FirebaseAuth idToken=null'
              : _kGenericError,
        )); // TEMP
        return;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // -- Step: firebase -------------------------------------------------
      step = 'firebase'; // TEMP
      _log('google: signInWithCredential begin'); // TEMP
      final uc = await _auth.signInWithCredential(credential);
      final uid6 = uc.user != null ? _uidPrefix(uc.user!.uid) : 'null';
      _log('google: signInWithCredential done uid=$uid6'); // TEMP
      // Success: the authStateChanges listener emits Authenticated.
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _log('google: CANCELED code=${e.code} '
            'description=${e.description}'); // TEMP
        // User dismissed the picker — not an error.
        emit(const Unauthenticated());
      } else {
        _log('google: GoogleSignInException code=${e.code} '
            'description=${e.description}'); // TEMP
        emit(Unauthenticated(
          errorMessage: _kShowDebugErrorsOnScreen
              ? 'G:$step GoogleSignInException ${e.code} ${e.description}'
              : _kGenericError,
        )); // TEMP
      }
    } on FirebaseAuthException catch (e) {
      _log('google: FirebaseAuthException code=${e.code} '
          'message=${e.message}'); // TEMP
      emit(Unauthenticated(
        errorMessage: _kShowDebugErrorsOnScreen
            ? 'G:$step FirebaseAuthException ${e.code} ${e.message}'
            : _messageFor(e),
      )); // TEMP
    } catch (e, st) {
      _log('google: OTHER type=${e.runtimeType} $e'); // TEMP
      _log('google: STACKTRACE $st'); // TEMP
      emit(Unauthenticated(
        errorMessage: _kShowDebugErrorsOnScreen
            ? 'G:$step ${e.runtimeType} $e'
            : _kGenericError,
      )); // TEMP
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= GoogleSignIn.instance.initialize(
      serverClientId: _kServerClientId.isEmpty ? null : _kServerClientId,
    );
  }

  /// Returns null on success, or a user-facing error message.
  /// Does not emit any state.
  Future<String?> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    _log('reset start domain=${_domain(trimmed)}'); // TEMP
    if (trimmed.isEmpty) {
      _log('reset result empty-email'); // TEMP
      return 'Enter your email first.';
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
      _log('reset result ok'); // TEMP
      return null;
    } on FirebaseAuthException catch (e) {
      _log('reset result code=${e.code}'); // TEMP
      if (e.code == 'user-not-found') {
        return 'No account found for this email.';
      }
      return _messageFor(e);
    } catch (e) {
      _log('reset result OTHER type=${e.runtimeType}'); // TEMP
      return _kGenericError;
    }
  }

  Future<void> signOut() async {
    _log('signOut start'); // TEMP
    try {
      await _ensureGoogleInitialized();
      _log('google init done'); // TEMP
      await GoogleSignIn.instance.signOut();
      _log('google signOut done'); // TEMP
    } catch (e) {
      _log('google signOut ignored error ${e.runtimeType} $e'); // TEMP
    }
    await _auth.signOut();
    _log('firebase signOut done'); // TEMP
  }

  /// Clears a lingering error message without touching the auth state.
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