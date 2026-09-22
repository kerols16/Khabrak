import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/features/auth/cubit/auth_cubit.dart';
import 'package:khabark/features/auth/presentation/screens/profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();
        return ProfileScreen(
          displayName: state.displayName,
          email: state.email,
          photoUrl: state.photoUrl,
          signInMethod: state.signInMethod,
          onLogout: cubit.signOut,
        );
      },
    );
  }
}
