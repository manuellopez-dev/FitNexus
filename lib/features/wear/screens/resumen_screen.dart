import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wear_session_provider.dart';

class ResumenScreen extends ConsumerWidget {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wearSessionProvider);

    if (!session.isComplete) {
      return Container(
        color: const Color(0xFF0D0D0F),
        child: Center(
          child: Text(
            'Sin sesión completada',
            style: GoogleFonts.zenDots(
              fontSize: 10,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0D0D0F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildCompletionCircle(),
              const SizedBox(height: 10),
              Expanded(
                child: _buildStats(session),
              ),
              const SizedBox(height: 8),
              _buildOverallBar(session),
              const SizedBox(height: 8),
              _buildButton(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assessment, color: const Color(0xFFC8F135), size: 12),
        const SizedBox(width: 4),
        Text(
          'Resumen',
          style: GoogleFonts.zenDots(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCircle() {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E1E24),
          border: Border.all(
            color: const Color(0xFFC8F135),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC8F135).withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.check,
            color: Color(0xFFC8F135),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(WearSessionState session) {
    final duracionMin = session.elapsedSeconds ~/ 60;
    final duracionSeg = session.elapsedSeconds % 60;
    final duracion = '${duracionMin.toString().padLeft(2, '0')}:${duracionSeg.toString().padLeft(2, '0')}';
    
    final maxBpm = 180;
    final bpmProgress = (session.heartRateBpm / maxBpm).clamp(0.0, 1.0);
    final calProgress = (session.calories / 500).clamp(0.0, 1.0);
    final ejerciciosProgress = session.totalExercises > 0
        ? (session.currentExerciseIndex + 1) / session.totalExercises
        : 0.0;
    final seriesProgress = session.totalSets > 0
        ? session.currentSet / session.totalSets
        : 0.0;

    return Column(
      children: [
        _buildStatBar(
          label: 'Duración',
          value: duracion,
          progress: ejerciciosProgress,
          color: const Color(0xFFC8F135),
          indicatorColor: const Color(0xFFC8F135),
        ),
        const SizedBox(height: 8),
        _buildStatBar(
          label: 'Calorías',
          value: '${session.calories}',
          progress: calProgress,
          color: const Color(0xFFFF4D6D),
          indicatorColor: const Color(0xFFFF4D6D),
        ),
        const SizedBox(height: 8),
        _buildStatBar(
          label: 'BPM Prom.',
          value: '${session.heartRateBpm}',
          progress: bpmProgress,
          color: const Color(0xFF5B8DEE),
          indicatorColor: const Color(0xFF5B8DEE),
        ),
        const SizedBox(height: 8),
        _buildStatBar(
          label: 'Series',
          value: '${session.currentSet}/${session.totalSets}',
          progress: seriesProgress,
          color: const Color(0xFFE8E8F0),
          indicatorColor: const Color(0xFFE8E8F0),
        ),
        const SizedBox(height: 8),
        _buildStatBar(
          label: 'Ejercicios',
          value: '${session.currentExerciseIndex + 1}/${session.totalExercises}',
          progress: ejerciciosProgress,
          color: const Color(0xFFC8F135),
          indicatorColor: const Color(0xFFC8F135),
        ),
      ],
    );
  }

  Widget _buildStatBar({
    required String label,
    required String value,
    required double progress,
    required Color color,
    required Color indicatorColor,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.zenDots(
                      fontSize: 8,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.zenDots(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A35),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: indicatorColor.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverallBar(WearSessionState session) {
    final totalPoints = session.elapsedSeconds > 0
        ? (session.calories * 0.3 + session.heartRateBpm * 0.4 + (session.currentExerciseIndex + 1) * 10 * 0.3)
        : 0.0;
    final maxPoints = 500 * 0.3 + 180 * 0.4 + (session.totalExercises > 0 ? session.totalExercises : 1) * 10 * 0.3;
    final overallProgress = maxPoints > 0 ? (totalPoints / maxPoints).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rendimiento General',
              style: GoogleFonts.zenDots(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B6B80),
              ),
            ),
            Text(
              '${(overallProgress * 100).toInt()}%',
              style: GoogleFonts.zenDots(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC8F135),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A35),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: overallProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8F135), Color(0xFFA0D020)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () => ref.invalidate(wearSessionProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8F135),
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Finalizar',
          style: GoogleFonts.zenDots(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
