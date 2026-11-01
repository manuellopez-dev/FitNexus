import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class LinkTvScreen extends ConsumerStatefulWidget {
  const LinkTvScreen({super.key});

  @override
  ConsumerState<LinkTvScreen> createState() => _LinkTvScreenState();
}

class _LinkTvScreenState extends ConsumerState<LinkTvScreen> {
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
          .crearVinculacion('tv', 'Smart TV');
      if (!mounted) return;
      setState(() => _codigo = code);
      _sub = ref.read(linkServiceProvider).escucharVinculacion(code).listen((uid) {
        if (uid != null) _alVincular(uid);
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _alVincular(String uid) async {
    await ref.read(linkedIdentityProvider.notifier).vincular(uid);
    await ref.read(linkServiceProvider).iniciarPresencia(uid, 'tv', 'Smart TV');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8F135),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt,
                                color: Colors.black, size: 26),
                            const SizedBox(width: 8),
                            Text(
                              'FitNexus TV',
                              style: GoogleFonts.zenDots(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Vincula esta pantalla a tu cuenta',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.zenDots(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Escribe este código en la app del teléfono, en\n"Dispositivos vinculados"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.zenDots(
                      fontSize: 15,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(child: _buildCodigo()),
                  if (_error) ...[
                    const SizedBox(height: 24),
                    Text(
                      'No se pudo generar el código, intenta de nuevo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.zenDots(
                        fontSize: 14,
                        color: const Color(0xFFFF4D6D),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 64,
                    child: ElevatedButton(
                      autofocus: true,
                      onPressed: _generar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8F135),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 24, color: Colors.black),
                          const SizedBox(width: 10),
                          Text(
                            'Generar otro código',
                            style: GoogleFonts.zenDots(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodigo() {
    if (_codigo == null) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          color: Color(0xFFC8F135),
          strokeWidth: 3,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8F135), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC8F135).withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        _codigo!,
        style: GoogleFonts.zenDots(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFC8F135),
          letterSpacing: 12,
        ),
      ),
    );
  }
}