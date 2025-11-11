import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/providers/auth_provider.dart';
import 'main_navigation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 🔹 Llamamos al login del AuthNotifier
        await ref
            .read(authProvider.notifier)
            .login(_emailController.text.trim(), _passwordController.text.trim());

        // 🔹 Le damos un pequeño margen a Riverpod para propagar cambios
        await Future.delayed(const Duration(milliseconds: 200));

        // 🔹 Verificamos si la autenticación fue exitosa
        final auth = ref.read(authProvider);
        if (auth.isAuthenticated && auth.user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se pudo iniciar sesión.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Banner superior
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'PORTAL ESTUDIANTES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Títulos
              Text(
                'Bienvenido Alumno',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'INICIAR SESIÓN',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Logo
              Image.asset(
                'assets/logo.png',
                height: 150,
              ),

              const SizedBox(height: 20),

              // Mensaje motivacional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '💪 ¡Tu Mejor Versión Te Espera!\nCada Entrenamiento Cuenta. ¡Vamos Por Ello!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Formulario
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TU CÓDIGO DE ESTUDIANTE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Ejemplo: EST-001_JU",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {},
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Ingrese su código" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Ingrese su contraseña" : null,
                    ),
                    const SizedBox(height: 25),

                    if (authState.error != null)
                      Text(
                        authState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFF1565C0),
                        ),
                        onPressed: authState.isLoading ? null : _login,
                        child: authState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "INGRESAR",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Mensaje inferior
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '¿No Tienes Código?\nTu Instructor Debe Proporcionarte Un Código Único Para Acceder A La Plataforma',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 13,
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
