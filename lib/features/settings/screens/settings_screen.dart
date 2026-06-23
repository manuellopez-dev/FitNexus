import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  final String section;

  const SettingsScreen({super.key, this.section = 'notificaciones'});

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
    switch (section) {
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
    switch (section) {
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
            activeColor: const Color(0xFFC8F135),
          ),
        ],
      ),
    );
  }

  Widget _buildDispositivos() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.watch_outlined,
            color: const Color(0xFF6B6B80),
            size: 64,
          ),
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
            'Conecta tu smartwatch o banda fitness\npara sincronizar tus entrenamientos',
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
