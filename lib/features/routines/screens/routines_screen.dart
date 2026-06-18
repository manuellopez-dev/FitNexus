import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  int _filtroActivo = 0;
  final List<String> _filtros = ['Todos', 'Fuerza', 'Cardio'];

  final List<Map<String, dynamic>> _rutinas = [
    {
      'nombre': 'Pecho + Tríceps',
      'ejercicios': 6,
      'duracion': 45,
      'tipo': 'Fuerza',
      'icon': Icons.fitness_center,
    },
    {
      'nombre': 'Piernas + Glúteos',
      'ejercicios': 8,
      'duracion': 55,
      'tipo': 'Fuerza',
      'icon': Icons.directions_run,
    },
    {
      'nombre': 'Espalda + Bíceps',
      'ejercicios': 7,
      'duracion': 50,
      'tipo': 'Fuerza',
      'icon': Icons.fitness_center,
    },
    {
      'nombre': 'HIIT Cardio',
      'ejercicios': 5,
      'duracion': 30,
      'tipo': 'Cardio',
      'icon': Icons.directions_bike,
    },
    {
      'nombre': 'Hombros + Trapecio',
      'ejercicios': 6,
      'duracion': 40,
      'tipo': 'Fuerza',
      'icon': Icons.fitness_center,
    },
  ];

  List<Map<String, dynamic>> get _rutinasFiltradas {
    if (_filtroActivo == 0) return _rutinas;
    return _rutinas
        .where((r) => r['tipo'] == _filtros[_filtroActivo])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: _buildListaRutinas()),
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
              fontSize: 24,
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

  Widget _buildListaRutinas() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _rutinasFiltradas.length,
      itemBuilder: (context, index) {
        final rutina = _rutinasFiltradas[index];
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
                  rutina['icon'] as IconData,
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
                      rutina['nombre'],
                      style: GoogleFonts.zenDots(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rutina['ejercicios']} ejercicios · ${rutina['duracion']} min',
                      style: GoogleFonts.zenDots(
                        fontSize: 13,
                        color: const Color(0xFF6B6B80),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
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
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoNuevaRutina(BuildContext context) {
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE8E8F0),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
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
                onPressed: () => context.push('/workout'),
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

  Widget _buildNavbar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Inicio', false),
          _navItem(Icons.fitness_center, 'Rutinas', true),
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