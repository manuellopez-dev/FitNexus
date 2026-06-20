import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/routine.dart';
import '../models/exercise.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final perfilProvider = FutureProvider((ref) async {
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
  return ref.read(firestoreServiceProvider).obtenerCatalogoEjercicios();
});

final historialProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerHistorial(user.uid);
});