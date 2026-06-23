import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isRegistrando = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    setState(() => _errorMessage = 'Por favor llena todos los campos');
    return;
  }

  if (_isRegistrando && _nombreController.text.isEmpty) {
    setState(() => _errorMessage = 'Por favor ingresa tu nombre');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    if (_isRegistrando) {
  final credential = await authService.register(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );
  await credential.user?.updateDisplayName(_nombreController.text.trim());
  if (credential.user != null) {
    await firestoreService.crearPerfil(
      credential.user!,
      _nombreController.text.trim(),
    );
    await firestoreService.sembrarRutinasIniciales(credential.user!.uid);
  }
    } else {
      await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (mounted) context.go('/home');
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = _traducirError(e);
    });
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  String _traducirError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      default:
        return 'Ocurrió un error, intenta de nuevo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFC8F135),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: Colors.black, size: 44),
              ),
              const SizedBox(height: 20),

              Text(
                'FitNexus',
                style: GoogleFonts.zenDots(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Tu entrenador inteligente',
                style: GoogleFonts.zenDots(
                  fontSize: 14,
                  color: const Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 56),

              // Campo nombre solo en registro
              if (_isRegistrando) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nombre',
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nombreController,
                  style: GoogleFonts.zenDots(
                    color: const Color(0xFFE8E8F0),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E1E24),
                    hintText: 'Tu nombre o apodo',
                    hintStyle: GoogleFonts.zenDots(
                      color: const Color(0xFF6B6B80),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFC8F135)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Label correo
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Correo',
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.zenDots(
                  color: const Color(0xFFE8E8F0),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E24),
                  hintText: 'correo@ejemplo.com',
                  hintStyle: GoogleFonts.zenDots(
                    color: const Color(0xFF6B6B80),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFC8F135)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Label contraseña
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contraseña',
                  style: GoogleFonts.zenDots(
                    fontSize: 13,
                    color: const Color(0xFF6B6B80),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.zenDots(
                  color: const Color(0xFFE8E8F0),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E24),
                  hintText: '••••••••',
                  hintStyle: GoogleFonts.zenDots(
                    color: const Color(0xFF6B6B80),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFC8F135)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF6B6B80),
                    ),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D6D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF4D6D).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFFFF4D6D),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Botón
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8F135),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF2A2A35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isRegistrando ? 'Crear cuenta' : 'Iniciar sesión',
                          style: GoogleFonts.zenDots(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle login/registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegistrando
                        ? '¿Ya tienes cuenta? '
                        : '¿No tienes cuenta? ',
                    style: GoogleFonts.zenDots(
                      fontSize: 13,
                      color: const Color(0xFF6B6B80),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isRegistrando = !_isRegistrando;
                      _errorMessage = null;
                    }),
                    child: Text(
                      _isRegistrando ? 'Inicia sesión' : 'Regístrate',
                      style: GoogleFonts.zenDots(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC8F135),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}