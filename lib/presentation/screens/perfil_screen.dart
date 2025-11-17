import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/perfil_provider.dart';
import '../../data/providers/api_provider.dart';
import '../../model/alumno.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  // Imagen segura
  ImageProvider buildFoto(String? base64img) {
    if (base64img == null) return const AssetImage("assets/avatar.jpg");

    try {
      final pure = base64img.split(",").last;

      if (pure.length < 50) return const AssetImage("assets/avatar.jpg");

      final bytes = base64Decode(pure);
      return MemoryImage(bytes);
    } catch (_) {
      return const AssetImage("assets/avatar.jpg");
    }
  }

  // --- SharedPreferences: Notificaciones ---
  Future<bool> _loadNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("notificaciones") ?? true;
  }

  Future<void> _saveNotificaciones(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notificaciones", value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: perfilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (perfil) => _buildUI(context, ref, perfil),
      ),
    );
  }

  Widget _buildUI(BuildContext context, WidgetRef ref, AlumnoPerfil alumno) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: buildFoto(alumno.fotoBase64),
              ),
              const SizedBox(width: 16),
              Text(
                alumno.nombreCompleto,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildCuenta(alumno),
          const SizedBox(height: 24),

          _buildInfoFisica(alumno),
          const SizedBox(height: 24),

          _buildInstructor(alumno),
          const SizedBox(height: 24),

          _buildConfiguracion(context, ref, alumno),
          const SizedBox(height: 24),

          _buildCerrarSesion(context),
        ],
      ),
    );
  }

  Widget _buildCuenta(AlumnoPerfil alumno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cuenta",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _InfoTile(title: "Correo", value: alumno.email),
              _InfoTile(title: "Género", value: alumno.genero),
              _InfoTile(title: "Fecha nacimiento", value: alumno.fechaNacimiento),
              if (alumno.telefono != null)
                _InfoTile(title: "Teléfono", value: alumno.telefono!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoFisica(AlumnoPerfil alumno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Información física",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              if (alumno.peso != null)
                _InfoTile(title: "Peso", value: "${alumno.peso} kg"),
              if (alumno.altura != null)
                _InfoTile(title: "Altura", value: "${alumno.altura} m"),
              if (alumno.objetivo != null)
                _InfoTile(title: "Objetivo", value: alumno.objetivo!),
              if (alumno.nivelExperiencia != null)
                _InfoTile(title: "Nivel", value: alumno.nivelExperiencia!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructor(AlumnoPerfil alumno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Instructor",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: _InfoTile(
              title: "Asignado a", value: alumno.nombreInstructor),
        ),
      ],
    );
  }

  Widget _buildConfiguracion(
      BuildContext context, WidgetRef ref, AlumnoPerfil alumno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Configuración",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        FutureBuilder<bool>(
          future: _loadNotificaciones(),
          builder: (context, snapshot) {
            bool notificaciones = snapshot.data ?? true;

            return Card(
              child: Column(
                children: [
                  // Notificaciones
                  StatefulBuilder(
                    builder: (context, setSB) {
                      return SwitchListTile(
                        title: const Text("Notificaciones"),
                        value: notificaciones,
                        onChanged: (value) async {
                          await _saveNotificaciones(value);
                          setSB(() => notificaciones = value);
                        },
                      );
                    },
                  ),

                  // Modo Vacación / Activo
                  StatefulBuilder(
                    builder: (context, setSB) {
                      bool modoVacacion = !alumno.activo;

                      return SwitchListTile(
                        title: const Text("Modo Vacación"),
                        subtitle: const Text("Desactiva las rutinas"),
                        value: modoVacacion,
                        onChanged: (value) async {
                          final api = ref.read(apiClientProvider);

                          try {
                            final resp = await api.post(
                                "auth/me/toggle-status", {});

                            ref.invalidate(perfilProvider);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(resp["message"])),
                            );

                            setSB(() => modoVacacion = value);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Error al cambiar el estado")),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildCerrarSesion(BuildContext context) {
    return Card(
      child: ListTile(
        title:
            const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
        leading: const Icon(Icons.logout, color: Colors.red),
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (_) => false);
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
