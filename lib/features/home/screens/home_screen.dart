import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/routine.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _diaSemana() {
    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return dias[DateTime.now().weekday - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinasAsync = ref.watch(rutinasProvider);
    final historialAsync = ref.watch(historialProvider);

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
                data: (rutinas) => _buildRutinaDelDia(context, rutinas),
                loading: () => _buildCardPlaceholder(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              historialAsync.when(
                data: (historial) => _buildEstadisticas(historial),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              rutinasAsync.when(
                data: (rutinas) => _buildProximosEjercicios(rutinas),
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

  Widget _buildRutinaDelDia(BuildContext context, List<Routine> rutinas) {
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

    final rutina = rutinas.first;

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
            'Rutina del día',
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
                    rutina.nombre,
                    style: GoogleFonts.zenDots(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${rutina.totalEjercicios} ejercicios · ${rutina.duracionEstimadaMinutos} min',
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push('/workout', extra: rutina),
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

  Widget _buildEstadisticas(List<Map<String, dynamic>> historial) {
    final workoutsEstaSemana = _workoutsEstaSemana(historial);
    final totalMinutos = workoutsEstaSemana.fold<int>(0, (sum, w) => sum + (w['duracionMinutos'] as int? ?? 0));
    final totalEjercicios = workoutsEstaSemana.fold<int>(0, (sum, w) => sum + (w['ejerciciosCompletados'] as int? ?? 0));

    final stats = [
      {'icon': Icons.local_fire_department, 'value': '$totalMinutos', 'label': 'Min esta semana', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.timer, 'value': '${workoutsEstaSemana.length}', 'label': 'Entrenos', 'color': const Color(0xFFE8E8F0)},
      {'icon': Icons.fitness_center, 'value': '$totalEjercicios', 'label': 'Ejercicios', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.calendar_today, 'value': '${historial.length}', 'label': 'Total workouts', 'color': const Color(0xFFE8E8F0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
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
    );
  }

  List<Map<String, dynamic>> _workoutsEstaSemana(List<Map<String, dynamic>> historial) {
    final now = DateTime.now();
    final inicioSemana = now.subtract(Duration(days: now.weekday - 1));
    return historial.where((w) {
      final fecha = (w['fecha'] as dynamic);
      if (fecha == null) return false;
      if (fecha is Timestamp) {
        return fecha.toDate().isAfter(inicioSemana);
      }
      return false;
    }).toList();
  }

  Widget _buildProximosEjercicios(List<Routine> rutinas) {
    if (rutinas.isEmpty || rutinas.first.ejercicios.isEmpty) {
      return const SizedBox.shrink();
    }

    final ejercicios = rutinas.first.ejercicios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${rutinas.first.nombre} · Ejercicios',
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
