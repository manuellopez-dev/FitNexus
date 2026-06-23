import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/routines/screens/exercise_selection_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../core/models/routine.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplashPage = location == '/splash';

      // Mientras carga el estado de auth, solo mostrar splash
      if (authState.isLoading) return isSplashPage ? null : '/splash';

      final isLoggedIn = authState.valueOrNull != null;

      if (isLoggedIn && (location == '/login' || isSplashPage)) return '/home';
      if (!isLoggedIn && !isSplashPage && location != '/login') return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/workout',
        builder: (context, state) {
          final routine = state.extra as Routine?;
          return WorkoutScreen(routine: routine);
        },
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/settings/:section',
        builder: (context, state) {
          final section = state.pathParameters['section'] ?? 'notificaciones';
          return SettingsScreen(section: section);
        },
      ),
      GoRoute(
        path: '/exercise-selection',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Routine) {
            return ExerciseSelectionScreen(
              routineName: extra.nombre,
              routineType: extra.tipo,
              existingRoutine: extra,
            );
          }
          String name;
          String type;
          if (extra is Map<String, dynamic>) {
            name = extra['name'] as String? ?? 'Rutina';
            type = extra['type'] as String? ?? 'Fuerza';
          } else {
            name = extra as String? ?? 'Rutina';
            type = 'Fuerza';
          }
          return ExerciseSelectionScreen(routineName: name, routineType: type);
        },
      ),
    ],
  );
});