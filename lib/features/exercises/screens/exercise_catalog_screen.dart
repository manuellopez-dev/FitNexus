import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/exercise.dart';

class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState
    extends ConsumerState<ExerciseCatalogScreen>
    with SingleTickerProviderStateMixin {
  String? _musculoSeleccionado;

  List<ExerciseCatalogItem> _filtrarPorMusculo(
      List<ExerciseCatalogItem> catalogo) {
    if (_musculoSeleccionado == null) return catalogo;
    return catalogo
        .where((e) => e.musculo == _musculoSeleccionado)
        .toList();
  }

  List<String> _musculosDisponibles(List<ExerciseCatalogItem> catalogo) {
    final musculos = catalogo.map((e) => e.musculo).toSet().toList();
    musculos.sort();
    return musculos;
  }

  void _abrirDetalle(ExerciseCatalogItem ejercicio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExerciseDetailSheet(ejercicio: ejercicio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogoAsync = ref.watch(catalogoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        title: Text(
          'Ejercicios',
          style: GoogleFonts.zenDots(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: catalogoAsync.when(
        data: (catalogo) => _buildContent(catalogo),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC8F135)),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off,
                    color: const Color(0xFF6B6B80), size: 48),
                const SizedBox(height: 16),
                Text(
                  'No se pudo cargar el catálogo',
                  style: GoogleFonts.zenDots(
                    fontSize: 14,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(catalogoProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8F135),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<ExerciseCatalogItem> catalogo) {
    final musculos = _musculosDisponibles(catalogo);
    final filtrados = _filtrarPorMusculo(catalogo);

    return Column(
      children: [
        _buildMusculoChips(musculos),
        const SizedBox(height: 8),
        Expanded(child: _buildGridEjercicios(filtrados)),
      ],
    );
  }

  Widget _buildMusculoChips(List<String> musculos) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: musculos.length + 1,
        itemBuilder: (context, index) {
          final label = index == 0 ? 'Todos' : musculos[index - 1];
          final seleccionado = index == 0
              ? _musculoSeleccionado == null
              : _musculoSeleccionado == musculos[index - 1];

          return GestureDetector(
            onTap: () => setState(() {
              _musculoSeleccionado =
                  index == 0 ? null : musculos[index - 1];
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: seleccionado
                    ? const Color(0xFFC8F135)
                    : const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: seleccionado
                      ? const Color(0xFFC8F135)
                      : const Color(0xFF2A2A35),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.zenDots(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: seleccionado
                        ? Colors.black
                        : const Color(0xFF6B6B80),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridEjercicios(List<ExerciseCatalogItem> ejercicios) {
    if (ejercicios.isEmpty) {
      return Center(
        child: Text(
          'Sin ejercicios en esta categoría',
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: ejercicios.length,
      itemBuilder: (context, index) {
        final ejercicio = ejercicios[index];
        return _ExerciseCard(
          ejercicio: ejercicio,
          onTap: () => _abrirDetalle(ejercicio),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseCatalogItem ejercicio;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.ejercicio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ejercicio.gifUrl.isNotEmpty
                  ? Image.network(
                      ejercicio.gifUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : _placeholderIcon(),
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholderIcon(),
                    )
                  : _placeholderIcon(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio.nombre,
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE8E8F0),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ejercicio.musculo}',
                    style: GoogleFonts.zenDots(
                      fontSize: 9,
                      color: const Color(0xFF6B6B80),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: const Color(0xFF16161A),
      child: Center(
        child: Icon(
          _iconoPorEquipo(ejercicio.equipo),
          color: const Color(0xFF2A2A35),
          size: 32,
        ),
      ),
    );
  }

  IconData _iconoPorEquipo(String equipo) {
    switch (equipo) {
      case 'Barra':
        return Icons.fitness_center;
      case 'Mancuerna':
        return Icons.fitness_center;
      case 'Máquina':
        return Icons.settings;
      case 'Polea':
        return Icons.swap_vert;
      case 'Peso corporal':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }
}

class _ExerciseDetailSheet extends StatelessWidget {
  final ExerciseCatalogItem ejercicio;

  const _ExerciseDetailSheet({required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  if (ejercicio.gifUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A35)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          ejercicio.gifUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) =>
                              loadingProgress == null
                                  ? child
                                  : Center(
                                      child: CircularProgressIndicator(
                                        color: const Color(0xFFC8F135),
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                          errorBuilder: (context, error, stackTrace) =>
                              _errorGif(),
                        ),
                      ),
                    ),
                  if (ejercicio.gifUrl.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A35)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _iconoPorEquipo(ejercicio.equipo),
                                color: const Color(0xFF2A2A35),
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sin demostración',
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
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      ejercicio.nombre,
                      style: GoogleFonts.zenDots(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _infoChip(
                          Icons.fitness_center,
                          ejercicio.equipo,
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.accessibility_new,
                          ejercicio.musculo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFC8F135), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.zenDots(
              fontSize: 11,
              color: const Color(0xFFE8E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorGif() {
    return Container(
      width: double.infinity,
      height: 300,
      color: const Color(0xFF0D0D0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image,
                color: const Color(0xFF2A2A35), size: 48),
            const SizedBox(height: 8),
            Text(
              'Error al cargar',
              style: GoogleFonts.zenDots(
                fontSize: 12,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconoPorEquipo(String equipo) {
    switch (equipo) {
      case 'Barra':
        return Icons.fitness_center;
      case 'Mancuerna':
        return Icons.fitness_center;
      case 'Máquina':
        return Icons.settings;
      case 'Polea':
        return Icons.swap_vert;
      case 'Peso corporal':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }
}
