part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const [];
}

/// Before Firebase answers.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// No signed-in user. [errorMessage] is set only for actionable errors.
final class Unauthenticated extends AuthState {
  final String? errorMessage;
  const Unauthenticated({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Sign in / sign up / Google flow in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Signed-in user. Never carries the FirebaseAuth User object itself.
final class Authenticated extends AuthState {
  final String uid;
  final String email; // '' if Firebase has no email on this provider
  final String? displayName;
  final String? photoUrl;
  final String signInMethod; // 'Google' | 'Email'

  const Authenticated({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.signInMethod,
  });

  @override
  List<Object?> get props =>
      [uid, email, displayName, photoUrl, signInMethod];
}