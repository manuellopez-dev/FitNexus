import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../wear/providers/wear_session_provider.dart';

class StatsTvScreen extends ConsumerStatefulWidget {
  const StatsTvScreen({super.key});

  @override
  ConsumerState<StatsTvScreen> createState() => _StatsTvScreenState();
}

class _StatsTvScreenState extends ConsumerState<StatsTvScreen> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(wearSessionProvider);
    final historialSemanalAsync = ref.watch(historialSemanalProvider);
    final historialAsync = ref.watch(historialProvider);

    final semana = historialSemanalAsync.valueOrNull ?? <Map<String, dynamic>>[];
    final historial = historialAsync.valueOrNull ?? <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildKpiCards(semana, historial, session),
              const SizedBox(height: 24),
              Expanded(
                child: _buildChartSection(semana),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics, color: Color(0xFFC8F135), size: 24),
        const SizedBox(width: 12),
        Text(
          'Estadísticas',
          style: GoogleFonts.zenDots(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2A35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back,
                      color: Color(0xFF6B6B80), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Volver',
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
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Text(
            'Última semana',
            style: GoogleFonts.zenDots(
              fontSize: 12,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ),
      ],
    );
  }

  int _minutos(List<Map<String, dynamic>> items) =>
      items.fold<int>(0, (sum, item) => sum + ((item['duracionMinutos'] as num?)?.toInt() ?? 0));

  String _variacion(int actual, int anterior) {
    if (anterior == 0) return actual > 0 ? '+100%' : '0%';
    final delta = ((actual - anterior) / anterior * 100).round();
    return delta >= 0 ? '+$delta%' : '$delta%';
  }

  List<Map<String, dynamic>> _entre(
      List<Map<String, dynamic>> historial, DateTime inicio, DateTime fin) {
    return historial.where((item) {
      final fecha = (item['fecha'] as Timestamp?)?.toDate();
      if (fecha == null) return false;
      return !fecha.isBefore(inicio) && fecha.isBefore(fin);
    }).toList();
  }

  Widget _buildKpiCards(
    List<Map<String, dynamic>> semana,
    List<Map<String, dynamic>> historial,
    dynamic session,
  ) {
    final ahora = DateTime.now();
    final inicio =
        DateTime(ahora.year, ahora.month, ahora.day - ahora.weekday + 1);
    final inicioPrev = inicio.subtract(const Duration(days: 7));

    final semanaAnterior = _entre(historial, inicioPrev, inicio);
    final minutos = _minutos(semana);
    final minutosPrev = _minutos(semanaAnterior);
    final calorias = minutos * 8;
    final caloriasPrev = minutosPrev * 8;
    final racha = _rachaActual(historial);

    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            'Calorías Quemadas',
            '$calorias',
            'kcal',
            const Color(0xFFC8F135),
            Icons.local_fire_department_outlined,
            _variacion(calorias, caloriasPrev),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Tiempo Total',
            '$minutos',
            'min',
            const Color(0xFFFF4D6D),
            Icons.timer_outlined,
            _variacion(minutos, minutosPrev),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Sesiones',
            '${semana.length}',
            'esta semana',
            const Color(0xFF5B8DEE),
            Icons.fitness_center,
            _variacion(semana.length, semanaAnterior.length),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'BPM actual',
            '${session.heartRateBpm}',
            'lpm',
            const Color(0xFFFF9800),
            Icons.favorite_outline,
            'racha $racha${racha == 1 ? ' día' : ' días'}',
          ),
        ),
      ],
    );
  }

  int _rachaActual(List<Map<String, dynamic>> historial) {
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

  Widget _buildKpiCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
    String change,
  ) {
    final isPositive = !change.startsWith('-') && change != '0%';

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFC8F135).withValues(alpha: 0.15)
                      : const Color(0xFFFF4D6D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.zenDots(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? const Color(0xFFC8F135)
                        : const Color(0xFFFF4D6D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.zenDots(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: GoogleFonts.zenDots(
                    fontSize: 12,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.zenDots(
              fontSize: 11,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<Map<String, dynamic>> semana) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rendimiento Semanal',
                style: GoogleFonts.zenDots(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Minutos', const Color(0xFFC8F135)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Calorías', const Color(0xFFFF4D6D)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: semana.isEmpty
                ? Center(
                    child: Text(
                      'Sin datos esta semana',
                      style: GoogleFonts.zenDots(
                        fontSize: 13,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  )
                : _buildBarChart(semana),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.zenDots(
            fontSize: 11,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> semana) {
    final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final datosMinutos = List<int>.filled(7, 0);

    for (final item in semana) {
      final fecha = (item['fecha'] as Timestamp?)?.toDate();
      if (fecha == null) continue;
      final index = (fecha.weekday - 1) % 7;
      datosMinutos[index] += (item['duracionMinutos'] as num?)?.toInt() ?? 0;
    }

    final datosCalorias = datosMinutos.map((m) => m * 8).toList();
    final maxMinutos =
        datosMinutos.fold<int>(0, (a, b) => a > b ? a : b).toDouble();
    final maxCalorias =
        datosCalorias.fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final alturaMin = maxMinutos > 0 ? datosMinutos[index] / maxMinutos : 0.0;
        final alturaCal = maxCalorias > 0 ? datosCalorias[index] / maxCalorias : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 16,
                      height: 120 * alturaMin,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8F135),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 16,
                      height: 120 * alturaCal,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D6D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${datosMinutos[index]}m',
                  style: GoogleFonts.zenDots(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: datosMinutos[index] > 0
                        ? const Color(0xFF16161A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dias[index],
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: datosMinutos[index] > 0
                          ? const Color(0xFFC8F135)
                          : const Color(0xFF6B6B80),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
