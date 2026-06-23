import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import '../data/exercise_gif_mapping.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final perfilProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(firestoreServiceProvider).obtenerPerfil(user.uid);
});

final rutinasProvider = StreamProvider<List<Routine>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerRutinas(user.uid);
});

final catalogoProvider = FutureProvider<List<ExerciseCatalogItem>>((ref) async {
  final service = ref.read(firestoreServiceProvider);
  await service.sembrarCatalogoEjercicios();
  final catalogo = await service.obtenerCatalogoEjercicios();
  return catalogo.map((e) {
    final gif = e.gifUrl;
    if (gif.contains('workoutxapp') || gif.isEmpty) {
      final mapped = exerciseGifMapping[e.nombre];
      if (mapped != null && mapped.isNotEmpty) {
        return ExerciseCatalogItem(
          id: e.id,
          nombre: e.nombre,
          musculo: e.musculo,
          equipo: e.equipo,
          gifUrl: mapped,
        );
      }
    }
    return e;
  }).toList();
});

final historialProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerHistorial(user.uid);
});

final historialSemanalProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerHistorialSemanal(user.uid);
});