import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/smart_tv/screens/link_tv_screen.dart';
import 'features/smart_tv/screens/main_tv_screen.dart';
import 'features/smart_tv/screens/active_session_tv_screen.dart';
import 'features/smart_tv/screens/stats_tv_screen.dart';
import 'features/smart_tv/screens/rest_tv_screen.dart';
import 'features/wear/providers/wear_session_provider.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (_) {}
  runApp(
    const ProviderScope(
      child: FitNexusTvApp(),
    ),
  );
}

class FitNexusTvApp extends ConsumerWidget {
  const FitNexusTvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linked = ref.watch(linkedIdentityProvider);

    return MaterialApp(
      title: 'FitNexus TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: !linked.loaded
          ? const _SplashTv()
          : linked.uid == null
              ? const LinkTvScreen()
              : const _TvHome(),
      routes: {
        '/tv': (context) => const MainTvScreen(),
        '/tv/session': (context) => const ActiveSessionTvScreen(),
        '/tv/stats': (context) => const StatsTvScreen(),
        '/tv/rest': (context) => const RestTvScreen(),
      },
    );
  }
}

class _SplashTv extends StatelessWidget {
  const _SplashTv();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0F),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC8F135),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _ForceLinkTv extends StatelessWidget {
  const _ForceLinkTv();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashTv();
        }
        return const LinkTvScreen();
      },
    );
  }
}

class _TvHome extends ConsumerStatefulWidget {
  const _TvHome();

  @override
  ConsumerState<_TvHome> createState() => _TvHomeState();
}

class _TvHomeState extends ConsumerState<_TvHome> {
  @override
  void initState() {
    super.initState();
    // Escucha la sesión creada desde el móvil o desde el reloj
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wearSessionProvider.notifier).startWatchSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainTvScreen();
  }
}
