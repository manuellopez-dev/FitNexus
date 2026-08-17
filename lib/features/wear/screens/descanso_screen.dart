import 'dart:math';
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
            'Sin descanso activo',
            style: GoogleFonts.zenDots(
              fontSize: 10,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ),
      );
    }

    final restSeconds = session.restSeconds;
    final totalRest = 90;
    final progress = totalRest > 0 ? restSeconds / totalRest : 0.0;
    final progresoGeneral = session.totalExercises > 0
        ? (session.currentExerciseIndex + 1) / session.totalExercises
        : 0.0;

    return Container(
      color: const Color(0xFF0D0D0F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildCircularTimer(restSeconds, progress),
              const SizedBox(height: 10),
              _buildStatusText(session),
              const SizedBox(height: 12),
              _buildBars(session, progresoGeneral),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.nightlight_round, color: const Color(0xFF5B8DEE), size: 12),
        const SizedBox(width: 4),
        Text(
          'Descanso',
          style: GoogleFonts.zenDots(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularTimer(int seconds, double progress) {
    return Center(
      child: SizedBox(
        width: 130,
        height: 130,
        child: CustomPaint(
          painter: _RestTimerPainter(
            progress: progress,
            primaryColor: const Color(0xFF5B8DEE),
            backgroundColor: const Color(0xFF2A2A35),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatSegundos(seconds),
                  style: GoogleFonts.zenDots(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                Text(
                  'restante',
                  style: GoogleFonts.zenDots(
                    fontSize: 9,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(WearSessionState session) {
    final isAlmostDone = session.restSeconds <= 10;
    final statusText = isAlmostDone
        ? '¡Prepárate!'
        : 'Recuperándote...';
    final statusColor = isAlmostDone
        ? const Color(0xFFC8F135)
        : const Color(0xFF5B8DEE);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          statusText,
          style: GoogleFonts.zenDots(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBars(WearSessionState session, double progresoGeneral) {
    final totalEjercicios = session.totalExercises > 0 ? session.totalExercises : 1;
    final ejerciciosCompletados = session.currentExerciseIndex;
    final progresoSerie = session.totalSets > 0
        ? session.currentSet / session.totalSets
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBar(
          'Progreso',
          progresoGeneral,
          const Color(0xFFC8F135),
        ),
        const SizedBox(height: 6),
        _buildBar(
          'Serie',
          progresoSerie,
          const Color(0xFF5B8DEE),
        ),
        const SizedBox(height: 6),
        _buildBar(
          'Ejercicios',
          ejerciciosCompletados / totalEjercicios,
          const Color(0xFFFF4D6D),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double progress, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 8,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A35),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
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

class _RestTimerPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  _RestTimerPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final angle = -3.14159265 / 2 + sweepAngle;
    final dotX = center.dx + radius * cos(angle);
    final dotY = center.dy + radius * sin(angle);
    canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RestTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
