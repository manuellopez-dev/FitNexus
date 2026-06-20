import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/routine.dart';
import '../../../core/providers/auth_provider.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  final String routineName;
  final String routineType;

  const ExerciseSelectionScreen({
    super.key,
    required this.routineName,
    this.routineType = 'Fuerza',
  });

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen> {
  final List<RoutineExercise> _selected = [];
  String? _musculoSeleccionado;

  List<ExerciseCatalogItem> _filtrarPorMusculo(
      List<ExerciseCatalogItem> catalogo) {
    if (_musculoSeleccionado == null) return catalogo;
    return catalogo
        .where((e) => e.musculo == _musculoSeleccionado)
        .toList();
  }

  List<String> _musculosDisponibles(List<ExerciseCatalogItem> catalogo) {
    final musculos = catalogo.map((e) => e.musculo).toSet().toList();
    musculos.sort();
    return musculos;
  }

  bool _estaSeleccionado(ExerciseCatalogItem ejercicio) {
    return _selected.any((e) => e.ejercicioId == ejercicio.id);
  }

  void _removerEjercicio(ExerciseCatalogItem ejercicio) {
    setState(() {
      _selected.removeWhere((e) => e.ejercicioId == ejercicio.id);
    });
  }

  Future<void> _agregarConConfig(ExerciseCatalogItem ejercicio) async {
    final config = await _mostrarDialogConfig(context,
      nombre: ejercicio.nombre,
      series: 4,
      reps: 12,
      descanso: 60,
    );
    if (config == null) return;
    final s = config['series']!;
    final r = config['reps']!;
    final d = config['descanso']!;

    setState(() {
      _selected.add(RoutineExercise(
        ejercicioId: ejercicio.id,
        nombre: ejercicio.nombre,
        musculo: ejercicio.musculo,
        series: s,
        reps: r,
        descansoSegundos: d,
      ));
    });
  }

  Future<void> _editarConfig(ExerciseCatalogItem ejercicio, RoutineExercise actual) async {
    final config = await _mostrarDialogConfig(context,
      nombre: ejercicio.nombre,
      series: actual.series,
      reps: actual.reps,
      descanso: actual.descansoSegundos,
    );
    if (config == null) return;
    final s = config['series']!;
    final r = config['reps']!;
    final d = config['descanso']!;

    setState(() {
      final idx = _selected.indexWhere((e) => e.ejercicioId == ejercicio.id);
      if (idx != -1) {
        _selected[idx] = RoutineExercise(
          ejercicioId: ejercicio.id,
          nombre: ejercicio.nombre,
          musculo: ejercicio.musculo,
          series: s,
          reps: r,
          descansoSegundos: d,
        );
      }
    });
  }

  Future<void> _guardarRutina() async {
    if (_selected.isEmpty) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final rutina = Routine(
      id: '',
      nombre: widget.routineName,
      tipo: widget.routineType,
      ejercicios: _selected,
    );

    await ref.read(firestoreServiceProvider).crearRutina(user.uid, rutina);

    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogoAsync = ref.watch(catalogoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE8E8F0)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.routineName,
          style: GoogleFonts.zenDots(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
      ),
      body: catalogoAsync.when(
        data: (catalogo) => _buildContent(catalogo),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC8F135)),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, color: const Color(0xFF6B6B80), size: 48),
                const SizedBox(height: 16),
                Text(
                  'No se pudo cargar el catálogo',
                  style: GoogleFonts.zenDots(
                    fontSize: 14,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(catalogoProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8F135),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<ExerciseCatalogItem> catalogo) {
    final musculos = _musculosDisponibles(catalogo);
    final filtrados = _filtrarPorMusculo(catalogo);

    return Column(
      children: [
        _buildMusculoChips(musculos),
        const SizedBox(height: 8),
        Expanded(child: _buildListaEjercicios(filtrados)),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildMusculoChips(List<String> musculos) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: musculos.length + 1,
        itemBuilder: (context, index) {
          final label = index == 0 ? 'Todos' : musculos[index - 1];
          final seleccionado = index == 0
              ? _musculoSeleccionado == null
              : _musculoSeleccionado == musculos[index - 1];

          return GestureDetector(
            onTap: () => setState(() {
              _musculoSeleccionado =
                  index == 0 ? null : musculos[index - 1];
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: seleccionado
                    ? const Color(0xFFC8F135)
                    : const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: seleccionado
                      ? const Color(0xFFC8F135)
                      : const Color(0xFF2A2A35),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.zenDots(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: seleccionado
                        ? Colors.black
                        : const Color(0xFF6B6B80),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaEjercicios(List<ExerciseCatalogItem> ejercicios) {
    if (ejercicios.isEmpty) {
      return Center(
        child: Text(
          'Sin ejercicios en esta categoría',
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ejercicios.length,
      itemBuilder: (context, index) {
        final ejercicio = ejercicios[index];
        final seleccionado = _estaSeleccionado(ejercicio);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: seleccionado
                ? const Color(0xFF1E1E24)
                : const Color(0xFF16161A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFFC8F135)
                  : const Color(0xFF2A2A35),
            ),
          ),
        child: InkWell(
            onTap: seleccionado
                ? () => _editarConfig(ejercicio, _selected.firstWhere((e) => e.ejercicioId == ejercicio.id))
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconoPorEquipo(ejercicio.equipo),
                  color: const Color(0xFFC8F135),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ejercicio.nombre,
                      style: GoogleFonts.zenDots(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      seleccionado
                          ? '${_selected.firstWhere((e) => e.ejercicioId == ejercicio.id).series} series · ${_selected.firstWhere((e) => e.ejercicioId == ejercicio.id).reps} reps · ${_selected.firstWhere((e) => e.ejercicioId == ejercicio.id).descansoSegundos}s'
                          : '${ejercicio.musculo} · ${ejercicio.equipo}',
                      style: GoogleFonts.zenDots(
                        fontSize: 11,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => seleccionado
                    ? _removerEjercicio(ejercicio)
                    : _agregarConConfig(ejercicio),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? const Color(0xFFC8F135)
                        : const Color(0xFF2A2A35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    seleccionado ? Icons.check : Icons.add,
                    color: seleccionado ? Colors.black : const Color(0xFF6B6B80),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildBottomBar() {
    final duracion = _estimarDuracion();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selected.length} ejercicios',
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                Text(
                  '~$duracion min',
                  style: GoogleFonts.zenDots(
                    fontSize: 11,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _selected.isEmpty ? null : _guardarRutina,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8F135),
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF2A2A35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Guardar rutina',
                style: GoogleFonts.zenDots(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _estimarDuracion() {
    int totalSegundos = 0;
    for (final e in _selected) {
      totalSegundos += e.series * (30 + e.descansoSegundos);
    }
    return (totalSegundos / 60).ceil();
  }
  Future<Map<String, int>?> _mostrarDialogConfig(
    BuildContext context, {
    required String nombre,
    required int series,
    required int reps,
    required int descanso,
  }) {
    return showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ConfigDialog(
        nombre: nombre,
        seriesInicial: series,
        repsInicial: reps,
        descansoInicial: descanso,
      ),
    );
  }

  IconData _iconoPorEquipo(String equipo) {
    switch (equipo) {
      case 'Barra':
        return Icons.fitness_center;
      case 'Mancuerna':
        return Icons.fitness_center;
      case 'Máquina':
        return Icons.settings;
      case 'Polea':
        return Icons.swap_vert;
      case 'Peso corporal':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }
}

class _ConfigDialog extends StatefulWidget {
  final String nombre;
  final int seriesInicial;
  final int repsInicial;
  final int descansoInicial;

  const _ConfigDialog({
    required this.nombre,
    required this.seriesInicial,
    required this.repsInicial,
    required this.descansoInicial,
  });

  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  late final TextEditingController _seriesCtl;
  late final TextEditingController _repsCtl;
  late final TextEditingController _descansoCtl;

  @override
  void initState() {
    super.initState();
    _seriesCtl = TextEditingController(text: widget.seriesInicial.toString());
    _repsCtl = TextEditingController(text: widget.repsInicial.toString());
    _descansoCtl = TextEditingController(text: widget.descansoInicial.toString());
  }

  @override
  void dispose() {
    _seriesCtl.dispose();
    _repsCtl.dispose();
    _descansoCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.nombre,
        style: GoogleFonts.zenDots(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE8E8F0),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _campo('Series', _seriesCtl),
          const SizedBox(height: 12),
          _campo('Repeticiones', _repsCtl),
          const SizedBox(height: 12),
          _campo('Descanso (seg)', _descansoCtl),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80), fontSize: 13),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final s = int.tryParse(_seriesCtl.text) ?? 4;
            final r = int.tryParse(_repsCtl.text) ?? 12;
            final d = int.tryParse(_descansoCtl.text) ?? 60;
            Navigator.pop(context, {
              'series': s.clamp(1, 99),
              'reps': r.clamp(1, 999),
              'descanso': d.clamp(0, 600),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC8F135),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Agregar',
            style: GoogleFonts.zenDots(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _campo(String label, TextEditingController ctl) {
    return TextField(
      controller: ctl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.zenDots(color: const Color(0xFFE8E8F0), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.zenDots(color: const Color(0xFF6B6B80), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF16161A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC8F135)),
        ),
      ),
    );
  }
}
