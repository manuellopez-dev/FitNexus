import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/sync_service.dart';
import '../services/link_service.dart';
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

final linkServiceProvider = Provider<LinkService>((ref) {
  return LinkService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Identidad de dispositivo vinculada (reloj/TV sin login).
class LinkedIdentity {
  final bool loaded;
  final String? uid;

  const LinkedIdentity({this.loaded = false, this.uid});
}

class LinkedIdentityNotifier extends StateNotifier<LinkedIdentity> {
  LinkedIdentityNotifier() : super(const LinkedIdentity()) {
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
      );
      state = LinkedIdentity(loaded: true, uid: prefs.getString('linkedUid'));
    } catch (_) {
      state = const LinkedIdentity(loaded: true, uid: null);
    }
  }

  Future<void> vincular(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('linkedUid', uid);
    state = LinkedIdentity(loaded: true, uid: uid);
  }

  Future<void> desvincular() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('linkedUid');
    state = const LinkedIdentity(loaded: true);
  }
}

final linkedIdentityProvider =
    StateNotifierProvider<LinkedIdentityNotifier, LinkedIdentity>(
  (ref) => LinkedIdentityNotifier(),
);

/// UID efectivo: en el móvil es el de Firebase Auth; en reloj/TV, el vinculado.
final identityProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user != null) return user.uid;
  return ref.watch(linkedIdentityProvider).uid;
});

final perfilProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(identityProvider);
  if (uid == null) return null;
  return ref.read(firestoreServiceProvider).obtenerPerfil(uid);
});

final rutinasProvider = StreamProvider<List<Routine>>((ref) {
  final uid = ref.watch(identityProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerRutinas(uid);
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
  final uid = ref.watch(identityProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerHistorial(uid);
});

final historialSemanalProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = ref.watch(identityProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).obtenerHistorialSemanal(uid);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

final activeSessionIdProvider = StateProvider<String?>((ref) => null);

// Sesión creada por el watch / TV esperando que el móvil la adopte
final sessionRequestProvider = StreamProvider<String?>((ref) {
  final uid = ref.watch(identityProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(syncServiceProvider).buscarSesionSolicitada(uid);
});

final dispositivosProvider =
    StreamProvider.family<List<LinkedDevice>, String>((ref, uid) {
  return ref.watch(linkServiceProvider).listarDispositivos(uid);
});