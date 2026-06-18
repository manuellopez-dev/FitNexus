import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/screens/home_screen.dart';
import '../../routines/screens/routines_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabActivo = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RoutinesScreen(),
    const _ProgresoPlaceholder(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: IndexedStack(
        index: _tabActivo,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavbar(),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Inicio', 0),
          _navItem(Icons.fitness_center, 'Rutinas', 1),
          _navItem(Icons.bar_chart, 'Progreso', 2),
          _navItem(Icons.person, 'Perfil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _tabActivo == index;
    return GestureDetector(
      onTap: () => setState(() => _tabActivo = index),
      child: Column(
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
              color: active
                  ? const Color(0xFFC8F135)
                  : const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgresoPlaceholder extends StatelessWidget {
  const _ProgresoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: Center(
        child: Text(
          'Próximamente',
          style: GoogleFonts.zenDots(
            fontSize: 18,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ),
    );
  }
}