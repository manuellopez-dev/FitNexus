import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wear_session_provider.dart';

class BpmScreen extends ConsumerWidget {
  const BpmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    return Container(
      color: const Color(0xFF0D0D0F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Frecuencia',
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _bpmColor(session.heartRateBpm),
                    width: 4,
                  ),
                  color: const Color(0xFF1E1E24),
                ),
                child: Center(
                  child: Text(
                    '${session.heartRateBpm}',
                    style: GoogleFonts.zenDots(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _bpmColor(session.heartRateBpm),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'BPM',
                style: GoogleFonts.zenDots(
                  fontSize: 9,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cal: ${session.calories}',
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFFC8F135),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _bpmColor(int bpm) {
    if (bpm < 60) return const Color(0xFF5B8DEE);
    if (bpm < 100) return const Color(0xFFC8F135);
    return const Color(0xFFFF4D6D);
  }
}
