import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/routine.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  int _filtroActivo = 0;
  final List<String> _filtros = ['Todos', 'Fuerza', 'Cardio'];

  List<Routine> _filtrar(List<Routine> rutinas) {
    if (_filtroActivo == 0) return rutinas;
    return rutinas.where((r) => r.tipo == _filtros[_filtroActivo]).toList();
  }

  IconData _iconoPorTipo(String tipo) {
    return tipo == 'Cardio' ? Icons.directions_bike : Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    final rutinasAsync = ref.watch(rutinasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildFiltros(),
            const SizedBox(height: 16),
            Expanded(
              child: rutinasAsync.when(
                data: (rutinas) => _buildListaRutinas(_filtrar(rutinas)),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFC8F135)),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error al cargar rutinas',
                    style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mis Rutinas',
            style: GoogleFonts.zenDots(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          GestureDetector(
            onTap: () => _mostrarDialogoNuevaRutina(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFC8F135),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filtros.length,
        itemBuilder: (context, index) {
          final activo = _filtroActivo == index;
          return GestureDetector(
            onTap: () => setState(() => _filtroActivo = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: activo
                    ? const Color(0xFFC8F135)
                    : const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo
                      ? const Color(0xFFC8F135)
                      : const Color(0xFF2A2A35),
                ),
              ),
              child: Center(
                child: Text(
                  _filtros[index],
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: activo ? Colors.black : const Color(0xFF6B6B80),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaRutinas(List<Routine> rutinas) {
    if (rutinas.isEmpty) {
      return Center(
        child: Text(
          'No hay rutinas en esta categoría',
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: rutinas.length,
      itemBuilder: (context, index) {
        final rutina = rutinas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconoPorTipo(rutina.tipo),
                  color: const Color(0xFFC8F135),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rutina.nombre,
                      style: GoogleFonts.zenDots(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
              ),
              GestureDetector(
                onTap: () => context.push('/workout', extra: rutina),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8F135),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoNuevaRutina(BuildContext context) {
    final nombreController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva Rutina',
              style: GoogleFonts.zenDots(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE8E8F0),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreController,
              style: GoogleFonts.zenDots(color: const Color(0xFFE8E8F0)),
              decoration: InputDecoration(
                hintText: 'Nombre de la rutina',
                hintStyle: GoogleFonts.zenDots(color: const Color(0xFF6B6B80)),
                filled: true,
                fillColor: const Color(0xFF1E1E24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC8F135)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final nombre = nombreController.text.trim();
                  if (nombre.isEmpty) return;

                  Navigator.pop(context);
                  context.push('/exercise-selection', extra: nombre);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8F135),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Crear rutina',
                  style: GoogleFonts.zenDots(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}