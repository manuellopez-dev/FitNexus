import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class MainTvScreen extends ConsumerStatefulWidget {
  const MainTvScreen({super.key});

  @override
  ConsumerState<MainTvScreen> createState() => _MainTvScreenState();
}

class _MainTvScreenState extends ConsumerState<MainTvScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rutinasAsync = ref.watch(rutinasProvider);
    final perfilAsync = ref.watch(perfilProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
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
                      child: _buildMainPanel(rutinasAsync),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _buildSideCards(rutinasAsync),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildNavItem(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
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
    );
  }

  Widget _buildMainPanel(AsyncValue<List<dynamic>> rutinasAsync) {
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
                      'Bienvenido a FitNexus',
                      style: GoogleFonts.zenDots(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu entrenador personal inteligente',
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
                _buildMainButton(),
                const Spacer(),
                _buildQuickStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return Container(
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
          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
          const SizedBox(width: 8),
          Text(
            'Iniciar Entrenamiento',
            style: GoogleFonts.zenDots(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatChip(Icons.timer_outlined, '0:00', const Color(0xFFC8F135)),
        const SizedBox(width: 12),
        _buildStatChip(Icons.local_fire_department_outlined, '0 cal', const Color(0xFFFF4D6D)),
        const SizedBox(width: 12),
        _buildStatChip(Icons.favorite_outline, '72 bpm', const Color(0xFF5B8DEE)),
      ],
    );
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

  Widget _buildSideCards(AsyncValue<List<dynamic>> rutinasAsync) {
    return Column(
      children: [
        Expanded(
          child: _buildRoutinePreviewCard(rutinasAsync),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildProgressCard(),
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
              Icon(Icons.list, color: const Color(0xFFC8F135), size: 20),
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
                    return Container(
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
                              color: const Color(0xFFC8F135).withValues(alpha: 0.15),
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
                        ],
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

  Widget _buildProgressCard() {
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
              Icon(Icons.trending_up, color: const Color(0xFFC8F135), size: 20),
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
              children: [
                _buildMiniBar(0.3, 'L'),
                _buildMiniBar(0.7, 'M'),
                _buildMiniBar(0.5, 'M'),
                _buildMiniBar(0.9, 'J'),
                _buildMiniBar(0.4, 'V'),
                _buildMiniBar(0.0, 'S'),
                _buildMiniBar(0.0, 'D'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('Sesiones', '3', const Color(0xFFC8F135)),
              _buildProgressStat('Minutos', '45', const Color(0xFF5B8DEE)),
              _buildProgressStat('Racha', '5 días', const Color(0xFFFF4D6D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
