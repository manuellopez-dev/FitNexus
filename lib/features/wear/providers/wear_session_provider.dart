import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/routine.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/active_session.dart';
import '../../../core/providers/auth_provider.dart';

class WearSessionState {
  final RoutineExercise? currentExercise;
  final int currentExerciseIndex;
  final int totalExercises;
  final int currentSet;
  final int totalSets;
  final int elapsedSeconds;
  final int restSeconds;
  final bool isResting;
  final bool isComplete;
  final bool isWaiting;
  final int heartRateBpm;
  final int calories;

  WearSessionState({
    this.currentExercise,
    this.currentExerciseIndex = 0,
    this.totalExercises = 0,
    this.currentSet = 1,
    this.totalSets = 3,
    this.elapsedSeconds = 0,
    this.restSeconds = 0,
    this.isResting = false,
    this.isComplete = false,
    this.isWaiting = false,
    this.heartRateBpm = 72,
    this.calories = 0,
  });

  WearSessionState copyWith({
    RoutineExercise? currentExercise,
    int? currentExerciseIndex,
    int? totalExercises,
    int? currentSet,
    int? totalSets,
    int? elapsedSeconds,
    int? restSeconds,
    bool? isResting,
    bool? isComplete,
    bool? isWaiting,
    int? heartRateBpm,
    int? calories,
  }) {
    return WearSessionState(
      currentExercise: currentExercise ?? this.currentExercise,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      totalExercises: totalExercises ?? this.totalExercises,
      currentSet: currentSet ?? this.currentSet,
      totalSets: totalSets ?? this.totalSets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      isResting: isResting ?? this.isResting,
      isComplete: isComplete ?? this.isComplete,
      isWaiting: isWaiting ?? this.isWaiting,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      calories: calories ?? this.calories,
    );
  }
}

class WearSessionNotifier extends Notifier<WearSessionState> {
  StreamSubscription? _idSubscription;
  StreamSubscription? _sessionSubscription;
  String? _sessionId;

  @override
  WearSessionState build() {
    ref.onDispose(() {
      _idSubscription?.cancel();
      _sessionSubscription?.cancel();
    });
    return WearSessionState();
  }

  /// Sigue la sesión activa del usuario (creada por el móvil o la TV)
  void startWatchSession() {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    _idSubscription?.cancel();
    _idSubscription = ref
        .read(syncServiceProvider)
        .buscarSesionActiva(user.uid)
        .listen((sessionId) {
      if (sessionId == _sessionId) return;
      _sessionSubscription?.cancel();
      _sessionId = sessionId;

      if (sessionId == null) {
        state = WearSessionState();
        return;
      }

      _sessionSubscription = ref
          .read(syncServiceProvider)
          .escucharSesion(sessionId)
          .listen((session) {
        if (session == null) return;
        _updateFromSession(session);
      });
    });
  }

  void _updateFromSession(ActiveSession session) {
    state = WearSessionState(
      currentExercise: session.ejercicioActual != null
          ? RoutineExercise(
              ejercicioId: '',
              nombre: session.ejercicioActual!.nombre,
              musculo: session.ejercicioActual!.musculo,
              series: session.ejercicioActual!.totalSeries,
              reps: session.ejercicioActual!.reps,
              descansoSegundos: session.ejercicioActual!.descansoSegundos,
              gifUrl: session.ejercicioActual!.gifUrl,
            )
          : null,
      currentExerciseIndex: session.progreso.ejercicioIndex,
      totalExercises: session.progreso.totalEjercicios,
      currentSet: session.ejercicioActual?.serieActual ?? 1,
      totalSets: session.ejercicioActual?.totalSeries ?? 3,
      elapsedSeconds: session.progreso.segundosTranscurridos,
      restSeconds: session.descanso.segundosRestantes,
      isResting: session.descanso.activo,
      isComplete: session.estado == 'finalizada',
      heartRateBpm: session.bpm,
      calories: session.progreso.calorias,
    );
  }

  /// Pide al móvil que abra esta rutina. El watch queda en espera
  /// hasta que el móvil active la sesión.
  Future<void> solicitarSesion(Routine routine) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null || routine.ejercicios.isEmpty) return;

    final primera = routine.ejercicios.first;
    state = WearSessionState(isWaiting: true);

    await ref.read(syncServiceProvider).limpiarSesionesAnteriores(user.uid);
    await ref.read(syncServiceProvider).crearSesion(
          ActiveSession(
            id: '',
            hostUid: user.uid,
            rutinaId: routine.id,
            rutinaNombre: routine.nombre,
            estado: 'solicitada',
            ejercicioActual: ExerciseState(
              nombre: primera.nombre,
              musculo: primera.musculo,
              gifUrl: primera.gifUrl,
              serieActual: 1,
              totalSeries: primera.series,
              reps: primera.reps,
              descansoSegundos: primera.descansoSegundos,
            ),
            progreso: ProgressState(
              ejercicioIndex: 0,
              totalEjercicios: routine.ejercicios.length,
              segundosTranscurridos: 0,
              calorias: 0,
            ),
            descanso: RestState(activo: false, segundosRestantes: 0),
            bpm: 72,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  // -------- Controles: siempre enviados como comando al móvil --------

  void nextSet() => _enviarComando('siguienteSerie');

  void nextExercise() => _enviarComando('siguienteEjercicio');

  void finishWorkout() => _enviarComando('finalizar');

  void reanudar() => _enviarComando('reanudar');

  void _enviarComando(String accion) {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    ref.read(syncServiceProvider).enviarComando(sessionId, accion, 'watch');
  }
}

final wearSessionProvider =
    NotifierProvider<WearSessionNotifier, WearSessionState>(
  WearSessionNotifier.new,
);
