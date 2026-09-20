import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/core/api_data_source/dio_client.dart';
import 'package:khabark/core/api_data_source/news_api_service.dart';
import 'package:khabark/core/constants/api_constants.dart';
import 'package:khabark/core/theme/app_theme.dart';
import 'package:khabark/features/news/cubit/news_cubit.dart';
import 'package:khabark/features/news/data/news_repository.dart';
import 'package:khabark/features/shell/presentation/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(
    ApiConstants.apiKey.isNotEmpty,
    'Run with --dart-define-from-file=env.json',
  );

  // Firebase initialization — remove the try/catch if a proper
  // FirebaseOptions is configured.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // No Firebase config present; skip silently for local runs.
  }

  runApp(const KhabarkApp());
}

class KhabarkApp extends StatelessWidget {
  const KhabarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khabark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocProvider<NewsCubit>(
        create: (_) => NewsCubit(
          NewsRepository(NewsApiService(DioClient.create())),
        )..started(),
        child:  const MainShell(),
      ),
    );
  }
}