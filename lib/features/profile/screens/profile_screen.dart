import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilProvider);
    final historialAsync = ref.watch(historialProvider);

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
              perfilAsync.when(
                data: (perfil) => _buildMetas(context, ref, perfil),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              historialAsync.when(
                data: (historial) => _buildEstadisticasSemanales(historial),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
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

  void _mostrarEditarMeta(
    BuildContext context, WidgetRef ref, String uid, String campo,
    String titulo, String unidad, dynamic valorActual,
    bool esDouble,
  ) {
    final controller = TextEditingController(text: '$valorActual');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16161A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          titulo,
          style: GoogleFonts.zenDots(
            fontSize: 16,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.zenDots(color: const Color(0xFFE8E8F0)),
          decoration: InputDecoration(
            suffixText: unidad,
            suffixStyle: GoogleFonts.zenDots(color: const Color(0xFF6B6B80)),
            filled: true,
            fillColor: const Color(0xFF1E1E24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final texto = controller.text.trim();
              if (texto.isEmpty) return;
              final valor = esDouble
                  ? double.tryParse(texto) ?? 0.0
                  : int.tryParse(texto) ?? 0;
              await ref.read(firestoreServiceProvider).actualizarPerfil(
                uid,
                {campo: valor},
              );
              ref.invalidate(perfilProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'Guardar',
              style: GoogleFonts.zenDots(
                color: const Color(0xFFC8F135),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetas(BuildContext context, WidgetRef ref, dynamic perfil) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid ?? '';
    final peso = perfil?.pesoObjetivo ?? 0;
    final calorias = perfil?.caloriasObjetivo ?? 500;
    final dias = perfil?.diasPorSemana ?? 5;
    final activos = perfil?.diasActivos ?? 0;

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
        GestureDetector(
          onTap: () => _mostrarEditarMeta(
            context, ref, uid, 'pesoObjetivo',
            'Peso objetivo', 'kg', peso, true,
          ),
          child: _metaCard(
            label: 'Peso objetivo',
            valor: peso > 0 ? '$peso kg' : '—',
            progreso: peso > 0 ? 0.5 : 0,
            actual: peso > 0 ? 'Toca para editar' : 'Toca para definir',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _mostrarEditarMeta(
            context, ref, uid, 'diasPorSemana',
            'Días por semana', 'días', dias, false,
          ),
          child: _metaCard(
            label: 'Días activos / semana',
            valor: '$dias días',
            progreso: dias > 0 ? (activos / dias).clamp(0.0, 1.0) : 0,
            actual: '$activos completados — Toca para editar',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _mostrarEditarMeta(
            context, ref, uid, 'caloriasObjetivo',
            'Calorías diarias', 'kcal', calorias, false,
          ),
          child: _metaCard(
            label: 'Calorías diarias',
            valor: '$calorias kcal',
            progreso: 0.0,
            actual: 'Toca para editar',
          ),
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

  Widget _buildEstadisticasSemanales(List<Map<String, dynamic>> historial) {
    final diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final completados = _diasCompletadosEstaSemana(historial);

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
                      color: completado ? Colors.black : const Color(0xFF6B6B80),
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    diasSemana[index],
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

  List<bool> _diasCompletadosEstaSemana(List<Map<String, dynamic>> historial) {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final completados = List.filled(7, false);

    for (final w in historial) {
      final fecha = (w['fecha'] as dynamic);
      if (fecha == null) continue;
      if (fecha is Timestamp) {
        final dia = fecha.toDate();
        if (dia.isAfter(inicioSemana)) {
          completados[dia.weekday - 1] = true;
        }
      }
    }
    return completados;
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
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: const Color(0xFF1E1E24),
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
}
