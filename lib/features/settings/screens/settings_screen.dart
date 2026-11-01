import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/link_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String section;

  const SettingsScreen({super.key, this.section = 'notificaciones'});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _codigoController = TextEditingController();
  String? _errorVinculacion;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        title: Text(
          _titulo,
          style: GoogleFonts.zenDots(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8E8F0),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE8E8F0)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildContent(context),
      ),
    );
  }

  String get _titulo {
    switch (widget.section) {
      case 'notificaciones':
        return 'Notificaciones';
      case 'dispositivos':
        return 'Dispositivos';
      case 'idioma':
        return 'Idioma';
      case 'ayuda':
        return 'Ayuda';
      default:
        return 'Configuración';
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.section) {
      case 'notificaciones':
        return _buildNotificaciones();
      case 'dispositivos':
        return _buildDispositivos();
      case 'idioma':
        return _buildIdioma();
      case 'ayuda':
        return _buildAyuda();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNotificaciones() {
    return Column(
      children: [
        _switchOption(
          'Recordatorios de entrenamiento',
          'Recibe notificaciones cuando sea hora de entrenar',
          true,
        ),
        const Divider(color: Color(0xFF2A2A35), height: 1),
        _switchOption(
          'Progreso semanal',
          'Resumen de tu progreso cada domingo',
          false,
        ),
        const Divider(color: Color(0xFF2A2A35), height: 1),
        _switchOption(
          'Sonidos y vibración',
          'Efectos de sonido durante el workout',
          true,
        ),
      ],
    );
  }

  Widget _switchOption(String titulo, String subtitulo, bool valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.zenDots(
                    fontSize: 14,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: GoogleFonts.zenDots(
                    fontSize: 11,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: (_) {},
            activeThumbColor: const Color(0xFFC8F135),
          ),
        ],
      ),
    );
  }

  Widget _buildDispositivos() {
    final uid = ref.watch(identityProvider);
    if (uid == null) {
      return const Center(
        child: Text(
          'Inicia sesión para ver tus dispositivos',
          style: TextStyle(color: Color(0xFF6B6B80)),
        ),
      );
    }
    final dispositivosAsync = ref.watch(dispositivosProvider(uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Dispositivos vinculados a tu cuenta',
                style: GoogleFonts.zenDots(
                  fontSize: 13,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _vincularDialog(uid),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8F135),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Vincular',
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: dispositivosAsync.when(
            data: (dispositivos) {
              if (dispositivos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.devices_other,
                          color: Color(0xFF2A2A35), size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No hay dispositivos vinculados',
                        style: GoogleFonts.zenDots(
                          fontSize: 14,
                          color: const Color(0xFFE8E8F0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Muestra el código en tu reloj o TV\ny escríbelo aquí para vincularlo',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.zenDots(
                          fontSize: 12,
                          color: const Color(0xFF6B6B80),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: dispositivos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _buildDeviceTile(uid, dispositivos[i]),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFC8F135)),
            ),
            error: (_, __) => Center(
              child: Text(
                'Error al cargar dispositivos',
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  color: const Color(0xFFFF4D6D),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTile(String uid, LinkedDevice d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Row(
        children: [
          Icon(_iconoDispositivo(d.tipo), color: const Color(0xFFC8F135)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.nombre,
                  style: GoogleFonts.zenDots(
                    fontSize: 14,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.activo ? 'En línea' : _ultimaConexion(d.ultimaConexion),
                  style: GoogleFonts.zenDots(
                    fontSize: 11,
                    color: d.activo
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF6B6B80),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Desvincular',
            icon: const Icon(Icons.link_off, color: Color(0xFFFF4D6D)),
            onPressed: () => _desvincular(uid, d),
          ),
        ],
      ),
    );
  }

  IconData _iconoDispositivo(String tipo) {
    switch (tipo) {
      case 'wear':
        return Icons.watch;
      case 'tv':
        return Icons.tv;
      case 'movil':
        return Icons.phone_android;
      default:
        return Icons.devices_other;
    }
  }

  Future<void> _vincularDialog(String uid) async {
    _codigoController.clear();
    _errorVinculacion = null;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF16161A),
          title: Text(
            'Vincular dispositivo',
            style: GoogleFonts.zenDots(
              fontSize: 16,
              color: const Color(0xFFE8E8F0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Escribe el código que aparece en tu reloj o TV.',
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codigoController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: GoogleFonts.zenDots(
                  fontSize: 24,
                  letterSpacing: 6,
                  color: const Color(0xFFE8E8F0),
                ),
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF1E1E24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                  ),
                ),
              ),
              if (_errorVinculacion != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorVinculacion!,
                  style: GoogleFonts.zenDots(
                    fontSize: 11,
                    color: const Color(0xFFFF4D6D),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar',
                  style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8F135),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final code = _codigoController.text.trim().toUpperCase();
                if (code.length != 6) {
                  setDialogState(
                      () => _errorVinculacion = 'El código tiene 6 caracteres');
                  return;
                }
                try {
                  await ref.read(linkServiceProvider).vincular(code, uid);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Dispositivo vinculado')),
                  );
                } catch (e) {
                  setDialogState(() => _errorVinculacion =
                      e.toString().replaceFirst('Exception: ', ''));
                }
              },
              child: Text('Vincular',
                  style: GoogleFonts.zenDots(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    _codigoController.clear();
    _errorVinculacion = null;
  }

  Future<void> _desvincular(String uid, LinkedDevice d) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161A),
        title: Text('Desvincular',
            style: GoogleFonts.zenDots(color: const Color(0xFFE8E8F0))),
        content: Text(
          '¿Quitar "${d.nombre}" de tu cuenta?',
          style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar',
                style: GoogleFonts.zenDots(color: const Color(0xFF6B6B80))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D6D),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Quitar', style: GoogleFonts.zenDots()),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await ref.read(linkServiceProvider).desvincular(uid, d.deviceId);
    }
  }

  String _ultimaConexion(int ts) {
    if (ts <= 0) return 'Sin conexión';
    final fecha = DateTime.fromMillisecondsSinceEpoch(ts);
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'En línea hace instantes';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  Widget _buildIdioma() {
    final idiomas = [
      {'nombre': 'Español', 'codigo': 'es', 'activo': true},
      {'nombre': 'English', 'codigo': 'en', 'activo': false},
    ];

    return Column(
      children: idiomas.map((i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              i['nombre'] as String,
              style: GoogleFonts.zenDots(
                fontSize: 14,
                color: i['activo'] as bool
                    ? const Color(0xFFC8F135)
                    : const Color(0xFFE8E8F0),
              ),
            ),
            if (i['activo'] as bool)
              const Icon(Icons.check, color: Color(0xFFC8F135), size: 20),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAyuda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ayudaItem(
          Icons.info_outline,
          'Versión',
          '1.0.0',
        ),
        const Divider(color: Color(0xFF2A2A35), height: 1),
        _ayudaItem(
          Icons.email_outlined,
          'Contacto',
          'soporte@fitnexus.app',
        ),
        const Divider(color: Color(0xFF2A2A35), height: 1),
        _ayudaItem(
          Icons.description_outlined,
          'Términos y condiciones',
          'Toca para ver',
        ),
        const Divider(color: Color(0xFF2A2A35), height: 1),
        _ayudaItem(
          Icons.privacy_tip_outlined,
          'Política de privacidad',
          'Toca para ver',
        ),
      ],
    );
  }

  Widget _ayudaItem(IconData icon, String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B6B80), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.zenDots(
                    fontSize: 14,
                    color: const Color(0xFFE8E8F0),
                  ),
                ),
                Text(
                  subtitulo,
                  style: GoogleFonts.zenDots(
                    fontSize: 11,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B6B80), size: 18),
        ],
      ),
    );
  }
}
