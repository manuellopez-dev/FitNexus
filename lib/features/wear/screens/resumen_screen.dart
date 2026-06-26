import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wear_session_provider.dart';

class ResumenScreen extends ConsumerWidget {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    if (!session.isComplete) {
      return Container(
        color: const Color(0xFF0D0D0F),
        child: Center(
          child: Text(
            'Sin sesión',
            style: GoogleFonts.zenDots(fontSize: 10, color: const Color(0xFF6B6B80)),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0D0D0F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFC8F135), size: 32),
              const SizedBox(height: 6),
              Text(
                '¡Entrenamiento\ncompletado!',
                style: GoogleFonts.zenDots(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              _resumenItem('Duración', _formatSegundos(session.elapsedSeconds)),
              const SizedBox(height: 4),
              _resumenItem('Calorías', '${session.calories} cal'),
              const SizedBox(height: 4),
              _resumenItem('Freq. prom.', '${session.heartRateBpm} BPM'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(wearSessionProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8F135),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.zenDots(fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumenItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.zenDots(fontSize: 8, color: const Color(0xFF6B6B80)),
        ),
        Text(
          value,
          style: GoogleFonts.zenDots(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
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
