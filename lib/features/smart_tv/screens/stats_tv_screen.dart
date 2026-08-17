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
    final historialAsync = ref.watch(historialSemanalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildKpiCards(session),
              const SizedBox(height: 24),
              Expanded(
                child: _buildChartSection(historialAsync),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, color: const Color(0xFFC8F135), size: 24),
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

  Widget _buildKpiCards(WearSessionState session) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            'Calorías Quemadas',
            '${session.calories > 0 ? session.calories : 320}',
            'kcal',
            const Color(0xFFC8F135),
            Icons.local_fire_department_outlined,
            '+12%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Tiempo Total',
            '${session.elapsedSeconds > 0 ? (session.elapsedSeconds ~/ 60) : 45}',
            'min',
            const Color(0xFFFF4D6D),
            Icons.timer_outlined,
            '+8%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Sesiones',
            '12',
            'esta semana',
            const Color(0xFF5B8DEE),
            Icons.fitness_center,
            '+25%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'BPM Promedio',
            '${session.heartRateBpm > 0 ? session.heartRateBpm : 82}',
            'lpm',
            const Color(0xFFFF9800),
            Icons.favorite_outline,
            '-3%',
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
    String change,
  ) {
    final isPositive = change.startsWith('+');

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
                    color: isPositive ? const Color(0xFFC8F135) : const Color(0xFFFF4D6D),
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

  Widget _buildChartSection(AsyncValue<List<Map<String, dynamic>>> historialAsync) {
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
            child: historialAsync.when(
              data: (historial) => _buildBarChart(historial),
              loading: () => _buildBarChart([]),
              error: (_, __) => _buildBarChart([]),
            ),
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

  Widget _buildBarChart(List<Map<String, dynamic>> historial) {
    final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final datosMinutos = [45, 60, 30, 75, 50, 0, 0];
    final datosCalorias = [320, 450, 210, 560, 380, 0, 0];
    final maxValor = 75.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final alturaMin = (datosMinutos[index] / maxValor);
        final alturaCal = (datosCalorias[index] / 560);

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
