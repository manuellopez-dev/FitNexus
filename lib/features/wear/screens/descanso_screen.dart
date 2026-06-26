import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wear_session_provider.dart';

class DescansoScreen extends ConsumerWidget {
  const DescansoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    if (!session.isResting) {
      return Container(
        color: const Color(0xFF0D0D0F),
        child: Center(
          child: Text(
            'Sin descanso',
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
              Text(
                'Descanso',
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: 90 > 0 ? session.restSeconds / 90 : 0,
                      strokeWidth: 5,
                      backgroundColor: const Color(0xFF1E1E24),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B8DEE)),
                    ),
                  ),
                  Text(
                    _formatSegundos(session.restSeconds),
                    style: GoogleFonts.zenDots(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                session.elapsedSeconds > 0
                    ? 'Recuperándote...'
                    : 'Preparado para la siguiente',
                style: GoogleFonts.zenDots(fontSize: 8, color: const Color(0xFF6B6B80)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSegundos(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
