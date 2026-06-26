import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/routine.dart';
import '../../../core/providers/auth_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilProvider);
    final historialSemanalAsync = ref.watch(historialSemanalProvider);

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
              _buildAvatar(context, ref),
              const SizedBox(height: 24),
              perfilAsync.when(
                data: (perfil) => _buildMetas(context, ref, perfil),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              historialSemanalAsync.when(
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

  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final nombre = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario';
  final email = user?.email ?? '';
  final perfilAsync = ref.watch(perfilProvider);

  return Center(
    child: Column(
      children: [
        GestureDetector(
          onTap: () => _seleccionarFoto(context, ref),
          child: Stack(
            children: [
              perfilAsync.when(
                data: (perfil) {
                  final fotoBase64 = perfil?.fotoBase64;
                  return Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E24),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC8F135),
                        width: 2,
                      ),
                      image: fotoBase64 != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(fotoBase64)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: fotoBase64 == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF6B6B80),
                            size: 44,
                          )
                        : null,
                  );
                },
                loading: () => Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E24),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC8F135),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (_, __) => Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF6B6B80), size: 44),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8F135),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 14,
                  ),
                ),
              ),
            ],
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

Future<void> _seleccionarFoto(BuildContext context, WidgetRef ref) async {
  final picker = ImagePicker();
  final imagenSeleccionada = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 60,
    maxWidth: 300,
    maxHeight: 300,
  );

  if (imagenSeleccionada == null) return;

  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null) return;

  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFC8F135)),
      ),
    );
  }

  try {
    final bytes = await File(imagenSeleccionada.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.actualizarFotoPerfil(user.uid, base64Image);

    ref.invalidate(perfilProvider);
  } finally {
    if (context.mounted) Navigator.pop(context);
  }
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

  static const _nombresDias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  Widget _buildMetas(BuildContext context, WidgetRef ref, UserProfile? perfil) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid ?? '';
    final peso = perfil?.pesoObjetivo ?? 0;
    final calorias = perfil?.caloriasObjetivo ?? 500;
    final activos = perfil?.diasActivos ?? 0;
    final diasEntreno = perfil?.diasEntrenamiento ?? [1, 3, 5];
    final rutinasAsync = ref.watch(rutinasProvider);

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
        _buildDiasEntrenamiento(context, ref, uid, diasEntreno, activos),
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
        const SizedBox(height: 24),
        rutinasAsync.when(
          data: (rutinas) => _buildRutinasPorDia(context, ref, uid, perfil, rutinas),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDiasEntrenamiento(BuildContext context, WidgetRef ref, String uid, List<int> diasEntreno, int activos) {
    final labels = diasEntreno.map((d) => _nombresDias[d - 1]).join(', ');

    return GestureDetector(
      onTap: () => _mostrarSelectorDias(context, ref, uid, diasEntreno.toList()),
      child: Container(
        width: double.infinity,
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
                  'Días de entrenamiento',
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
                Text(
                  '${diasEntreno.length} días',
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC8F135),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(7, (i) {
                final dia = i + 1;
                final activo = diasEntreno.contains(dia);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: activo ? const Color(0xFFC8F135) : const Color(0xFF2A2A35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _nombresDias[i].substring(0, 3),
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: activo ? Colors.black : const Color(0xFF6B6B80),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              '$activos completados — Toca para cambiar',
              style: GoogleFonts.zenDots(
                fontSize: 11,
                color: const Color(0xFF6B6B80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSelectorDias(BuildContext context, WidgetRef ref, String uid, List<int> diasActuales) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final seleccion = diasActuales.toSet();
          return AlertDialog(
            backgroundColor: const Color(0xFF16161A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Días de entrenamiento',
              style: GoogleFonts.zenDots(
                fontSize: 16,
                color: const Color(0xFFE8E8F0),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (i) {
                final dia = i + 1;
                final activo = seleccion.contains(dia);
                return CheckboxListTile(
                  title: Text(
                    _nombresDias[i],
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  value: activo,
                  activeColor: const Color(0xFFC8F135),
                  checkColor: Colors.black,
                  onChanged: (_) {
                    setDialogState(() {
                      if (activo) {
                        seleccion.remove(dia);
                      } else {
                        seleccion.add(dia);
                      }
                    });
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80), fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final lista = seleccion.toList()..sort();
                  await ref.read(firestoreServiceProvider).actualizarPerfil(uid, {
                    'diasEntrenamiento': lista,
                    'diasPorSemana': lista.length,
                  });
                  ref.invalidate(perfilProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(
                  'Guardar',
                  style: GoogleFonts.zenDots(
                    color: const Color(0xFFC8F135),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRutinasPorDia(BuildContext context, WidgetRef ref, String uid, UserProfile? perfil, List<Routine> rutinas) {
    final diasEntreno = perfil?.diasEntrenamiento ?? [];
    final rutinaPorDia = Map<String, String>.from(perfil?.rutinaPorDia ?? {});

    if (diasEntreno.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rutinas por día',
          style: GoogleFonts.zenDots(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        const SizedBox(height: 12),
        ...diasEntreno.map((dia) {
          final diaKey = dia.toString();
          final rutinaId = rutinaPorDia[diaKey] ?? '';
          final rutinaAsignada = rutinas.firstWhere(
            (r) => r.id == rutinaId,
            orElse: () => Routine(id: '', nombre: 'Sin asignar', tipo: '', ejercicios: []),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A2A35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _nombresDias[dia - 1].substring(0, 2),
                      style: GoogleFonts.zenDots(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC8F135),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nombresDias[dia - 1],
                        style: GoogleFonts.zenDots(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE8E8F0),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rutinaAsignada.nombre,
                        style: GoogleFonts.zenDots(
                          fontSize: 12,
                          color: const Color(0xFF6B6B80),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _mostrarSelectorRutina(context, ref, uid, dia, diaKey, rutinaPorDia[diaKey] ?? '', rutinas),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: rutinaId.isNotEmpty ? const Color(0xFFC8F135) : const Color(0xFF2A2A35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rutinaId.isNotEmpty ? 'Cambiar' : 'Asignar',
                      style: GoogleFonts.zenDots(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: rutinaId.isNotEmpty ? Colors.black : const Color(0xFF6B6B80),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _mostrarSelectorRutina(BuildContext context, WidgetRef ref, String uid, int dia, String diaKey, String rutinaActualId, List<Routine> rutinas) {
    showDialog(
      context: context,
      builder: (ctx) {
        String seleccionada = rutinaActualId;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF16161A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              '${_nombresDias[dia - 1]}',
              style: GoogleFonts.zenDots(
                fontSize: 16,
                color: const Color(0xFFE8E8F0),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in rutinas)
                  RadioListTile<String>(
                    title: Text(
                      r.nombre,
                      style: GoogleFonts.zenDots(
                        fontSize: 13,
                        color: const Color(0xFFE8E8F0),
                      ),
                    ),
                    value: r.id,
                    groupValue: seleccionada,
                    activeColor: const Color(0xFFC8F135),
                    onChanged: (val) {
                      setDialogState(() => seleccionada = val!);
                    },
                  ),
                RadioListTile<String>(
                  title: Text(
                    'Sin asignar',
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                  value: '',
                  groupValue: seleccionada,
                  activeColor: const Color(0xFFC8F135),
                  onChanged: (val) {
                    setDialogState(() => seleccionada = val!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80), fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final perfil = ref.read(perfilProvider).valueOrNull;
                  final rutinaPorDia = Map<String, String>.from(perfil?.rutinaPorDia ?? {});
                  rutinaPorDia[diaKey] = seleccionada;
                  await ref.read(firestoreServiceProvider).actualizarPerfil(uid, {
                    'rutinaPorDia': rutinaPorDia,
                  });
                  ref.invalidate(perfilProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(
                  'Guardar',
                  style: GoogleFonts.zenDots(
                    color: const Color(0xFFC8F135),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    final completados = List.filled(7, false);

    for (final w in historial) {
      final fecha = (w['fecha'] as dynamic);
      if (fecha == null) continue;
      if (fecha is Timestamp) {
        completados[fecha.toDate().weekday - 1] = true;
      }
    }
    return completados;
  }

  Widget _buildConfiguracion(BuildContext context, WidgetRef ref) {
    final items = [
      {'icon': Icons.notifications_none, 'label': 'Notificaciones', 'section': 'notificaciones'},
      {'icon': Icons.watch, 'label': 'Dispositivos vinculados', 'section': 'dispositivos'},
      {'icon': Icons.language, 'label': 'Idioma', 'section': 'idioma'},
      {'icon': Icons.help_outline, 'label': 'Ayuda', 'section': 'ayuda'},
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
                      onTap: () => context.push('/settings/${item['section']}'),
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
