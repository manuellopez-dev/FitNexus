import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../wear/providers/wear_session_provider.dart';

class MainTvScreen extends ConsumerStatefulWidget {
  const MainTvScreen({super.key});

  @override
  ConsumerState<MainTvScreen> createState() => _MainTvScreenState();
}

class _MainTvScreenState extends ConsumerState<MainTvScreen> {
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  void _solicitarInicio(dynamic rutina) async {
    final notifier = ref.read(wearSessionProvider.notifier);
    final session = ref.read(wearSessionProvider);
    if (session.currentExercise != null && !session.isComplete) {
      if (!mounted) return;
      Navigator.of(context).pushNamed('/tv/session');
      return;
    }
    try {
      await notifier.solicitarSesion(rutina);
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushNamed('/tv/session');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rutinasAsync = ref.watch(rutinasProvider);
    final perfilAsync = ref.watch(perfilProvider);
    final historialSemanalAsync = ref.watch(historialSemanalProvider);
    final historialAsync = ref.watch(historialProvider);
    final session = ref.watch(wearSessionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.goBack) {
              if (_selectedIndex > 0) {
                setState(() => _selectedIndex--);
                return KeyEventResult.handled;
              }
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              if (_selectedIndex < 2) {
                setState(() => _selectedIndex++);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            children: [
              _buildTopBar(perfilAsync),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildMainPanel(
                          rutinasAsync,
                          historialAsync,
                          historialSemanalAsync,
                          session,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _buildSideCards(rutinasAsync, historialSemanalAsync),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AsyncValue<dynamic> perfilAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A35), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFC8F135),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.black, size: 18),
                const SizedBox(width: 6),
                Text(
                  'FitNexus',
                  style: GoogleFonts.zenDots(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          _buildNavItem('Inicio', 0),
          const SizedBox(width: 16),
          _buildNavItem('Rutinas', 1),
          const SizedBox(width: 16),
          _buildNavItem('Historial', 2),
          const Spacer(),
          _buildStatsButton(),
          const SizedBox(width: 16),
          perfilAsync.when(
            data: (perfil) => Row(
              children: [
                Text(
                  perfil?.nombre ?? 'Usuario',
                  style: GoogleFonts.zenDots(
                    fontSize: 12,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2A2A35)),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF6B6B80),
                    size: 20,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Color(0xFFC8F135),
                strokeWidth: 2,
              ),
            ),
            error: (_, __) => const Icon(
              Icons.person,
              color: Color(0xFF6B6B80),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).pushNamed('/tv/stats'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics,
                  color: Color(0xFFC8F135), size: 16),
              const SizedBox(width: 8),
              Text(
                'Estadísticas',
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC8F135).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC8F135)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFFC8F135)
                  : const Color(0xFF6B6B80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainPanel(
    AsyncValue<List<dynamic>> rutinasAsync,
    AsyncValue<List<Map<String, dynamic>>> historialAsync,
    AsyncValue<List<Map<String, dynamic>>> historialSemanalAsync,
    dynamic session,
  ) {
    switch (_selectedIndex) {
      case 1:
        return _buildRutinasPanel(rutinasAsync);
      case 2:
        return _buildHistorialPanel(historialAsync);
      default:
        return _buildInicioPanel(rutinasAsync, historialSemanalAsync, session);
    }
  }

  Widget _buildInicioPanel(
    AsyncValue<List<dynamic>> rutinasAsync,
    AsyncValue<List<Map<String, dynamic>>> historialSemanalAsync,
    dynamic session,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF16161A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC8F135),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFC8F135),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      session.currentExercise != null && !session.isComplete
                          ? 'Entrenamiento en curso'
                          : 'Bienvenido a FitNexus',
                      style: GoogleFonts.zenDots(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.currentExercise != null && !session.isComplete
                          ? 'Sincronizado con tu teléfono'
                          : 'Elige una rutina para empezar',
                      style: GoogleFonts.zenDots(
                        fontSize: 12,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMainButton(rutinasAsync, session),
                const Spacer(),
                _buildQuickStats(session),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(AsyncValue<List<dynamic>> rutinasAsync, dynamic session) {
    final enCurso = session.currentExercise != null && !session.isComplete;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enCurso
            ? () => Navigator.of(context).pushNamed('/tv/session')
            : () {
                if (rutinasAsync.valueOrNull == null ||
                    rutinasAsync.valueOrNull!.isEmpty) return;
                _solicitarInicio(rutinasAsync.valueOrNull!.first);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFC8F135),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC8F135).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enCurso ? Icons.tv : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                enCurso ? 'Ver Entrenamiento' : 'Iniciar Entrenamiento',
                style: GoogleFonts.zenDots(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(dynamic session) {
    return Row(
      children: [
        _buildStatChip(
          Icons.timer_outlined,
          _formatTiempo(session.elapsedSeconds),
          const Color(0xFFC8F135),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.local_fire_department_outlined,
          '${session.calories} cal',
          const Color(0xFFFF4D6D),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.favorite_outline,
          '${session.heartRateBpm} bpm',
          const Color(0xFF5B8DEE),
        ),
      ],
    );
  }

  String _formatTiempo(int segundos) {
    final m = (segundos ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.zenDots(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRutinasPanel(AsyncValue<List<dynamic>> rutinasAsync) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: rutinasAsync.when(
        data: (rutinas) {
          if (rutinas.isEmpty) {
            return _buildEmptyState('No tienes rutinas creadas');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Elige una rutina',
                  style: GoogleFonts.zenDots(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rutinas.length,
                  itemBuilder: (context, index) => _buildRutinaTile(rutinas[index], autofocus: index == 0),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC8F135)),
        ),
        error: (_, __) => _buildEmptyState('Error al cargar rutinas'),
      ),
    );
  }

  Widget _buildRutinaTile(dynamic rutina, {bool autofocus = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        autofocus: autofocus,
        focusColor: const Color(0xFFC8F135).withValues(alpha: 0.2),
        hoverColor: const Color(0xFFC8F135).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        onTap: () => _solicitarInicio(rutina),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF16161A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8F135).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFFC8F135),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rutina.nombre,
                      style: GoogleFonts.zenDots(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8E8F0),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${rutina.totalEjercicios} ejercicios · ${rutina.duracionEstimadaMinutos} min',
                      style: GoogleFonts.zenDots(
                        fontSize: 11,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_arrow_rounded,
                  color: Color(0xFFC8F135), size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorialPanel(AsyncValue<List<Map<String, dynamic>>> historialAsync) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: historialAsync.when(
        data: (historial) {
          if (historial.isEmpty) {
            return _buildEmptyState('Aún no hay entrenamientos registrados');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Historial reciente',
                      style: GoogleFonts.zenDots(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${historial.length} entrenamientos',
                      style: GoogleFonts.zenDots(
                        fontSize: 12,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: historial.length.clamp(0, 20),
                  itemBuilder: (context, index) {
                    final item = historial[index];
                    final fecha = (item['fecha'] as Timestamp?)?.toDate();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFFC8F135), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['nombreRutina'] ?? 'Rutina',
                              style: GoogleFonts.zenDots(
                                fontSize: 13,
                                color: const Color(0xFFE8E8F0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item['duracionMinutos'] ?? 0} min',
                            style: GoogleFonts.zenDots(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5B8DEE),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            fecha != null ? _formatFecha(fecha) : '',
                            style: GoogleFonts.zenDots(
                              fontSize: 11,
                              color: const Color(0xFF6B6B80),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC8F135)),
        ),
        error: (_, __) => _buildEmptyState('Error al cargar historial'),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }

  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center,
              color: Color(0xFF2A2A35), size: 56),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.zenDots(
              fontSize: 13,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideCards(
    AsyncValue<List<dynamic>> rutinasAsync,
    AsyncValue<List<Map<String, dynamic>>> historialSemanalAsync,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildRoutinePreviewCard(rutinasAsync),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildProgressCard(historialSemanalAsync),
        ),
      ],
    );
  }

  Widget _buildRoutinePreviewCard(AsyncValue<List<dynamic>> rutinasAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list, color: Color(0xFFC8F135), size: 20),
              const SizedBox(width: 8),
              Text(
                'Mis Rutinas',
                style: GoogleFonts.zenDots(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: rutinasAsync.when(
              data: (rutinas) {
                if (rutinas.isEmpty) {
                  return Center(
                    child: Text(
                      'Sin rutinas disponibles',
                      style: GoogleFonts.zenDots(
                        fontSize: 11,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: rutinas.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final rutina = rutinas[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _solicitarInicio(rutina),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC8F135)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Color(0xFFC8F135),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rutina.nombre,
                                      style: GoogleFonts.zenDots(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFE8E8F0),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${rutina.totalEjercicios} ejercicios · ${rutina.duracionEstimadaMinutos} min',
                                      style: GoogleFonts.zenDots(
                                        fontSize: 10,
                                        color: const Color(0xFF6B6B80),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Color(0xFF6B6B80), size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC8F135),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Error al cargar rutinas',
                  style: GoogleFonts.zenDots(
                    fontSize: 11,
                    color: const Color(0xFFFF4D6D),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      AsyncValue<List<Map<String, dynamic>>> historialSemanalAsync) {
    final historial = historialSemanalAsync.valueOrNull ?? <Map<String, dynamic>>[];

    final minutosPorDia = List<double>.filled(7, 0);
    for (final item in historial) {
      final fecha = (item['fecha'] as Timestamp?)?.toDate();
      if (fecha == null) continue;
      final index = (fecha.weekday - 1) % 7;
      minutosPorDia[index] += (item['duracionMinutos'] as num?)?.toDouble() ?? 0;
    }
    final maxMinutos = minutosPorDia.fold<double>(0, (a, b) => a > b ? a : b);

    final minutosTotales = historial.fold<int>(
        0, (sum, item) => sum + ((item['duracionMinutos'] as num?)?.toInt() ?? 0));
    final sesiones = historial.length;
    final racha = _calcularRacha(historial);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFFC8F135), size: 20),
              const SizedBox(width: 8),
              Text(
                'Progreso Semanal',
                style: GoogleFonts.zenDots(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final factor = maxMinutos > 0 ? minutosPorDia[i] / maxMinutos : 0.0;
                return _buildMiniBar(factor, _diaCorto(i), minutosPorDia[i]);
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('Sesiones', '$sesiones', const Color(0xFFC8F135)),
              _buildProgressStat('Minutos', '$minutosTotales', const Color(0xFF5B8DEE)),
              _buildProgressStat('Racha', racha == 1 ? '1 día' : '$racha días',
                  const Color(0xFFFF4D6D)),
            ],
          ),
        ],
      ),
    );
  }

  int _calcularRacha(List<Map<String, dynamic>> historial) {
    final dias = <DateTime>{};
    for (final item in historial) {
      final fecha = (item['fecha'] as Timestamp?)?.toDate();
      if (fecha != null) dias.add(DateTime(fecha.year, fecha.month, fecha.day));
    }
    if (dias.isEmpty) return 0;

    var hoy = DateTime.now();
    hoy = DateTime(hoy.year, hoy.month, hoy.day);
    if (!dias.contains(hoy)) {
      hoy = hoy.subtract(const Duration(days: 1));
      if (!dias.contains(hoy)) return 0;
    }

    int racha = 0;
    while (dias.contains(hoy)) {
      racha++;
      hoy = hoy.subtract(const Duration(days: 1));
    }
    return racha;
  }

  String _diaCorto(int index) {
    const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return dias[index];
  }

  Widget _buildMiniBar(double height, String label, double minutos) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (minutos > 0)
          Text(
            '${minutos.round()}',
            style: GoogleFonts.zenDots(
              fontSize: 8,
              color: const Color(0xFF6B6B80),
            ),
          ),
        Container(
          width: 24,
          height: 60 * height,
          decoration: BoxDecoration(
            color: height > 0
                ? const Color(0xFFC8F135)
                : const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.zenDots(
            fontSize: 9,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.zenDots(
            fontSize: 9,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }
}
