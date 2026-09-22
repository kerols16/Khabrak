import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/core/constants/api_constants.dart';
import 'package:khabark/core/theme/app_theme.dart';
import 'package:khabark/features/auth/cubit/auth_cubit.dart';
import 'package:khabark/features/entry_point/app_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    ApiConstants.apiKey.isNotEmpty,
    'Run with --dart-define-from-file=env.json',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool seen = prefs.getBool('onboarding_seen') ?? false;

  runApp(
    BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(),
      child: MaterialApp(
        title: 'Khabark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AppGate(onboardingSeen: seen),
      ),
    ),
  );
}
