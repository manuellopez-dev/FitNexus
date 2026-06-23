class ExerciseCatalogItem {
  final String id;
  final String nombre;
  final String musculo;
  final String equipo; // 'Peso corporal', 'Mancuerna', 'Barra', 'Máquina', 'Polea'
  final String gifUrl;

  ExerciseCatalogItem({
    required this.id,
    required this.nombre,
    required this.musculo,
    required this.equipo,
    this.gifUrl = '',
  });

  factory ExerciseCatalogItem.fromMap(String id, Map<String, dynamic> map) {
    return ExerciseCatalogItem(
      id: id,
      nombre: map['nombre'] ?? '',
      musculo: map['musculo'] ?? '',
      equipo: map['equipo'] ?? '',
      gifUrl: map['gifUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'musculo': musculo,
      'equipo': equipo,
      'gifUrl': gifUrl,
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
  final String gifUrl;

  RoutineExercise({
    required this.ejercicioId,
    required this.nombre,
    required this.musculo,
    required this.series,
    required this.reps,
    required this.descansoSegundos,
    this.gifUrl = '',
  });

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      ejercicioId: map['ejercicioId'] ?? '',
      nombre: map['nombre'] ?? '',
      musculo: map['musculo'] ?? '',
      series: map['series'] ?? 3,
      reps: map['reps'] ?? 12,
      descansoSegundos: map['descansoSegundos'] ?? 60,
      gifUrl: map['gifUrl'] ?? '',
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
      'gifUrl': gifUrl,
    };
  }
}