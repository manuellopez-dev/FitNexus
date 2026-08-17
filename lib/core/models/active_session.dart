class ActiveSession {
  final String id;
  final String hostUid;
  final String rutinaNombre;
  final String estado;
  final ExerciseState? ejercicioActual;
  final ProgressState progreso;
  final RestState descanso;
  final int bpm;
  final int timestamp;

  ActiveSession({
    required this.id,
    required this.hostUid,
    required this.rutinaNombre,
    required this.estado,
    this.ejercicioActual,
    required this.progreso,
    required this.descanso,
    required this.bpm,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'hostUid': hostUid,
      'rutinaNombre': rutinaNombre,
      'estado': estado,
      'ejercicioActual': ejercicioActual?.toMap(),
      'progreso': progreso.toMap(),
      'descanso': descanso.toMap(),
      'bpm': bpm,
      'timestamp': timestamp,
    };
  }

  factory ActiveSession.fromMap(String id, Map<String, dynamic> map) {
    return ActiveSession(
      id: id,
      hostUid: map['hostUid'] ?? '',
      rutinaNombre: map['rutinaNombre'] ?? '',
      estado: map['estado'] ?? 'iniciada',
      ejercicioActual: map['ejercicioActual'] != null
          ? ExerciseState.fromMap(Map<String, dynamic>.from(map['ejercicioActual']))
          : null,
      progreso: ProgressState.fromMap(Map<String, dynamic>.from(map['progreso'] ?? {})),
      descanso: RestState.fromMap(Map<String, dynamic>.from(map['descanso'] ?? {})),
      bpm: map['bpm'] ?? 72,
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

class ExerciseState {
  final String nombre;
  final String musculo;
  final String gifUrl;
  final int serieActual;
  final int totalSeries;
  final int reps;
  final int descansoSegundos;

  ExerciseState({
    required this.nombre,
    required this.musculo,
    required this.gifUrl,
    required this.serieActual,
    required this.totalSeries,
    required this.reps,
    required this.descansoSegundos,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'musculo': musculo,
      'gifUrl': gifUrl,
      'serieActual': serieActual,
      'totalSeries': totalSeries,
      'reps': reps,
      'descansoSegundos': descansoSegundos,
    };
  }

  factory ExerciseState.fromMap(Map<String, dynamic> map) {
    return ExerciseState(
      nombre: map['nombre'] ?? '',
      musculo: map['musculo'] ?? '',
      gifUrl: map['gifUrl'] ?? '',
      serieActual: map['serieActual'] ?? 1,
      totalSeries: map['totalSeries'] ?? 3,
      reps: map['reps'] ?? 12,
      descansoSegundos: map['descansoSegundos'] ?? 90,
    );
  }
}

class ProgressState {
  final int ejercicioIndex;
  final int totalEjercicios;
  final int segundosTranscurridos;
  final int calorias;

  ProgressState({
    required this.ejercicioIndex,
    required this.totalEjercicios,
    required this.segundosTranscurridos,
    required this.calorias,
  });

  Map<String, dynamic> toMap() {
    return {
      'ejercicioIndex': ejercicioIndex,
      'totalEjercicios': totalEjercicios,
      'segundosTranscurridos': segundosTranscurridos,
      'calorias': calorias,
    };
  }

  factory ProgressState.fromMap(Map<String, dynamic> map) {
    return ProgressState(
      ejercicioIndex: map['ejercicioIndex'] ?? 0,
      totalEjercicios: map['totalEjercicios'] ?? 0,
      segundosTranscurridos: map['segundosTranscurridos'] ?? 0,
      calorias: map['calorias'] ?? 0,
    );
  }
}

class RestState {
  final bool activo;
  final int segundosRestantes;

  RestState({
    required this.activo,
    required this.segundosRestantes,
  });

  Map<String, dynamic> toMap() {
    return {
      'activo': activo,
      'segundosRestantes': segundosRestantes,
    };
  }

  factory RestState.fromMap(Map<String, dynamic> map) {
    return RestState(
      activo: map['activo'] ?? false,
      segundosRestantes: map['segundosRestantes'] ?? 0,
    );
  }
}
