import 'package:flutter_test/flutter_test.dart';
import 'package:fitnexus/core/data/exercise_gif_mapping.dart';
import 'package:fitnexus/core/data/exercise_catalog_seed.dart';

void main() {
  group('exerciseGifMapping', () {
    test('all seed exercises have a mapping entry', () {
      final semMapping = exerciseCatalogSeed.where(
        (e) => exerciseGifMapping[e['nombre']] == null || exerciseGifMapping[e['nombre']]!.isEmpty,
      ).toList();

      if (semMapping.isNotEmpty) {
        print('Ejercicios sin mapping:');
        for (final e in semMapping) {
          print('  - ${e['nombre']}');
        }
      }
      expect(semMapping, isEmpty);
    });

    test('all mapping URLs start with expected prefix', () {
      for (final entry in exerciseGifMapping.entries) {
        expect(
          entry.value,
          startsWith('https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB'),
          reason: 'URL inválida para: ${entry.key}',
        );
      }
    });

    test('no empty URLs in mapping', () {
      final empty = exerciseGifMapping.entries.where((e) => e.value.isEmpty).toList();
      if (empty.isNotEmpty) {
        print('Entradas con URL vacía:');
        for (final e in empty) {
          print('  - ${e.key}');
        }
      }
      expect(empty, isEmpty);
    });
  });
}
