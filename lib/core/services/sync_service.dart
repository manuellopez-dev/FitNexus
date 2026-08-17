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

  Future<void> finalizarSesion(String sessionId) async {
    await _db.child('sesiones_activas/$sessionId').update({
      'estado': 'finalizada',
    });
  }

  Future<void> eliminarSesion(String sessionId) async {
    await _db.child('sesiones_activas/$sessionId').remove();
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
      return data.keys.first;
    });
  }
}
