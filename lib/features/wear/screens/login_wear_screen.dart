import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class LoginWearScreen extends ConsumerStatefulWidget {
  const LoginWearScreen({super.key});

  @override
  ConsumerState<LoginWearScreen> createState() => _LoginWearScreenState();
}

class _LoginWearScreenState extends ConsumerState<LoginWearScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Faltan datos');
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
        return 'Datos incorrectos';
      case 'too-many-requests':
        return 'Intenta más tarde';
      default:
        return 'Error al entrar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFC8F135), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'FitNexus',
                    style: GoogleFonts.zenDots(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC8F135),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Sincroniza tu reloj',
                textAlign: TextAlign.center,
                style: GoogleFonts.zenDots(
                  fontSize: 9,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 14),
              _buildField(_emailController, 'Correo', false),
              const SizedBox(height: 8),
              _buildField(_passwordController, 'Clave', true),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.zenDots(
                    fontSize: 8,
                    color: const Color(0xFFFF4D6D),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8F135),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF2A2A35),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Color(0xFF0D0D0F),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Entrar',
                          style: GoogleFonts.zenDots(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, bool obscure) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.center,
        style: GoogleFonts.zenDots(
          fontSize: 10,
          color: const Color(0xFFE8E8F0),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.zenDots(
            fontSize: 10,
            color: const Color(0xFF6B6B80),
          ),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF16161A),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2A2A35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC8F135)),
          ),
        ),
      ),
    );
  }
}
