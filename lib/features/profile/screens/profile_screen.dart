import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
            _buildHeader(),
            const SizedBox(height: 32),
            _buildAvatar(ref),
            const SizedBox(height: 24),
            _buildMetas(),
            const SizedBox(height: 24),
            _buildEstadisticasSemanales(),
            const SizedBox(height: 24),
            _buildConfiguracion(context, ref),
            const SizedBox(height: 100),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Text(
      'Mi Perfil',
      style: GoogleFonts.zenDots(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFE8E8F0),
      ),
    );
  }

  Widget _buildAvatar(WidgetRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final nombre = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario';
  final email = user?.email ?? '';

  return Center(
    child: Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFC8F135),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF6B6B80),
            size: 44,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          nombre,
          style: GoogleFonts.zenDots(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.zenDots(
            fontSize: 13,
            color: const Color(0xFF6B6B80),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMetas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Metas',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 12),
        _metaCard(
          label: 'Peso objetivo',
          valor: '75 kg',
          progreso: 0.68,
          actual: '72 kg actual',
        ),
        const SizedBox(height: 10),
        _metaCard(
          label: 'Días activos / semana',
          valor: '5 días',
          progreso: 0.71,
          actual: '3 completados',
        ),
        const SizedBox(height: 10),
        _metaCard(
          label: 'Calorías diarias',
          valor: '500 kcal',
          progreso: 0.55,
          actual: '275 hoy',
        ),
      ],
    );
  }

  Widget _metaCard({
    required String label,
    required String valor,
    required double progreso,
    required String actual,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.zenDots(
                  fontSize: 13,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              Text(
                valor,
                style: GoogleFonts.zenDots(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC8F135),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: const Color(0xFF2A2A35),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFC8F135)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            actual,
            style: GoogleFonts.zenDots(
              fontSize: 11,
              color: const Color(0xFF6B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasSemanales() {
    final dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final completados = [true, true, false, true, false, false, false];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Esta semana',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final completado = completados[index];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: completado
                          ? const Color(0xFFC8F135)
                          : const Color(0xFF2A2A35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      completado ? Icons.check : Icons.remove,
                      color: completado
                          ? Colors.black
                          : const Color(0xFF6B6B80),
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dias[index],
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      color: completado
                          ? const Color(0xFFC8F135)
                          : const Color(0xFF6B6B80),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildConfiguracion(BuildContext context, WidgetRef ref) {
    final items = [
      {'icon': Icons.notifications_none, 'label': 'Notificaciones'},
      {'icon': Icons.watch, 'label': 'Dispositivos vinculados'},
      {'icon': Icons.language, 'label': 'Idioma'},
      {'icon': Icons.help_outline, 'label': 'Ayuda'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Column(
            children: [
              ...items.map((item) => Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: const Color(0xFF6B6B80),
                      size: 20,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: GoogleFonts.zenDots(
                        fontSize: 14,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF6B6B80),
                      size: 18,
                    ),
                    onTap: () {},
                  ),
                  if (item != items.last)
                    const Divider(
                      color: Color(0xFF2A2A35),
                      height: 1,
                      indent: 16,
                    ),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) context.go('/login');
            },
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.zenDots(
                fontSize: 14,
                color: const Color(0xFFFF4D6D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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
          _navItem(Icons.home_rounded, 'Inicio', false),
          _navItem(Icons.fitness_center, 'Rutinas', false),
          _navItem(Icons.bar_chart, 'Progreso', false),
          _navItem(Icons.person, 'Perfil', true),
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