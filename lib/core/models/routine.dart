import 'exercise.dart';

class Routine {
  final String id;
  final String nombre;
  final String tipo;
  final List<RoutineExercise> ejercicios;

  Routine({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.ejercicios,
  });

  int get totalEjercicios => ejercicios.length;

  int get duracionEstimadaMinutos {
    // Estimación: (series * (30 seg trabajo + descanso)) por ejercicio
    int totalSegundos = 0;
    for (final e in ejercicios) {
      totalSegundos += e.series * (30 + e.descansoSegundos);
    }
    return (totalSegundos / 60).ceil();
  }

  factory Routine.fromMap(String id, Map<String, dynamic> map) {
    return Routine(
      id: id,
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? 'Fuerza',
      ejercicios: (map['ejercicios'] as List<dynamic>? ?? [])
          .map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
    };
  }
}