import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/smart_tv/screens/main_tv_screen.dart';

@pragma('vm:entry-point')
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MainTvScreen(),
    );
  }
}
