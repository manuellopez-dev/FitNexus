import 'package:firebase_database/firebase_database.dart';
import '../models/active_session.dart';

class SyncService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<String> crearSesion(ActiveSession session) async {
    final ref = _db.child('sesiones_activas').push();
    await ref.set(session.toMap());
    return ref.key!;
  }

  Future<void> actualizarSesion(String sessionId, Map<String, dynamic> data) async {
    await _db.child('sesiones_activas/$sessionId').update(data);
  }

  Future<void> activarSesion(String sessionId) async {
    await _db.child('sesiones_activas/$sessionId').update({
      'estado': 'activa',
    });
  }

  Future<void> finalizarSesion(String sessionId) async {
    await _db.child('sesiones_activas/$sessionId').update({
      'estado': 'finalizada',
    });
  }

  Future<void> eliminarSesion(String sessionId) async {
    await _db.child('sesiones_activas/$sessionId').remove();
  }

  Future<void> enviarComando(String sessionId, String accion, String origen) async {
    await _db.child('sesiones_activas/$sessionId').update({
      'comando': {
        'accion': accion,
        'origen': origen,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    });
  }

  Future<void> limpiarComando(String sessionId) async {
    await _db.child('sesiones_activas/$sessionId').child('comando').remove();
  }

  Future<ActiveSession?> obtenerSesion(String sessionId) async {
    final snapshot = await _db.child('sesiones_activas/$sessionId').get();
    if (snapshot.value == null) return null;
    return ActiveSession.fromMap(
      sessionId,
      Map<String, dynamic>.from(snapshot.value as Map),
    );
  }

  // Limpia sesiones finalizadas que quedaron huérfanas de este usuario
  Future<void> limpiarSesionesAnteriores(String uid) async {
    final snapshot = await _db
        .child('sesiones_activas')
        .orderByChild('hostUid')
        .equalTo(uid)
        .get();
    if (snapshot.value == null) return;
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    for (final entry in data.entries) {
      final sesion = Map<String, dynamic>.from(entry.value as Map);
      if (sesion['estado'] == 'finalizada') {
        await _db.child('sesiones_activas/${entry.key}').remove();
      }
    }
  }

  Stream<ActiveSession?> escucharSesion(String sessionId) {
    return _db
        .child('sesiones_activas/$sessionId')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;
      return ActiveSession.fromMap(
        sessionId,
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }

  Stream<String?> buscarSesionActiva(String uid) {
    return _db
        .child('sesiones_activas')
        .orderByChild('hostUid')
        .equalTo(uid)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      for (final entry in data.entries) {
        final sesion = Map<String, dynamic>.from(entry.value as Map);
        if (sesion['estado'] == 'activa') return entry.key;
      }
      return null;
    });
  }

  // Sesiones creadas por el watch / TV esperando que el móvil las adopte
  Stream<String?> buscarSesionSolicitada(String uid) {
    return _db
        .child('sesiones_activas')
        .orderByChild('hostUid')
        .equalTo(uid)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      for (final entry in data.entries) {
        final sesion = Map<String, dynamic>.from(entry.value as Map);
        if (sesion['estado'] == 'solicitada') return entry.key;
      }
      return null;
    });
  }
}
