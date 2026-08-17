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

    final ej = session.currentExercise;
    final progresoEjercicio = session.totalExercises > 0
        ? (session.currentExerciseIndex + 1) / session.totalExercises
        : 0.0;
    final progresoSerie = session.totalSets > 0
        ? session.currentSet / session.totalSets
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
              const SizedBox(height: 8),
              _buildTopProgressBar(progresoEjercicio),
              const SizedBox(height: 10),
              Expanded(
                child: _buildMainCard(ej, session, progresoSerie),
              ),
              const SizedBox(height: 8),
              _buildBottomProgressBar(progresoSerie),
              const SizedBox(height: 8),
              _buildButtons(ref, session),
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
        Icon(Icons.fitness_center, color: const Color(0xFFC8F135), size: 12),
        const SizedBox(width: 4),
        Text(
          'Ejercicio',
          style: GoogleFonts.zenDots(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso general',
              style: GoogleFonts.zenDots(
                fontSize: 8,
                color: const Color(0xFF6B6B80),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.zenDots(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC8F135),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC8F135),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(dynamic ej, WearSessionState session, double progresoSerie) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                ej?.nombre ?? 'Sin ejercicio',
                style: GoogleFonts.zenDots(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8F135).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ej?.musculo ?? '',
                  style: GoogleFonts.zenDots(
                    fontSize: 8,
                    color: const Color(0xFFC8F135),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${ej?.reps ?? 0} reps por serie',
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFF5B8DEE),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatSegundos(session.elapsedSeconds),
                style: GoogleFonts.zenDots(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircleIndicator(
                value: '${session.currentSet}',
                label: 'Serie',
                progress: progresoSerie,
              ),
              _buildCircleIndicator(
                value: '${ej?.series ?? 0}',
                label: 'Total',
                progress: 1.0,
              ),
              _buildCircleIndicator(
                value: '${session.currentExerciseIndex + 1}',
                label: 'Ejercicio',
                progress: session.totalExercises > 0
                    ? (session.currentExerciseIndex + 1) / session.totalExercises
                    : 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIndicator({
    required String value,
    required String label,
    required double progress,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CustomPaint(
            painter: _MiniCirclePainter(
              progress: progress,
              progressColor: const Color(0xFFC8F135),
              backgroundColor: const Color(0xFF2A2A35),
            ),
            child: Center(
              child: Text(
                value,
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.zenDots(
            fontSize: 7,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomProgressBar(double progress) {
    return Column(
      children: [
        Text(
          'Serie ${progress > 0 ? (progress * 100).toInt() : 0}%',
          style: GoogleFonts.zenDots(
            fontSize: 8,
            color: const Color(0xFF6B6B80),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8F135), Color(0xFFA0D020)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(WidgetRef ref, WearSessionState session) {
    return Row(
      children: [
        if (session.currentSet < session.totalSets)
          Expanded(
            child: SizedBox(
              height: 36,
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
                  'Siguiente serie',
                  style: GoogleFonts.zenDots(
                    fontSize: 9,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (session.currentSet < session.totalSets)
          const SizedBox(width: 8),
        SizedBox(
          width: 60,
          height: 36,
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
              style: GoogleFonts.zenDots(
                fontSize: 9,
                color: Colors.white,
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

class _MiniCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _MiniCirclePainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
