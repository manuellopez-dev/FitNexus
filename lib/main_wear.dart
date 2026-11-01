import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/wear/providers/wear_session_provider.dart';
import 'features/wear/screens/link_wear_screen.dart';
import 'features/wear/screens/watch_face_screen.dart';
import 'features/wear/screens/ejercicio_screen.dart';
import 'features/wear/screens/bpm_screen.dart';
import 'features/wear/screens/descanso_screen.dart';
import 'features/wear/screens/resumen_screen.dart';

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
      child: FitNexusWearApp(),
    ),
  );
}

class FitNexusWearApp extends ConsumerWidget {
  const FitNexusWearApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linked = ref.watch(linkedIdentityProvider);

    return MaterialApp(
      title: 'FitNexus Wear',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: !linked.loaded
          ? const _SplashWear()
          : linked.uid == null
              ? const LinkWearScreen()
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

class _ForceLinkWear extends StatelessWidget {
  const _ForceLinkWear();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashWear();
        }
        return const LinkWearScreen();
      },
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
      if (!mounted) return;
      if (next.isComplete && _currentPage != 4) {
        _pageController.animateToPage(4, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
      } else if (next.isResting && !next.isComplete && _currentPage != 3) {
        _pageController.animateToPage(3, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
      } else if (next.currentExercise != null && !next.isResting && !next.isComplete && _currentPage == 0) {
        _pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        pageSnapping: true,
        onPageChanged: (i) {
          if (mounted) setState(() => _currentPage = i);
        },
        children: const [
          WatchFaceScreen(),
          EjercicioScreen(),
          BpmScreen(),
          DescansoScreen(),
          ResumenScreen(),
        ],
      ),
    );
  }
}