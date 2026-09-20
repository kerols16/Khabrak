import 'package:flutter/material.dart';
import 'package:khabark/features/news/presentation/screens/profile_screen.dart';

/// Temporary stub.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      email: 'you@example.com',
      signInMethod: 'Email',
      onLogout: () {},
    );
  }
}