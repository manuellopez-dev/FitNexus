import 'package:flutter_test/flutter_test.dart';
import 'package:fitnexus/core/models/exercise.dart';
import 'package:fitnexus/core/models/routine.dart';

void main() {
  group('ExerciseCatalogItem', () {
    test('fromMap and toMap roundtrip', () {
      final map = {
        'nombre': 'Press de banca',
        'musculo': 'Pecho',
        'equipo': 'Barra',
        'gifUrl': 'https://example.com/1.gif',
      };
      final item = ExerciseCatalogItem.fromMap('abc123', map);
      expect(item.id, 'abc123');
      expect(item.nombre, 'Press de banca');
      expect(item.musculo, 'Pecho');
      expect(item.equipo, 'Barra');
      expect(item.gifUrl, 'https://example.com/1.gif');
      expect(item.toMap(), map);
    });

    test('fromMap handles missing fields', () {
      final item = ExerciseCatalogItem.fromMap('id', {});
      expect(item.nombre, '');
      expect(item.musculo, '');
      expect(item.equipo, '');
      expect(item.gifUrl, '');
    });
  });

  group('RoutineExercise', () {
    test('fromMap and toMap roundtrip', () {
      final map = {
        'ejercicioId': 'ex1',
        'nombre': 'Press',
        'musculo': 'Pecho',
        'series': 4,
        'reps': 10,
        'descansoSegundos': 60,
        'gifUrl': 'https://example.com/g.gif',
      };
      final exercise = RoutineExercise.fromMap(map);
      expect(exercise.ejercicioId, 'ex1');
      expect(exercise.series, 4);
      expect(exercise.reps, 10);
      expect(exercise.descansoSegundos, 60);
      expect(exercise.toMap(), map);
    });

    test('fromMap uses defaults for missing fields', () {
      final exercise = RoutineExercise.fromMap({});
      expect(exercise.series, 3);
      expect(exercise.reps, 12);
      expect(exercise.descansoSegundos, 60);
    });
  });

  group('Routine', () {
    test('fromMap and toMap roundtrip', () {
      final ejercicios = [
        RoutineExercise(
          ejercicioId: 'e1',
          nombre: 'Press',
          musculo: 'Pecho',
          series: 4,
          reps: 10,
          descansoSegundos: 60,
        ),
      ];
      final map = {
        'nombre': 'Rutina de pecho',
        'tipo': 'Fuerza',
        'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
      };
      final routine = Routine.fromMap('abc', map);
      expect(routine.id, 'abc');
      expect(routine.nombre, 'Rutina de pecho');
      expect(routine.tipo, 'Fuerza');
      expect(routine.ejercicios.length, 1);
      expect(routine.totalEjercicios, 1);
      expect(routine.toMap(), map);
    });

    test('fromMap handles empty ejercicios', () {
      final map = {'nombre': 'Vacía', 'tipo': 'Cardio', 'ejercicios': []};
      final routine = Routine.fromMap('id', map);
      expect(routine.ejercicios, isEmpty);
      expect(routine.duracionEstimadaMinutos, 0);
    });

    test('duracionEstimadaMinutos calculates correctly', () {
      final ejercicios = [
        RoutineExercise(
          ejercicioId: 'e1',
          nombre: 'Press',
          musculo: 'Pecho',
          series: 4,
          reps: 10,
          descansoSegundos: 60,
        ),
        RoutineExercise(
          ejercicioId: 'e2',
          nombre: 'Aperturas',
          musculo: 'Pecho',
          series: 3,
          reps: 12,
          descansoSegundos: 45,
        ),
      ];
      final routine = Routine(
        id: 'id',
        nombre: 'Test',
        tipo: 'Fuerza',
        ejercicios: ejercicios,
      );
      // Ej1: 4 * (30 + 60) = 360s
      // Ej2: 3 * (30 + 45) = 225s
      // Total: 585s => 10 min
      expect(routine.duracionEstimadaMinutos, 10);
    });
  });
}
