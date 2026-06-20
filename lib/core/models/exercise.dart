class ExerciseCatalogItem {
  final String id;
  final String nombre;
  final String musculo;
  final String equipo; // 'Peso corporal', 'Mancuerna', 'Barra', 'Máquina', 'Polea'

  ExerciseCatalogItem({
    required this.id,
    required this.nombre,
    required this.musculo,
    required this.equipo,
  });

  factory ExerciseCatalogItem.fromMap(String id, Map<String, dynamic> map) {
    return ExerciseCatalogItem(
      id: id,
      nombre: map['nombre'] ?? '',
      musculo: map['musculo'] ?? '',
      equipo: map['equipo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'musculo': musculo,
      'equipo': equipo,
    };
  }
}

// Ejercicio ya configurado dentro de una rutina del usuario
class RoutineExercise {
  final String ejercicioId;
  final String nombre;
  final String musculo;
  final int series;
  final int reps;
  final int descansoSegundos;

  RoutineExercise({
    required this.ejercicioId,
    required this.nombre,
    required this.musculo,
    required this.series,
    required this.reps,
    required this.descansoSegundos,
  });

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      ejercicioId: map['ejercicioId'] ?? '',
      nombre: map['nombre'] ?? '',
      musculo: map['musculo'] ?? '',
      series: map['series'] ?? 3,
      reps: map['reps'] ?? 12,
      descansoSegundos: map['descansoSegundos'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ejercicioId': ejercicioId,
      'nombre': nombre,
      'musculo': musculo,
      'series': series,
      'reps': reps,
      'descansoSegundos': descansoSegundos,
    };
  }
}