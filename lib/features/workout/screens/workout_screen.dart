import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _serieActual = 1;
  final int _totalSeries = 4;
  int _ejercicioActual = 0;
  int _segundosDescanso = 90;
  bool _descansando = false;
  Timer? _timer;

  final List<Map<String, dynamic>> _ejercicios = [
    {
      'nombre': 'Press de Banca',
      'musculo': 'Pecho · Tríceps',
      'series': 4,
      'reps': 12,
      'descanso': 90,
    },
    {
      'nombre': 'Aperturas con Mancuernas',
      'musculo': 'Pecho',
      'series': 3,
      'reps': 15,
      'descanso': 60,
    },
    {
      'nombre': 'Fondos en Paralelas',
      'musculo': 'Tríceps · Pecho',
      'series': 3,
      'reps': 10,
      'descanso': 75,
    },
    {
      'nombre': 'Press Militar',
      'musculo': 'Hombros',
      'series': 4,
      'reps': 10,
      'descanso': 90,
    },
  ];

  Map<String, dynamic> get _ejercicioActualData =>
      _ejercicios[_ejercicioActual];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarDescanso() {
    setState(() {
      _descansando = true;
      _segundosDescanso = _ejercicioActualData['descanso'];
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosDescanso <= 0) {
        timer.cancel();
        setState(() => _descansando = false);
      } else {
        setState(() => _segundosDescanso--);
      }
    });
  }

  void _serieCompletada() {
    if (_serieActual < _totalSeries) {
      _iniciarDescanso();
      setState(() => _serieActual++);
    } else {
      // Siguiente ejercicio
      if (_ejercicioActual < _ejercicios.length - 1) {
        _timer?.cancel();
        setState(() {
          _ejercicioActual++;
          _serieActual = 1;
          _descansando = false;
        });
      } else {
        _mostrarResumen();
      }
    }
  }

  void _mostrarResumen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFC8F135),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Rutina completada!',
              style: GoogleFonts.zenDots(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE8E8F0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Excelente trabajo, Manuel',
              style: GoogleFonts.zenDots(
                fontSize: 14,
                color: const Color(0xFF6B6B80),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8F135),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Finalizar',
                  style: GoogleFonts.zenDots(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTiempo(int segundos) {
    final m = (segundos ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildImagenEjercicio(),
              const SizedBox(height: 20),
              _buildNombreEjercicio(),
              const SizedBox(height: 20),
              _buildCardSeriesReps(),
              const SizedBox(height: 16),
              _buildCardDescanso(),
              const Spacer(),
              _buildBotones(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4D6D),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'EN VIVO',
              style: GoogleFonts.zenDots(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF4D6D),
              ),
            ),
          ],
        ),
        Text(
          'Serie $_serieActual de $_totalSeries',
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A2A35)),
            ),
            child: const Icon(
              Icons.close,
              color: Color(0xFF6B6B80),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagenEjercicio() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            color: Color(0xFF2A2A35),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            _ejercicioActualData['nombre'],
            style: GoogleFonts.zenDots(
              fontSize: 14,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNombreEjercicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _ejercicioActualData['nombre'],
          style: GoogleFonts.zenDots(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _ejercicioActualData['musculo'],
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSeriesReps() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            valor: '$_serieActual',
            label: 'Series',
            color: const Color(0xFFC8F135),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            valor: '${_ejercicioActualData['reps']}',
            label: 'Repeticiones',
            color: const Color(0xFFE8E8F0),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String valor,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: GoogleFonts.zenDots(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 11,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDescanso() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _descansando
              ? const Color(0xFFC8F135)
              : const Color(0xFF2A2A35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Descanso',
            style: GoogleFonts.zenDots(
              fontSize: 12,
              color: const Color(0xFF6B6B80),
            ),
          ),
          Text(
            _formatTiempo(_segundosDescanso),
            style: GoogleFonts.zenDots(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _descansando
                  ? const Color(0xFFC8F135)
                  : const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotones() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _descansando ? null : _serieCompletada,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8F135),
              foregroundColor: Colors.black,
              disabledBackgroundColor: const Color(0xFF2A2A35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _descansando ? 'Descansando...' : 'Serie completada ✓',
              style: GoogleFonts.zenDots(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2A2A35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Terminar entrenamiento',
              style: GoogleFonts.zenDots(
                fontSize: 14,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ),
        ),
      ],
    );
  }
}