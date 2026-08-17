import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wear_session_provider.dart';

class BpmScreen extends ConsumerStatefulWidget {
  const BpmScreen({super.key});

  @override
  ConsumerState<BpmScreen> createState() => _BpmScreenState();
}

class _BpmScreenState extends ConsumerState<BpmScreen> {
  final List<int> _bpmHistory = [];
  Timer? _historyTimer;

  @override
  void initState() {
    super.initState();
    _historyTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateBpmHistory();
    });
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    super.dispose();
  }

  void _updateBpmHistory() {
    final session = ref.read(wearSessionProvider);
    final bpm = session.heartRateBpm;
    
    if (bpm > 0) {
      setState(() {
        _bpmHistory.add(bpm);
        if (_bpmHistory.length > 20) {
          _bpmHistory.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(wearSessionProvider);
    final bpm = session.heartRateBpm;
    final bpmColor = _bpmColor(bpm);

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
              _buildHeartCircle(bpm, bpmColor),
              const SizedBox(height: 10),
              _buildBpmBar(bpm, bpmColor),
              const SizedBox(height: 10),
              Expanded(
                child: _buildGraph(bpmColor),
              ),
              const SizedBox(height: 8),
              _buildStats(session),
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
        Icon(Icons.favorite, color: const Color(0xFFFF4D6D), size: 12),
        const SizedBox(width: 4),
        Text(
          'Ritmo Cardíaco',
          style: GoogleFonts.zenDots(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildHeartCircle(int bpm, Color color) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E1E24),
          border: Border.all(
            color: color,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                '$bpm',
                style: GoogleFonts.zenDots(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBpmBar(int bpm, Color color) {
    final progress = (bpm / 180).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BPM Actual',
              style: GoogleFonts.zenDots(
                fontSize: 8,
                color: const Color(0xFF6B6B80),
              ),
            ),
            Text(
              '$bpm / 180',
              style: GoogleFonts.zenDots(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.7),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraph(Color bpmColor) {
    if (_bpmHistory.isEmpty) {
      return Center(
        child: Text(
          'Inicia entrenamiento para ver historial',
          style: GoogleFonts.zenDots(
            fontSize: 9,
            color: const Color(0xFF6B6B80),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial BPM',
          style: GoogleFonts.zenDots(
            fontSize: 8,
            color: const Color(0xFF6B6B80),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _BpmGraphPainter(
              bpmHistory: _bpmHistory,
              bpmColor: bpmColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(WearSessionState session) {
    final avgBpm = _bpmHistory.isNotEmpty
        ? (_bpmHistory.reduce((a, b) => a + b) / _bpmHistory.length).toInt()
        : 0;
    final maxBpm = _bpmHistory.isNotEmpty
        ? _bpmHistory.reduce((a, b) => a > b ? a : b)
        : 0;
    final minBpm = _bpmHistory.isNotEmpty
        ? _bpmHistory.reduce((a, b) => a < b ? a : b)
        : 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('PROM', '$avgBpm', const Color(0xFFC8F135)),
          _buildStatDivider(),
          _buildStatItem('MÁX', '$maxBpm', const Color(0xFFFF4D6D)),
          _buildStatDivider(),
          _buildStatItem('MÍN', '$minBpm', const Color(0xFF5B8DEE)),
          _buildStatDivider(),
          _buildStatItem('CAL', '${session.calories}', const Color(0xFFC8F135)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.zenDots(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0xFF2A2A35),
    );
  }

  Color _bpmColor(int bpm) {
    if (bpm < 60) return const Color(0xFF5B8DEE);
    if (bpm < 100) return const Color(0xFFC8F135);
    return const Color(0xFFFF4D6D);
  }
}

class _BpmGraphPainter extends CustomPainter {
  final List<int> bpmHistory;
  final Color bpmColor;

  _BpmGraphPainter({
    required this.bpmHistory,
    required this.bpmColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bpmHistory.isEmpty) return;

    final paint = Paint()
      ..color = bpmColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          bpmColor.withValues(alpha: 0.3),
          bpmColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final minBpm = bpmHistory.reduce((a, b) => a < b ? a : b);
    final maxBpm = bpmHistory.reduce((a, b) => a > b ? a : b);
    final range = (maxBpm - minBpm).toDouble();
    final normalizedValues = bpmHistory.map((bpm) {
      if (range == 0) return 0.5;
      return (bpm - minBpm) / range;
    }).toList();

    final stepX = size.width / (normalizedValues.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < normalizedValues.length; i++) {
      final x = i * stepX;
      final y = size.height - (normalizedValues[i] * size.height * 0.8) - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = bpmColor
      ..style = PaintingStyle.fill;

    if (normalizedValues.isNotEmpty) {
      final lastX = (normalizedValues.length - 1) * stepX;
      final lastY = size.height - (normalizedValues.last * size.height * 0.8) - size.height * 0.1;
      canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BpmGraphPainter oldDelegate) {
    return oldDelegate.bpmHistory != bpmHistory;
  }
}
