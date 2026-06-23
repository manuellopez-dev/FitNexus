import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String nombre;
  final String email;
  final double pesoObjetivo;
  final int caloriasObjetivo;
  final int diasPorSemana;
  final int diasActivos;
  final DateTime? fechaRegistro;

  UserProfile({
    required this.uid,
    required this.nombre,
    required this.email,
    this.pesoObjetivo = 0,
    this.caloriasObjetivo = 500,
    this.diasPorSemana = 5,
    this.diasActivos = 0,
    this.fechaRegistro,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? 'Usuario',
      email: map['email'] ?? '',
      pesoObjetivo: (map['pesoObjetivo'] ?? 0).toDouble(),
      caloriasObjetivo: map['caloriasObjetivo'] ?? 500,
      diasPorSemana: map['diasPorSemana'] ?? 5,
      diasActivos: map['diasActivos'] ?? 0,
      fechaRegistro: (map['fechaRegistro'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'pesoObjetivo': pesoObjetivo,
      'caloriasObjetivo': caloriasObjetivo,
      'diasPorSemana': diasPorSemana,
      'diasActivos': diasActivos,
      'fechaRegistro': fechaRegistro,
    };
  }
}