import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/routine.dart';
import '../../home/screens/home_screen.dart';
import '../../routines/screens/routines_screen.dart';
import '../../exercises/screens/exercise_catalog_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _tabActivo = 0;
  final Set<String> _solicitudesAtendidas = {};

  final List<Widget> _screens = [
    const HomeScreen(),
    const RoutinesScreen(),
    const ExerciseCatalogScreen(),
    const ProfileScreen(),
  ];

  Future<void> _abrirSolicitud(String sessionId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final sync = ref.read(syncServiceProvider);
    final sesion = await sync.obtenerSesion(sessionId);
    if (sesion == null || sesion.estado != 'solicitada') return;

    Routine? rutina;
    if (sesion.rutinaId.isNotEmpty) {
      rutina = await ref
          .read(firestoreServiceProvider)
          .obtenerRutina(user.uid, sesion.rutinaId);
    }
    rutina ??= ref.read(rutinasProvider).valueOrNull?.firstWhere(
          (r) => r.nombre == sesion.rutinaNombre,
          orElse: () => Routine(
            id: '',
            nombre: sesion.rutinaNombre,
            tipo: 'Fuerza',
            ejercicios: [],
          ),
        );

    if (!mounted || rutina == null || rutina.ejercicios.isEmpty) return;
    if (!context.mounted) return;

    context.push('/workout', extra: {'rutina': rutina, 'sessionId': sessionId});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionRequestProvider, (prev, next) {
      final sessionId = next.valueOrNull;
      if (sessionId == null || sessionId.isEmpty) return;
      if (ref.read(activeSessionIdProvider) != null) return;
      if (!_solicitudesAtendidas.add(sessionId)) return;
      _abrirSolicitud(sessionId);
    });

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
          _navItem(Icons.videocam, 'Ejercicios', 2),
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
