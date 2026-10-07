import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class LoginTvScreen extends ConsumerStatefulWidget {
  const LoginTvScreen({super.key});

  @override
  ConsumerState<LoginTvScreen> createState() => _LoginTvScreenState();
}

class _LoginTvScreenState extends ConsumerState<LoginTvScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _buttonFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _buttonFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa correo y contraseña');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authServiceProvider).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _traducirError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _traducirError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'too-many-requests':
        return 'Demasiados intentos, intenta después';
      default:
        return 'Error al iniciar sesión';
    }
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
              constraints: const BoxConstraints(maxWidth: 720),
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
                  const SizedBox(height: 20),
                  Text(
                    'Inicia sesión para sincronizar con tu teléfono',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.zenDots(
                      fontSize: 16,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildField(
                    focusNode: _emailFocus,
                    autofocus: true,
                    controller: _emailController,
                    hint: 'Correo electrónico',
                    icon: Icons.mail_outline,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    focusNode: _passwordFocus,
                    controller: _passwordController,
                    hint: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.zenDots(
                        fontSize: 14,
                        color: const Color(0xFFFF4D6D),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 64,
                    child: ElevatedButton(
                      focusNode: _buttonFocus,
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8F135),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFF2A2A35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Color(0xFFC8F135),
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Entrar',
                              style: GoogleFonts.zenDots(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool autofocus = false,
    ValueChanged<String>? onSubmitted,
  }) {
    return Focus(
      focusNode: focusNode,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.zenDots(
          fontSize: 20,
          color: const Color(0xFFE8E8F0),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF6B6B80), size: 26),
          hintText: hint,
          hintStyle: GoogleFonts.zenDots(
            fontSize: 18,
            color: const Color(0xFF6B6B80),
          ),
          filled: true,
          fillColor: const Color(0xFF16161A),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFC8F135), width: 2),
          ),
        ),
      ),
    );
  }
}
