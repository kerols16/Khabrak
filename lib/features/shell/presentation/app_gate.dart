import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/core/api_data_source/dio_client.dart';
import 'package:khabark/core/api_data_source/news_api_service.dart';
import 'package:khabark/features/auth/cubit/auth_cubit.dart';
import 'package:khabark/features/auth/presentation/pages/auth_page.dart';
import 'package:khabark/features/news/cubit/news_cubit.dart';
import 'package:khabark/features/news/data/news_repository.dart';
import 'package:khabark/features/onbourding/presentation/screens/onboarding_screen.dart';
import 'package:khabark/features/shell/presentation/main_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level router: splash → onboarding/auth → MainShell.
///
/// NewsCubit is provided only inside the Authenticated branch, so logout
/// disposes it and the next login starts a fresh cubit + first page.
class AppGate extends StatefulWidget {
  final bool onboardingSeen;

  const AppGate({super.key, required this.onboardingSeen});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  late bool _seen = widget.onboardingSeen;

  Future<void> _markSeen() async {
    setState(() => _seen = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthUnknown) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Authenticated) {
          return BlocProvider<NewsCubit>(
            create: (_) => NewsCubit(
              NewsRepository(NewsApiService(DioClient.create())),
            )..started(),
            child: const MainShell(),
          );
        }

        // Unauthenticated OR AuthLoading → identical widget, so the form
        // keeps its text during an in-flight submission.
        if (!_seen) {
          return OnboardingScreen(onGetStarted: _markSeen);
        }
        return const AuthPage();
      },
    );
  }
}