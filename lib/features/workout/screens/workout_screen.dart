import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/routine.dart';
import '../../../core/models/exercise.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/snackbar_helper.dart';
import '../../../core/data/exercise_gif_mapping.dart';

class _SetLog {
  final int setNumber;
  final double weight;
  final int reps;
  _SetLog({required this.setNumber, required this.weight, required this.reps});
}

class WorkoutScreen extends ConsumerStatefulWidget {
  final Routine? routine;

  const WorkoutScreen({super.key, this.routine});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final List<RoutineExercise> _ejercicios;
  int _serieActual = 1;
  int _ejercicioActual = 0;
  int _segundosDescanso = 90;
  bool _descansando = false;
  Timer? _timer;
  Timer? _cronometro;
  late final DateTime _inicio;
  int _segundosTranscurridos = 0;
  int _calorias = 0;
  late final AnimationController _pulsoCtrl;
  late final Animation<double> _pulsoAnim;

  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();

  // Log de series completadas: [ejercicioIndex][serieIndex] = (peso, reps)
  final List<List<_SetLog>> _setsLog = [];

  RoutineExercise get _ejercicioActualData => _ejercicios[_ejercicioActual];
  int get _totalSeries => _ejercicioActualData.series;

  @override
  void initState() {
    super.initState();
    _ejercicios = widget.routine?.ejercicios ?? [];
    _inicio = DateTime.now();
    if (_ejercicios.isNotEmpty) {
      _segundosDescanso = _ejercicios.first.descansoSegundos;
    }
    _weightCtrl.text = '';
    _repsCtrl.text = '';
    for (int i = 0; i < _ejercicios.length; i++) {
      _setsLog.add([]);
    }
    _cronometro = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _segundosTranscurridos++;
        _calorias = (_segundosTranscurridos / 60 * 8).round();
      });
    });
    _pulsoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulsoAnim = Tween<double>(begin: 0.85, end: 1.0).animate(_pulsoCtrl);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cronometro?.cancel();
    _pulsoCtrl.dispose();
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _resetInputs() {
    _weightCtrl.text = '';
    _repsCtrl.text = '';
  }

  void _iniciarDescanso() {
    _timer?.cancel();
    setState(() {
      _descansando = true;
      _segundosDescanso = _ejercicioActualData.descansoSegundos;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosDescanso <= 0) {
        timer.cancel();
        if (mounted) setState(() => _descansando = false);
      } else {
        if (mounted) setState(() => _segundosDescanso--);
      }
    });
  }

  void _serieCompletada() {
    final peso = double.tryParse(_weightCtrl.text) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? 0;
    _setsLog[_ejercicioActual].add(_SetLog(
      setNumber: _serieActual,
      weight: peso,
      reps: reps > 0 ? reps : _ejercicioActualData.reps,
    ));
    _resetInputs();

    if (_serieActual < _totalSeries) {
      _iniciarDescanso();
      setState(() => _serieActual++);
    } else {
      if (_ejercicioActual < _ejercicios.length - 1) {
        _timer?.cancel();
        setState(() {
          _ejercicioActual++;
          _serieActual = 1;
          _descansando = false;
        });
      } else {
        _timer?.cancel();
        _mostrarResumen();
      }
    }
  }

  void _confirmarSalida() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '¿Terminar entrenamiento?',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        content: Text(
          'Vas a perder el progreso de esta sesión.',
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80)),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: Text(
              'Terminar',
              style: GoogleFonts.zenDots(
                color: const Color(0xFFFF4D6D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarEnHistorial() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final duracion = DateTime.now().difference(_inicio).inMinutes;
    try {
      await ref.read(firestoreServiceProvider).guardarWorkoutCompletado(
        uid: user.uid,
        nombreRutina: widget.routine?.nombre ?? 'Rutina',
        duracionMinutos: duracion < 1 ? 1 : duracion,
        ejerciciosCompletados: _ejercicios.length,
      );
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Error al guardar historial: $e');
      }
    }
  }

  void _mostrarResumen() {
    unawaited(_guardarEnHistorial());
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
              'Excelente trabajo',
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
                  context.pop();
                  context.pop();
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
    if (_ejercicios.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Selecciona una rutina primero',
              style: GoogleFonts.zenDots(
                fontSize: 16,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ),
        ),
      );
    }

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
              const SizedBox(height: 12),
              _buildMetricas(),
              const SizedBox(height: 12),
              _buildDemoEjercicio(),
              const SizedBox(height: 14),
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
          '${_ejercicioActual + 1}/${_ejercicios.length} · Serie $_serieActual de $_totalSeries',
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
        GestureDetector(
          onTap: _confirmarSalida,
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

  Widget _buildMetricas() {
    return Row(
      children: [
        Expanded(child: _metricaCard(Icons.timer_outlined, _formatTiempo(_segundosTranscurridos), 'Tiempo')),
        const SizedBox(width: 10),
        Expanded(child: _metricaCard(Icons.local_fire_department_outlined, '$_calorias', 'Calorías')),
        const SizedBox(width: 10),
        Expanded(child: _metricaCard(Icons.fitness_center, '${_ejercicioActual + 1}/${_ejercicios.length}', 'Ejercicio')),
      ],
    );
  }

  Widget _metricaCard(IconData icon, String valor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFC8F135), size: 18),
          const SizedBox(height: 6),
          Text(
            valor,
            style: GoogleFonts.zenDots(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 10,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoEjercicio() {
    final rawGif = _ejercicioActualData.gifUrl;
    final gifUrl = (rawGif.isNotEmpty && !rawGif.contains('workoutxapp'))
        ? rawGif
        : (exerciseGifMapping[_ejercicioActualData.nombre] ?? '');
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: gifUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                gifUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 140,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null
                        ? child
                        : _placeholderAnimado(),
                errorBuilder: (context, error, stackTrace) =>
                    _placeholderAnimado(),
              ),
            )
          : _placeholderAnimado(),
    );
  }

  Widget _placeholderAnimado() {
    return AnimatedBuilder(
      animation: _pulsoAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulsoAnim.value,
          child: child,
        );
      },
      child: const Icon(
        Icons.fitness_center,
        color: Color(0xFF2A2A35),
        size: 56,
      ),
    );
  }

  Widget _buildNombreEjercicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _ejercicioActualData.nombre,
          style: GoogleFonts.zenDots(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _ejercicioActualData.musculo,
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSeriesReps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$_serieActual / $_totalSeries',
                      style: GoogleFonts.zenDots(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC8F135),
                      ),
                    ),
                    Text(
                      'Series',
                      style: GoogleFonts.zenDots(
                        fontSize: 11,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.zenDots(
                    color: const Color(0xFFE8E8F0),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Peso (kg)',
                    hintStyle: GoogleFonts.zenDots(
                      color: const Color(0xFF6B6B80),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF16161A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFC8F135)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _repsCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.zenDots(
                    color: const Color(0xFFE8E8F0),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Reps',
                    hintStyle: GoogleFonts.zenDots(
                      color: const Color(0xFF6B6B80),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF16161A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFC8F135)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa peso y reps reales de esta serie',
            style: GoogleFonts.zenDots(
              fontSize: 10,
              color: const Color(0xFF6B6B80),
            ),
          ),
          if (_setsLog[_ejercicioActual].isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._setsLog[_ejercicioActual].map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Serie ${s.setNumber}: ${s.weight.toStringAsFixed(0)} kg × ${s.reps} reps',
                style: GoogleFonts.zenDots(
                  fontSize: 11,
                  color: const Color(0xFFC8F135),
                ),
              ),
            )),
          ],
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
            onPressed: _confirmarSalida,
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
