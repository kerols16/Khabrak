import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;         
  final String? displayName;
  final String? photoUrl;
  final String signInMethod;   

  const AppUser({
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