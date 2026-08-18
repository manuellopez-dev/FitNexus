import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/smart_tv/screens/main_tv_screen.dart';
import 'features/smart_tv/screens/active_session_tv_screen.dart';
import 'features/smart_tv/screens/stats_tv_screen.dart';
import 'features/smart_tv/screens/rest_tv_screen.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: FitNexusTvApp(),
    ),
  );
}

class FitNexusTvApp extends StatelessWidget {
  const FitNexusTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitNexus TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/tv',
      routes: {
        '/tv': (context) => const MainTvScreen(),
        '/tv/session': (context) => const ActiveSessionTvScreen(),
        '/tv/stats': (context) => const StatsTvScreen(),
        '/tv/rest': (context) => const RestTvScreen(),
      },
    );
  }
}
