import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkedDevice {
  final String deviceId;
  final String tipo;
  final String nombre;
  final bool activo;
  final int ultimaConexion;

  LinkedDevice({
    required this.deviceId,
    required this.tipo,
    required this.nombre,
    required this.activo,
    required this.ultimaConexion,
  });

  factory LinkedDevice.fromMap(String deviceId, Map<String, dynamic> map) {
    return LinkedDevice(
      deviceId: deviceId,
      tipo: map['tipo'] ?? 'desconocido',
      nombre: map['nombre'] ?? 'Dispositivo',
      activo: map['activo'] ?? false,
      ultimaConexion: (map['ultimaConexion'] as num?)?.toInt() ?? 0,
    );
  }
}

class LinkService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('deviceId');
    if (id == null) {
      final rnd = Random();
      id = List.generate(8, (_) => _chars[rnd.nextInt(_chars.length)]).join();
      await prefs.setString('deviceId', id);
    }
    return id;
  }

  Future<String> _generarCodigo() async {
    final rnd = Random();
    for (var i = 0; i < 12; i++) {
      final code = List.generate(6, (_) => _chars[rnd.nextInt(_chars.length)]).join();
      final snap = await _db.child('vinculacion/$code').get();
      if (!snap.exists) return code;
    }
    throw Exception('No se pudo generar un código');
  }

  /// Reloj/TV: genera un código y lo publica a la espera de que el móvil lo ingrese.
  Future<String> crearVinculacion(String tipo, String nombre) async {
    final code = await _generarCodigo();
    final deviceId = await _deviceId();
    await _db.child('vinculacion/$code').set({
      'deviceId': deviceId,
      'tipo': tipo,
      'nombre': nombre,
      'estado': 'esperando',
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    return code;
  }

  /// Reloj/TV: escucha hasta que el móvil vincule el código.
  Stream<String?> escucharVinculacion(String codigo) {
    return _db.child('vinculacion/$codigo').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (map['estado'] == 'vinculado') return map['uid'] as String?;
      return null;
    });
  }

  /// Móvil: vincula el código mostrado por el reloj/TV a la cuenta.
  Future<String> vincular(String codigo, String uid) async {
    final code = codigo.trim().toUpperCase();
    final snap = await _db.child('vinculacion/$code').get();
    if (!snap.exists) throw Exception('Código no válido');
    final map = Map<String, dynamic>.from(snap.value as Map);
    if (map['estado'] == 'vinculado' && map['uid'] != uid) {
      throw Exception('Ese código ya fue vinculado');
    }
    final deviceId = map['deviceId'] as String? ?? code;
    await _db.child('vinculacion/$code').update({
      'estado': 'vinculado',
      'uid': uid,
    });
    await _db.child('dispositivos/$uid/$deviceId').update({
      'tipo': map['tipo'] ?? 'desconocido',
      'nombre': map['nombre'] ?? 'Dispositivo',
      'activo': true,
      'ultimaConexion': ServerValue.timestamp,
    });
    return deviceId;
  }

  Stream<List<LinkedDevice>> listarDispositivos(String uid) {
    return _db.child('dispositivos/$uid').onValue.map((event) {
      if (event.snapshot.value == null) return <LinkedDevice>[];
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      final dispositivos = map.entries
          .map((e) =>
              LinkedDevice.fromMap(e.key, Map<String, dynamic>.from(e.value as Map)))
          .toList();
      dispositivos.sort((a, b) => b.ultimaConexion.compareTo(a.ultimaConexion));
      return dispositivos;
    });
  }

  Future<void> desvincular(String uid, String deviceId) async {
    await _db.child('dispositivos/$uid/$deviceId').remove();
  }

  /// Marca el dispositivo como activo y programa su desconexión automática.
  Future<void> iniciarPresencia(String uid, String tipo, String nombre) async {
    final deviceId = await _deviceId();
    final ref = _db.child('dispositivos/$uid/$deviceId');
    await ref.update({
      'tipo': tipo,
      'nombre': nombre,
      'activo': true,
      'ultimaConexion': ServerValue.timestamp,
    });
    await ref.onDisconnect().update({
      'activo': false,
      'ultimaConexion': ServerValue.timestamp,
    });
  }
}