import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/wear_session_provider.dart';

class WatchFaceScreen extends ConsumerWidget {
  const WatchFaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinasAsync = ref.watch(rutinasProvider);

    return Container(
      color: const Color(0xFF0D0D0F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FitNexus',
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC8F135),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  shape: BoxShape.circle,
                  border: Border(
                    top: BorderSide(color: const Color(0xFFC8F135), width: 3),
                    right: BorderSide(color: const Color(0xFFC8F135), width: 3),
                    bottom: BorderSide(color: const Color(0xFF2A2A35), width: 3),
                    left: BorderSide(color: const Color(0xFF2A2A35), width: 3),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.bolt, color: Color(0xFFC8F135), size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatHora(),
                style: GoogleFonts.zenDots(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              const SizedBox(height: 14),
              rutinasAsync.when(
                data: (rutinas) {
                  if (rutinas.isEmpty) {
                    return _smallLabel('Sin rutinas');
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => ref.read(wearSessionProvider.notifier).startWorkout(rutinas.first),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8F135),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Iniciar ${rutinas.first.nombre}',
                        style: GoogleFonts.zenDots(fontSize: 9, color: Colors.black),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    color: Color(0xFFC8F135), strokeWidth: 2,
                  ),
                ),
                error: (_, __) => _smallLabel('Error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.zenDots(fontSize: 9, color: const Color(0xFF6B6B80)),
    );
  }

  String _formatHora() {
    final ahora = DateTime.now();
    return '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
  }
}
