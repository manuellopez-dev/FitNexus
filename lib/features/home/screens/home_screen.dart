import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _buildRutinaDelDia(context),
              const SizedBox(height: 24),
              _buildEstadisticas(),
              const SizedBox(height: 24),
              _buildProximosEjercicios(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final nombre = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario';

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $nombre 👋',
                style: GoogleFonts.zenDots(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              Text(
                'Lunes · Día de pecho',
                style: GoogleFonts.zenDots(
                  fontSize: 13,
                  color: const Color(0xFF6B6B80),
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildRutinaDelDia(BuildContext context) {
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
                    'Pecho + Tríceps',
                    style: GoogleFonts.zenDots(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '6 ejercicios · 45 min',
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push('/workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8F135),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
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

  Widget _buildEstadisticas() {
    final stats = [
      {'icon': Icons.local_fire_department, 'value': '320', 'label': 'Calorías', 'color': const Color(0xFFC8F135)},
      {'icon': Icons.favorite, 'value': '78', 'label': 'BPM prom', 'color': const Color(0xFFFF4D6D)},
      {'icon': Icons.timer, 'value': '42m', 'label': 'Tiempo', 'color': const Color(0xFFE8E8F0)},
      {'icon': Icons.fitness_center, 'value': '6', 'label': 'Ejercicios', 'color': const Color(0xFFC8F135)},
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
                  Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 18,
                  ),
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

  Widget _buildProximosEjercicios() {
    final ejercicios = [
      {'nombre': 'Press de Banca', 'detalle': '4 series · 12 reps'},
      {'nombre': 'Aperturas', 'detalle': '3 series · 15 reps'},
      {'nombre': 'Fondos en paralelas', 'detalle': '3 series · 10 reps'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos ejercicios',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e['nombre']!,
                    style: GoogleFonts.zenDots(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  Text(
                    e['detalle']!,
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6B6B80),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A35)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Inicio', true),
          _navItem(Icons.fitness_center, 'Rutinas', false),
          _navItem(Icons.bar_chart, 'Progreso', false),
          _navItem(Icons.person, 'Perfil', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFFC8F135) : const Color(0xFF6B6B80),
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.zenDots(
            fontSize: 11,
            color: active ? const Color(0xFFC8F135) : const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }
}