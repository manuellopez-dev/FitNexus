import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wear_session_provider.dart';

class EjercicioScreen extends ConsumerWidget {
  const EjercicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    if (!session.isResting && session.currentExercise == null) {
      return Container(
        color: const Color(0xFF0D0D0F),
        child: Center(
          child: Text(
            'Esperando rutina...',
            style: GoogleFonts.zenDots(fontSize: 10, color: const Color(0xFF6B6B80)),
          ),
        ),
      );
    }

    final ej = session.currentExercise!;
    final tiempo = _formatSegundos(session.elapsedSeconds);

    return Container(
      color: const Color(0xFF0D0D0F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ej.nombre,
                style: GoogleFonts.zenDots(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _badge('${session.currentSet}/${session.totalSets}', 'Series'),
                  const SizedBox(width: 8),
                  _badge(tiempo, 'Tiempo'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${ej.reps} reps',
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFF5B8DEE),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (session.currentSet < session.totalSets)
                    SizedBox(
                      width: 60,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => ref.read(wearSessionProvider.notifier).nextSet(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B8DEE),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Siguiente',
                          style: GoogleFonts.zenDots(fontSize: 8, color: Colors.black),
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 60,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => ref.read(wearSessionProvider.notifier).finishWorkout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D6D),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Salir',
                        style: GoogleFonts.zenDots(fontSize: 8, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String valor, String label) {
    return Column(
      children: [
        Text(
          valor,
          style: GoogleFonts.zenDots(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC8F135),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.zenDots(fontSize: 7, color: const Color(0xFF6B6B80)),
        ),
      ],
    );
  }

  String _formatSegundos(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
