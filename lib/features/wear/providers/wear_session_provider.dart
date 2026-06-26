import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/routine.dart';
import '../../../core/models/exercise.dart';

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
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      calories: calories ?? this.calories,
    );
  }
}

class WearSessionNotifier extends Notifier<WearSessionState> {
  Timer? _timer;
  Timer? _bpmTimer;

  @override
  WearSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _bpmTimer?.cancel();
    });
    return WearSessionState();
  }

  void startWorkout(Routine routine) {
    if (routine.ejercicios.isEmpty) return;
    state = WearSessionState(
      currentExercise: routine.ejercicios.first,
      totalExercises: routine.ejercicios.length,
      totalSets: routine.ejercicios.first.series,
      restSeconds: routine.ejercicios.first.descansoSegundos,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
        calories: ((state.elapsedSeconds + 1) / 60 * 8).round(),
      );
    });
    _simularBpm();
  }

  void _simularBpm() {
    _bpmTimer?.cancel();
    _bpmTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final variacion = (DateTime.now().millisecondsSinceEpoch % 30 - 15).toInt();
      state = state.copyWith(
        heartRateBpm: (72 + variacion).clamp(60, 130),
      );
    });
  }

  void nextSet() {
    if (state.currentSet < state.totalSets) {
      state = state.copyWith(
        currentSet: state.currentSet + 1,
        isResting: true,
        restSeconds: state.restSeconds,
      );
      _iniciarCuentaRegresiva();
    }
  }

  void nextExercise() {
    if (state.currentExerciseIndex < state.totalExercises - 1) {
      final nextIndex = state.currentExerciseIndex + 1;
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        currentSet: 1,
        isResting: false,
        restSeconds: 90,
      );
      _timer?.cancel();
    }
  }

  void _iniciarCuentaRegresiva() {
    _timer?.cancel();
    var segundos = state.restSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundos <= 0) {
        timer.cancel();
        state = state.copyWith(isResting: false);
      } else {
        segundos--;
        state = state.copyWith(restSeconds: segundos);
      }
    });
  }

  void finishWorkout() {
    _timer?.cancel();
    _bpmTimer?.cancel();
    state = state.copyWith(isComplete: true);
  }
}

final wearSessionProvider = NotifierProvider<WearSessionNotifier, WearSessionState>(
  WearSessionNotifier.new,
);
