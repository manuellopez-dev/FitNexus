import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../wear/providers/wear_session_provider.dart';

class RestTvScreen extends ConsumerWidget {
  const RestTvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    if (!session.isResting) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0F),
        body: Center(
          child: Text(
            'Sin descanso activo',
            style: GoogleFonts.zenDots(
              fontSize: 18,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ),
      );
    }

    final restSeconds = session.restSeconds;
    final totalRest = 90;
    final progress = totalRest > 0 ? restSeconds / totalRest : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTimerSection(restSeconds, progress, session),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: _buildInfoSection(session),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(int seconds, double progress, WearSessionState session) {
    final isAlmostDone = seconds <= 10;
    final statusColor = isAlmostDone ? const Color(0xFFC8F135) : const Color(0xFF5B8DEE);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Descanso',
          style: GoogleFonts.zenDots(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6B80),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _RestCirclePainter(
              progress: progress,
              primaryColor: statusColor,
              backgroundColor: const Color(0xFF2A2A35),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatSegundos(seconds),
                    style: GoogleFonts.zenDots(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  Text(
                    'restante',
                    style: GoogleFonts.zenDots(
                      fontSize: 14,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            isAlmostDone ? '¡Prepárate para el siguiente ejercicio!' : 'Recuperándote...',
            style: GoogleFonts.zenDots(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSessionProgress(session),
      ],
    );
  }

  Widget _buildSessionProgress(WearSessionState session) {
    final progresoGeneral = session.totalExercises > 0
        ? (session.currentExerciseIndex + 1) / session.totalExercises
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de sesión',
              style: GoogleFonts.zenDots(
                fontSize: 12,
                color: const Color(0xFF6B6B80),
              ),
            ),
            Text(
              '${(progresoGeneral * 100).toInt()}%',
              style: GoogleFonts.zenDots(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC8F135),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progresoGeneral,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC8F135),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(WearSessionState session) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFF5B8DEE), size: 24),
              const SizedBox(width: 12),
              Text(
                'Información de la Sesión',
                style: GoogleFonts.zenDots(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoBlock(
            'Ejercicio Actual',
            session.currentExercise?.nombre ?? 'N/A',
            const Color(0xFFC8F135),
          ),
          const SizedBox(height: 16),
          _buildInfoBlock(
            'Grupo Muscular',
            session.currentExercise?.musculo ?? 'N/A',
            const Color(0xFF5B8DEE),
          ),
          const SizedBox(height: 16),
          _buildInfoBlock(
            'Series Completadas',
            '${session.currentSet - 1} de ${session.totalSets}',
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2A2A35), height: 1),
          const SizedBox(height: 24),
          Text(
            'Recomendaciones',
            style: GoogleFonts.zenDots(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B6B80),
            ),
          ),
          const SizedBox(height: 12),
          _buildRecommendation('💡 Mantén una buena hidratación durante el descanso'),
          const SizedBox(height: 8),
          _buildRecommendation('🫁 Realiza respiraciones profundas para recuperar el aliento'),
          const SizedBox(height: 8),
          _buildRecommendation('🔄 Estira los músculos que acabas de trabajar'),
          const SizedBox(height: 24),
          _buildNextExercisePreview(session),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.zenDots(
                fontSize: 11,
                color: const Color(0xFF6B6B80),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.zenDots(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE8E8F0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendation(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.zenDots(
                fontSize: 12,
                color: const Color(0xFFE8E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextExercisePreview(WearSessionState session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC8F135).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8F135).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC8F135).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Color(0xFFC8F135),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siguiente ejercicio',
                style: GoogleFonts.zenDots(
                  fontSize: 11,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              Text(
                session.currentExercise?.nombre ?? 'Continuar rutina',
                style: GoogleFonts.zenDots(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC8F135),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSegundos(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _RestCirclePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  _RestCirclePainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
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
    canvas.drawCircle(Offset(dotX, dotY), 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RestCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
