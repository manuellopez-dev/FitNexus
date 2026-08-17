import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/wear_session_provider.dart';

class WatchFaceScreen extends ConsumerStatefulWidget {
  const WatchFaceScreen({super.key});

  @override
  ConsumerState<WatchFaceScreen> createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends ConsumerState<WatchFaceScreen> {
  Timer? _horaTimer;
  String _hora = '';
  String _fecha = '';

  @override
  void initState() {
    super.initState();
    _actualizarHora();
    _horaTimer = Timer.periodic(const Duration(seconds: 1), (_) => _actualizarHora());
  }

  @override
  void dispose() {
    _horaTimer?.cancel();
    super.dispose();
  }

  void _actualizarHora() {
    final ahora = DateTime.now();
    final dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    setState(() {
      _hora = '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
      _fecha = '${dias[ahora.weekday % 7]}, ${ahora.day} ${meses[ahora.month - 1]}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(wearSessionProvider);
    final rutinasAsync = ref.watch(rutinasProvider);

    return Container(
      color: const Color(0xFF0D0D0F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeader(),
              _buildCircleIndicator(session),
              _buildBars(session),
              _buildIndicators(session),
              _buildButton(rutinasAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: const Color(0xFFC8F135), size: 14),
            const SizedBox(width: 4),
            Text(
              'Watch Face',
              style: GoogleFonts.zenDots(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _hora,
          style: GoogleFonts.zenDots(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        Text(
          _fecha,
          style: GoogleFonts.zenDots(
            fontSize: 8,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleIndicator(WearSessionState session) {
    final bpm = session.heartRateBpm;
    final progress = (bpm / 180).clamp(0.0, 1.0);

    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _CircleProgressPainter(
          progress: progress,
          progressColor: const Color(0xFFC8F135),
          backgroundColor: const Color(0xFF1E1E24),
          strokeWidth: 8,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$bpm',
                style: GoogleFonts.zenDots(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              Text(
                'BPM',
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFF6B6B80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBars(WearSessionState session) {
    final totalEjercicios = session.totalExercises > 0 ? session.totalExercises : 1;
    final totalSeries = session.totalSets > 0 ? session.totalSets : 1;
    final progresoEjercicio = session.currentExerciseIndex / totalEjercicios;
    final progresoSerie = session.currentSet / totalSeries;
    final progresoTiempo = session.elapsedSeconds > 0
        ? (session.elapsedSeconds / (session.elapsedSeconds + 120)).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        _buildBar('Tiempo', progresoTiempo),
        const SizedBox(height: 6),
        _buildBar('Series', progresoSerie),
        const SizedBox(height: 6),
        _buildBar('Ejercicios', progresoEjercicio),
      ],
    );
  }

  Widget _buildBar(String label, double progress) {
    return Row(
      children: [
        SizedBox(
          width: 48,
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
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC8F135),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators(WearSessionState session) {
    final bpm = session.heartRateBpm;
    final bool isAlto = bpm > 120;
    final bool isBajo = bpm < 80;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIndicatorDot(
          color: const Color(0xFFFF4D6D),
          label: 'ALTO',
          active: isAlto,
        ),
        _buildIndicatorDot(
          color: const Color(0xFF4CAF50),
          label: 'BAJO',
          active: isBajo,
        ),
      ],
    );
  }

  Widget _buildIndicatorDot({
    required Color color,
    required String label,
    required bool active,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: active ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.zenDots(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: active ? color : const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(AsyncValue<List<dynamic>> rutinasAsync) {
    return rutinasAsync.when(
      data: (rutinas) {
        if (rutinas.isEmpty) {
          return Text(
            'Sin rutinas disponibles',
            style: GoogleFonts.zenDots(
              fontSize: 9,
              color: const Color(0xFF6B6B80),
            ),
          );
        }
        return SizedBox(
          width: double.infinity,
          height: 32,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  rutinas.first.nombre,
                  style: GoogleFonts.zenDots(
                    fontSize: 9,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          color: Color(0xFFC8F135),
          strokeWidth: 2,
        ),
      ),
      error: (_, __) => Text(
        'Error al cargar',
        style: GoogleFonts.zenDots(
          fontSize: 9,
          color: const Color(0xFFFF4D6D),
        ),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
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
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
