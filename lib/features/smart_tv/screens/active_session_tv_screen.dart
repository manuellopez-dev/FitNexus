import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/exercise_gif_mapping.dart';
import '../../wear/providers/wear_session_provider.dart';

class ActiveSessionTvScreen extends ConsumerWidget {
  const ActiveSessionTvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    if (session.currentExercise == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0F),
        body: Center(
          child: Text(
            'Sin sesión activa',
            style: GoogleFonts.zenDots(
              fontSize: 18,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ),
      );
    }

    final ejercicio = session.currentExercise!;
    final gifUrl = exerciseGifMapping[ejercicio.nombre] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildMainPanel(gifUrl, ejercicio.nombre, ejercicio.musculo, session),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: _buildSidePanel(session, ejercicio),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainPanel(String gifUrl, String nombre, String musculo, WearSessionState session) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A35)),
            ),
            child: gifUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      gifUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: const Color(0xFFC8F135),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Cargando ejercicio...',
                                style: GoogleFonts.zenDots(
                                  fontSize: 12,
                                  color: const Color(0xFF6B6B80),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildControlButton(
                'Siguiente Serie',
                const Color(0xFFC8F135),
                Icons.skip_next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildControlButton(
                'Siguiente Ejercicio',
                const Color(0xFFC8F135),
                Icons.fast_forward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: const Color(0xFF2A2A35),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Vista del ejercicio',
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

  Widget _buildControlButton(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(WearSessionState session, dynamic ejercicio) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildExerciseInfo(ejercicio, session),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(child: _buildStatusBlock('EN VIVO', const Color(0xFFFF4D6D), Icons.circle, true)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatusBlock('ACTIVO', const Color(0xFFC8F135), Icons.check_circle, true)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: _buildStatsGrid(session),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 1,
          child: _buildQuickActions(),
        ),
      ],
    );
  }

  Widget _buildExerciseInfo(dynamic ejercicio, WearSessionState session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC8F135).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ejercicio.musculo,
              style: GoogleFonts.zenDots(
                fontSize: 10,
                color: const Color(0xFFC8F135),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ejercicio.nombre,
            style: GoogleFonts.zenDots(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE8E8F0),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.repeat, '${ejercicio.series} series', const Color(0xFF5B8DEE)),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.tag, '${ejercicio.reps} reps', const Color(0xFFC8F135)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBlock(String label, Color color, IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.15) : const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? color : const Color(0xFF2A2A35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? color : const Color(0xFF6B6B80),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? color : const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(WearSessionState session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItem('SERIE', '${session.currentSet}/${session.totalSets}', const Color(0xFFC8F135))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatItem('EJERCICIO', '${session.currentExerciseIndex + 1}/${session.totalExercises}', const Color(0xFF5B8DEE))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatItem('TIEMPO', _formatSegundos(session.elapsedSeconds), const Color(0xFFE8E8F0))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatItem('CALORÍAS', '${session.calories}', const Color(0xFFFF4D6D))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatItem('BPM', '${session.heartRateBpm}', const Color(0xFFFF4D6D))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatItem('DESCANSO', _formatSegundos(session.restSeconds), const Color(0xFF5B8DEE))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.zenDots(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 8,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildCircularAction(Icons.pause, const Color(0xFF5B8DEE)),
        const SizedBox(width: 8),
        _buildCircularAction(Icons.volume_up, const Color(0xFFC8F135)),
        const SizedBox(width: 8),
        _buildCircularAction(Icons.refresh, const Color(0xFFFF4D6D)),
        const SizedBox(width: 8),
        _buildCircularAction(Icons.settings, const Color(0xFF6B6B80)),
      ],
    );
  }

  Widget _buildCircularAction(IconData icon, Color color) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  String _formatSegundos(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
