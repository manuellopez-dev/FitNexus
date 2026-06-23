import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const _diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialProvider);
    final historialSemanalAsync = ref.watch(historialSemanalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        title: Text(
          'Progreso',
          style: GoogleFonts.zenDots(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE8E8F0)),
          onPressed: () => context.pop(),
        ),
      ),
      body: historialSemanalAsync.when(
        data: (semanal) => historialAsync.when(
          data: (total) => _buildContent(context, semanal, total),
          loading: () => const _LoadingWidget(),
          error: (_, __) => const _ErrorWidget(),
        ),
        loading: () => const _LoadingWidget(),
        error: (_, __) => const _ErrorWidget(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Map<String, dynamic>> semanal,
    List<Map<String, dynamic>> total,
  ) {
    final minutosPorDia = _calcularMinutosPorDia(semanal);
    final totalMinutosSemanal = minutosPorDia.values.fold<int>(0, (a, b) => a + b);
    final streak = _calcularRacha(total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumen(totalMinutosSemanal, semanal.length, total.length, streak),
          const SizedBox(height: 28),
          Text(
            'Esta semana',
            style: GoogleFonts.zenDots(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          const SizedBox(height: 16),
          _buildGraficoSemanal(minutosPorDia),
          const SizedBox(height: 28),
          Text(
            'Últimos workouts',
            style: GoogleFonts.zenDots(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          const SizedBox(height: 12),
          ..._buildWorkoutsRecientes(total),
        ],
      ),
    );
  }

  Map<int, int> _calcularMinutosPorDia(List<Map<String, dynamic>> semanal) {
    final mapa = <int, int>{};
    for (final w in semanal) {
      final ts = w['fecha'] as dynamic;
      if (ts == null) continue;
      final fecha = (ts as dynamic).toDate() as DateTime;
      final dia = fecha.weekday; // 1=lunes .. 7=domingo
      final mins = w['duracionMinutos'] as int? ?? 0;
      mapa[dia] = (mapa[dia] ?? 0) + mins;
    }
    return mapa;
  }

  int _calcularRacha(List<Map<String, dynamic>> historial) {
    if (historial.isEmpty) return 0;
    final fechas = historial.map((w) {
      final ts = w['fecha'] as dynamic;
      if (ts == null) return null;
      return (ts as dynamic).toDate() as DateTime;
    }).whereType<DateTime>().toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (fechas.isEmpty) return 0;

    int racha = 1;
    for (int i = 1; i < fechas.length; i++) {
      final diff = fechas[i - 1].difference(fechas[i]).inDays;
      if (diff == 1) {
        racha++;
      } else {
        break;
      }
    }
    return racha;
  }

  Widget _buildResumen(int minSemana, int sesiones, int total, int racha) {
    final stats = [
      {'icon': Icons.local_fire_department, 'value': '$minSemana', 'label': 'Min esta semana', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.timer, 'value': '$sesiones', 'label': 'Sesiones', 'color': const Color(0xFFE8E8F0)},
      {'icon': Icons.fitness_center, 'value': '$total', 'label': 'Total', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.whatshot, 'value': '$racha', 'label': 'Racha (días)', 'color': const Color(0xFFE8E8F0)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: GoogleFonts.zenDots(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: stat['color'] as Color,
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraficoSemanal(Map<int, int> minutosPorDia) {
    final maxMin = minutosPorDia.values.isEmpty
        ? 1
        : minutosPorDia.values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dia = i + 1; // 1=lunes
              final mins = minutosPorDia[dia] ?? 0;
              final altura = maxMin > 0 ? (mins / maxMin).clamp(0.0, 1.0) : 0.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$mins',
                    style: GoogleFonts.zenDots(
                      fontSize: 10,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 28,
                    height: 120 * altura,
                    decoration: BoxDecoration(
                      color: mins > 0
                          ? const Color(0xFFC8F135)
                          : const Color(0xFF2A2A35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _diasSemana[i],
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      color: mins > 0
                          ? const Color(0xFFE8E8F0)
                          : const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWorkoutsRecientes(List<Map<String, dynamic>> historial) {
    if (historial.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No hay workouts registrados',
              style: GoogleFonts.zenDots(
                fontSize: 13,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ),
        ),
      ];
    }

    final recientes = historial.take(5).toList();
    return recientes.map((w) {
      final nombre = w['nombreRutina'] as String? ?? 'Workout';
      final duracion = w['duracionMinutos'] as int? ?? 0;
      final ejercicios = w['ejerciciosCompletados'] as int? ?? 0;
      final ts = w['fecha'] as dynamic;
      final fecha = ts != null ? (ts as dynamic).toDate() as DateTime : null;
      final fechaStr = fecha != null
          ? '${fecha.day}/${fecha.month}'
          : '';

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Color(0xFFC8F135),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: GoogleFonts.zenDots(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duracion min · $ejercicios ejercicios',
                    style: GoogleFonts.zenDots(
                      fontSize: 12,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              fechaStr,
              style: GoogleFonts.zenDots(
                fontSize: 11,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFC8F135)),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: const Color(0xFF6B6B80), size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar progreso',
              style: GoogleFonts.zenDots(
                fontSize: 14,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
