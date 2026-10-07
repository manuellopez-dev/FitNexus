import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/wear/providers/wear_session_provider.dart';
import 'features/wear/screens/login_wear_screen.dart';
import 'features/wear/screens/watch_face_screen.dart';
import 'features/wear/screens/ejercicio_screen.dart';
import 'features/wear/screens/bpm_screen.dart';
import 'features/wear/screens/descanso_screen.dart';
import 'features/wear/screens/resumen_screen.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: FitNexusWearApp(),
    ),
  );
}

class FitNexusWearApp extends ConsumerWidget {
  const FitNexusWearApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'FitNexus Wear',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.isLoading
          ? const _SplashWear()
          : authState.valueOrNull == null
              ? const LoginWearScreen()
              : const _WearNavigation(),
    );
  }
}

class _SplashWear extends StatelessWidget {
  const _SplashWear();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0F),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC8F135),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _WearNavigation extends ConsumerStatefulWidget {
  const _WearNavigation();

  @override
  ConsumerState<_WearNavigation> createState() => _WearNavigationState();
}

class _WearNavigationState extends ConsumerState<_WearNavigation> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Escucha la sesión creada desde el móvil o la TV
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wearSessionProvider.notifier).startWatchSession();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(wearSessionProvider, (prev, next) {
      if (next.isComplete && _currentPage != 4) {
        _pageController.animateToPage(4, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else if (next.isResting && _currentPage != 3) {
        _pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else if (next.elapsedSeconds > 0 && _currentPage == 0) {
        _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: GestureDetector(
        onTap: () {},
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: const [
            WatchFaceScreen(),
            EjercicioScreen(),
            BpmScreen(),
            DescansoScreen(),
            ResumenScreen(),
          ],
        ),
      ),
    );
  }
}