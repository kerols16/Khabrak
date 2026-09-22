part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const [];
}

final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Unauthenticated extends AuthState {
  final String? errorMessage;
  const Unauthenticated({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String signInMethod;

  const Authenticated({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.signInMethod,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, signInMethod];
}
