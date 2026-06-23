import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/routine.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  String _diaSemana() => _diasSemana[DateTime.now().weekday - 1];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinasAsync = ref.watch(rutinasProvider);
    final historialAsync = ref.watch(historialProvider);
    final historialSemanalAsync = ref.watch(historialSemanalProvider);
    final perfilAsync = ref.watch(perfilProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(ref),
              const SizedBox(height: 24),
              rutinasAsync.when(
                data: (rutinas) => perfilAsync.when(
                  data: (perfil) => _buildRutinaDelDia(context, rutinas, perfil),
                  loading: () => _buildCardPlaceholder(),
                  error: (_, __) => _buildRutinaDelDia(context, rutinas, null),
                ),
                loading: _buildCardPlaceholder,
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              historialSemanalAsync.when(
                data: (semanal) => historialAsync.when(
                  data: (total) => _buildEstadisticas(context, semanal, total.length),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              rutinasAsync.when(
                data: (rutinas) => perfilAsync.when(
                  data: (perfil) => _buildProximosEjercicios(rutinas, perfil),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => _buildProximosEjercicios(rutinas, null),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: const Center(child: CircularProgressIndicator(color: Color(0xFFC8F135))),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final nombre = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $nombre 👋',
                style: GoogleFonts.zenDots(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${_diaSemana()} · Día de entrenamiento',
                style: GoogleFonts.zenDots(
                  fontSize: 11,
                  color: const Color(0xFF6B6B80),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: const Icon(
            Icons.notifications_none,
            color: Color(0xFF6B6B80),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildRutinaDelDia(BuildContext context, List<Routine> rutinas, dynamic perfil) {
    if (rutinas.isEmpty) {
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
            Icon(Icons.fitness_center, color: const Color(0xFF6B6B80), size: 32),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera rutina',
              style: GoogleFonts.zenDots(
                fontSize: 12,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ],
        ),
      );
    }

    // Buscar rutina asignada al día de hoy
    final hoy = DateTime.now().weekday; // 1=lunes
    final rutinaPorDia = (perfil?.rutinaPorDia as Map<String, dynamic>?) ?? {};
    final rutinaIdHoy = rutinaPorDia[hoy.toString()] as String?;
    final rutina = rutinaIdHoy != null && rutinaIdHoy.isNotEmpty
        ? rutinas.where((r) => r.id == rutinaIdHoy).firstOrNull
        : null;

    // Fallback: si no hay asignación, mostrar la primera rutina
    final rutinaFinal = rutina ?? rutinas.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rutina != null ? 'Rutina de hoy' : 'Rutina del día',
            style: GoogleFonts.zenDots(
              fontSize: 12,
              color: const Color(0xFF6B6B80),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rutinaFinal.nombre,
                    style: GoogleFonts.zenDots(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${rutinaFinal.totalEjercicios} ejercicios · ${rutinaFinal.duracionEstimadaMinutos} min',
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push('/workout', extra: rutinaFinal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8F135),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Iniciar',
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas(BuildContext context, List<Map<String, dynamic>> semanal, int total) {
    final totalMinutos = semanal.fold<int>(0, (sum, w) => sum + (w['duracionMinutos'] as int? ?? 0));
    final totalEjercicios = semanal.fold<int>(0, (sum, w) => sum + (w['ejerciciosCompletados'] as int? ?? 0));

    final stats = [
      {'icon': Icons.local_fire_department, 'value': '$totalMinutos', 'label': 'Min esta semana', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.timer, 'value': '${semanal.length}', 'label': 'Entrenos', 'color': const Color(0xFFE8E8F0)},
      {'icon': Icons.fitness_center, 'value': '$totalEjercicios', 'label': 'Ejercicios', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.calendar_today, 'value': '$total', 'label': 'Total workouts', 'color': const Color(0xFFE8E8F0)},
    ];

    return GestureDetector(
      onTap: () => context.push('/progress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estadísticas',
                style: GoogleFonts.zenDots(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              Icon(Icons.chevron_right, color: const Color(0xFF6B6B80), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
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
        ),
      ],
      ),
    );
  }

  Widget _buildProximosEjercicios(List<Routine> rutinas, dynamic perfil) {
    if (rutinas.isEmpty) return const SizedBox.shrink();

    final hoy = DateTime.now().weekday;
    final rutinaPorDia = (perfil?.rutinaPorDia as Map<String, dynamic>?) ?? {};
    final rutinaIdHoy = rutinaPorDia[hoy.toString()] as String?;
    final rutina = rutinaIdHoy != null && rutinaIdHoy.isNotEmpty
        ? rutinas.where((r) => r.id == rutinaIdHoy).firstOrNull
        : null;
    final rutinaFinal = rutina ?? rutinas.first;

    if (rutinaFinal.ejercicios.isEmpty) return const SizedBox.shrink();

    final ejercicios = rutinaFinal.ejercicios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${rutinaFinal.nombre} · Ejercicios',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 12),
        ...ejercicios.map((e) => Container(
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFFC8F135),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: GoogleFonts.zenDots(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE8E8F0),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${e.series} series · ${e.reps} reps',
                      style: GoogleFonts.zenDots(
                        fontSize: 13,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${e.descansoSegundos}s',
                style: GoogleFonts.zenDots(
                  fontSize: 11,
                  color: const Color(0xFF6B6B80),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
