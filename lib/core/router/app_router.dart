import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/routines/screens/exercise_selection_screen.dart';
import '../../core/models/routine.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginPage = state.matchedLocation == '/login';

      // Mientras carga el estado de auth, no redirigir a nada
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/home';
      return null;
    },
    routes: [
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
        path: '/exercise-selection',
        builder: (context, state) {
          final extra = state.extra;
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