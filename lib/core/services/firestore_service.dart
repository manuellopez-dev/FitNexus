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

  Future<Routine?> obtenerRutina(String uid, String rutinaId) async {
    if (rutinaId.isEmpty) return null;
    final doc = await _db
        .collection('usuarios')
        .doc(uid)
        .collection('rutinas')
        .doc(rutinaId)
        .get();
    if (!doc.exists) return null;
    return Routine.fromMap(doc.id, doc.data() ?? {});
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

  // ---------- CATÁLOGO DE EJERCICIOS ----------

  Future<void> sembrarCatalogoEjercicios() async {
  final ref = _db.collection('catalogo_ejercicios');

  // Obtener ejercicios que ya existen en Firestore
  final existentes = await ref.get();

  // Mapa: nombre del ejercicio -> documento de Firestore
  final documentosExistentes = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

  for (final doc in existentes.docs) {
    final nombre = doc.data()['nombre']?.toString();

    if (nombre != null && nombre.isNotEmpty) {
      documentosExistentes[nombre] = doc;
    }
  }

  final batch = _db.batch();

  int agregados = 0;
  int actualizados = 0;

  for (final item in exerciseCatalogSeed) {
    final nombre = item['nombre']?.toString() ?? '';

    if (nombre.isEmpty) {
      continue;
    }

    final gifUrl = exerciseGifMapping[nombre] ?? '';

    // ¿Ya existe este ejercicio?
    final documentoExistente = documentosExistentes[nombre];

    if (documentoExistente != null) {
      // Actualizar GIF si existe uno diferente
      final gifActual =
          documentoExistente.data()['gifUrl']?.toString() ?? '';

      if (gifUrl.isNotEmpty && gifActual != gifUrl) {
        batch.update(
          documentoExistente.reference,
          {
            'gifUrl': gifUrl,
          },
        );

        actualizados++;
      }
    } else {
      // Crear ejercicio faltante
      final nuevoDocumento = ref.doc();

      batch.set(
        nuevoDocumento,
        {
          ...item,
          'gifUrl': gifUrl,
        },
      );

      agregados++;
    }
  }

  // Ejecutar todas las operaciones
  if (agregados > 0 || actualizados > 0) {
    await batch.commit();
  }

  print('========================================');
  print('CATÁLOGO DE EJERCICIOS');
  print('Ejercicios existentes: ${existentes.docs.length}');
  print('Ejercicios agregados: $agregados');
  print('GIFs actualizados: $actualizados');
  print('========================================');
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

  // ---------------- Guardar imagen en FireStore en Base64 ------------------------
  Future<void> actualizarFotoPerfil(String uid, String base64Image) async {
    await _db.collection('usuarios').doc(uid).update({
      'fotoBase64': base64Image,
    });
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