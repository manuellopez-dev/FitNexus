import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class LinkWearScreen extends ConsumerStatefulWidget {
  const LinkWearScreen({super.key});

  @override
  ConsumerState<LinkWearScreen> createState() => _LinkWearScreenState();
}

class _LinkWearScreenState extends ConsumerState<LinkWearScreen> {
  StreamSubscription<String?>? _sub;
  String? _codigo;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _generar();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _generar() async {
    _sub?.cancel();
    setState(() {
      _codigo = null;
      _error = false;
    });
    try {
      final code = await ref
          .read(linkServiceProvider)
          .crearVinculacion('wear', 'Smartwatch');
      if (!mounted) return;
      setState(() => _codigo = code);
      _sub = ref
          .read(linkServiceProvider)
          .escucharVinculacion(code)
          .listen((uid) {
        if (uid != null) _alVincular(uid);
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _alVincular(String uid) async {
    await ref.read(linkedIdentityProvider.notifier).vincular(uid);
    await ref.read(linkServiceProvider).iniciarPresencia(uid, 'wear', 'Smartwatch');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFC8F135), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'FitNexus',
                    style: GoogleFonts.zenDots(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC8F135),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Vincula tu reloj',
                textAlign: TextAlign.center,
                style: GoogleFonts.zenDots(
                  fontSize: 10,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              const SizedBox(height: 10),
              if (_error)
                Text(
                  'Error, toca para reintentar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.zenDots(
                    fontSize: 9,
                    color: const Color(0xFFFF4D6D),
                  ),
                )
              else if (_codigo == null)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Color(0xFFC8F135),
                    strokeWidth: 2,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC8F135), width: 2),
                  ),
                  child: Text(
                    _codigo!,
                    style: GoogleFonts.zenDots(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC8F135),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Escríbelo en la app del teléfono',
                textAlign: TextAlign.center,
                style: GoogleFonts.zenDots(
                  fontSize: 8,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E24),
                    foregroundColor: const Color(0xFFE8E8F0),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Nuevo código',
                    style: GoogleFonts.zenDots(fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}