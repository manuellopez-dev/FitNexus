import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import '../data/exercise_catalog_seed.dart';
import '../data/exercise_gif_mapping.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- PERFIL ----------

  Future<void> crearPerfil(User user, String nombre) async {
    await _db.collection('usuarios').doc(user.uid).set({
      'uid': user.uid,
      'nombre': nombre,
      'email': user.email,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'diasActivos': 0,
      'pesoObjetivo': 0,
      'caloriasObjetivo': 500,
      'diasPorSemana': 5,
    });
  }

  Future<UserProfile?> obtenerPerfil(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data() ?? {});
  }

  Future<void> actualizarPerfil(String uid, Map<String, dynamic> datos) async {
    await _db.collection('usuarios').doc(uid).update(datos);
  }

  // ---------- RUTINAS ----------

  Stream<List<Routine>> obtenerRutinas(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Routine.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> crearRutina(String uid, Routine rutina) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .add(rutina.toMap());
  }

  Future<void> actualizarRutina(
      String uid, String rutinaId, Map<String, dynamic> datos) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .doc(rutinaId)
        .update(datos);
  }

  Future<void> eliminarRutina(String uid, String rutinaId) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .doc(rutinaId)
        .delete();
  }

  // Crea las rutinas iniciales solo si el usuario no tiene ninguna
  Future<void> sembrarRutinasIniciales(String uid) async {
    final rutinasRef = _db.collection('usuarios').doc(uid).collection('rutinas');
    final existentes = await rutinasRef.limit(1).get();
    if (existentes.docs.isNotEmpty) return; // ya tiene rutinas, no sembrar

    final rutinasBase = [
      Routine(
        id: '',
        nombre: 'Pecho + Tríceps',
        tipo: 'Fuerza',
        ejercicios: [],
      ),
      Routine(
        id: '',
        nombre: 'Piernas + Glúteos',
        tipo: 'Fuerza',
        ejercicios: [],
      ),
      Routine(
        id: '',
        nombre: 'Espalda + Bíceps',
        tipo: 'Fuerza',
        ejercicios: [],
      ),
      Routine(
        id: '',
        nombre: 'HIIT Cardio',
        tipo: 'Cardio',
        ejercicios: [],
      ),
    ];

    for (final rutina in rutinasBase) {
      await rutinasRef.add(rutina.toMap());
    }
  }

  // ---------- CATÁLOGO DE EJERCICIOS ----------

  Future<void> sembrarCatalogoEjercicios() async {
    final ref = _db.collection('catalogo_ejercicios');
    final existentes = await ref.get();

    if (existentes.docs.isEmpty) {
      for (final item in exerciseCatalogSeed) {
        final gifUrl = exerciseGifMapping[item['nombre']] ?? '';
        await ref.add({...item, 'gifUrl': gifUrl});
      }
      return;
    }

    final batch = _db.batch();
    for (final doc in existentes.docs) {
      final data = doc.data();
      final currentGif = data['gifUrl'] as String? ?? '';
      final mappedGif = exerciseGifMapping[data['nombre']] ?? '';
      if (mappedGif.isNotEmpty && currentGif != mappedGif) {
        batch.update(doc.reference, {'gifUrl': mappedGif});
      }
    }
    await batch.commit();
  }

  Future<List<ExerciseCatalogItem>> obtenerCatalogoEjercicios() async {
    final snapshot = await _db.collection('catalogo_ejercicios').get();
    return snapshot.docs
        .map((doc) => ExerciseCatalogItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ---------- HISTORIAL DE WORKOUTS ----------

  Future<void> guardarWorkoutCompletado({
    required String uid,
    required String nombreRutina,
    required int duracionMinutos,
    required int ejerciciosCompletados,
  }) async {
    final batch = _db.batch();
    final historialRef = _db
        .collection('usuarios')
        .doc(uid)
        .collection('historial')
        .doc();
    batch.set(historialRef, {
      'nombreRutina': nombreRutina,
      'duracionMinutos': duracionMinutos,
      'ejerciciosCompletados': ejerciciosCompletados,
      'fecha': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('usuarios').doc(uid), {
      'diasActivos': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> obtenerHistorial(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('historial')
        .orderBy('fecha', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> obtenerHistorialSemanal(String uid) {
    final ahora = DateTime.now();
    final inicioSemana = DateTime(ahora.year, ahora.month, ahora.day - ahora.weekday + 1);
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('historial')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioSemana))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}