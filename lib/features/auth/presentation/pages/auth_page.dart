import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/features/auth/cubit/auth_cubit.dart';
import 'package:khabark/features/auth/presentation/screens/auth_screen.dart';

/// Sole owner of the AuthCubit ↔ AuthScreen wiring.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return AuthScreen(
          isLoading: state is AuthLoading,
          errorMessage:
              state is Unauthenticated ? state.errorMessage : null,
          onSignIn: cubit.signIn,
          onSignUp: cubit.signUp,
          onGoogleSignIn: cubit.signInWithGoogle,
          onForgotPassword: (email) async {
            final err = await cubit.sendPasswordReset(email);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err ?? 'Password reset email sent.'),
              ),
            );
          },
          onModeChanged: cubit.clearError,
        );
      },
    );
  }
}