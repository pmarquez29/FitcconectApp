import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import '../../data/providers/perfil_provider.dart';
import '../../data/providers/api_provider.dart';
import '../../data/providers/auth_provider.dart';
// import '../../model/alumno.dart'; // Si lo necesitas

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _notificacionesEnabled = true; // Estado local para notificaciones

  @override
  void initState() {
    super.initState();
    _loadNotificaciones(); // Cargar pref al inicio
  }

  Future<void> _loadNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificacionesEnabled = prefs.getBool("notificaciones") ?? true;
      });
    }
  }

  Future<void> _toggleNotificaciones(bool value) async {
    setState(() => _notificacionesEnabled = value); // Cambio inmediato
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notificaciones", value);
  }

  // --- Lógica: Cambiar Foto ---
  Future<void> _cambiarFoto(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Cambiar foto de perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(ctx, Icons.camera_alt, "Cámara", ImageSource.camera),
                _buildSourceOption(ctx, Icons.photo_library, "Galería", ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(BuildContext ctx, IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () async {
        Navigator.pop(ctx); 
        await _procesarImagen(source);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade100,
            child: Icon(icon, color: const Color(0xFF2EBD85), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _procesarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source, 
        imageQuality: 50, // Comprime calidad jpg
        maxWidth: 800,    
        maxHeight: 800,   
      ); 
      if (image == null) return;

      setState(() => _isUploading = true);

      final bytes = await File(image.path).readAsBytes();
      String base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

      final api = ref.read(apiClientProvider);
      
      await api.post("auth/me/foto", {"fotoBase64": base64Image}); 

      ref.invalidate(perfilProvider);
      await ref.read(authProvider.notifier).checkAuthStatus(); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto actualizada correctamente ✅"), backgroundColor: Color(0xFF2EBD85)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al subir imagen: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  ImageProvider _buildFotoProvider(String? base64img) {
    if (base64img == null || base64img.isEmpty) return const AssetImage("assets/avatar.jpg");
    try {
      final pure = base64img.contains(",") ? base64img.split(",").last : base64img;
      if (pure.length < 50) return const AssetImage("assets/avatar.jpg");
      return MemoryImage(base64Decode(pure));
    } catch (_) {
      return const AssetImage("assets/avatar.jpg");
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilProvider);

    return perfilAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
      error: (err, _) => Center(child: Text("Error al cargar perfil: $err")),
      data: (perfil) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. FOTO DE PERFIL
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _buildFotoProvider(perfil.fotoBase64),
                      child: _isUploading 
                          ? const CircularProgressIndicator(color: Color(0xFF2EBD85))
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _cambiarFoto(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2EBD85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(perfil.nombreCompleto, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text(perfil.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),

            const SizedBox(height: 30),

            // 2. SECCIONES
            _ProfileSection(
              title: "Información Personal",
              icon: Icons.person_outline,
              children: [
                _ProfileInfoTile(icon: Icons.cake_outlined, label: "Nacimiento", value: perfil.fechaNacimiento),
                _ProfileInfoTile(icon: Icons.wc, label: "Género", value: perfil.genero),
                if (perfil.telefono != null) _ProfileInfoTile(icon: Icons.phone_outlined, label: "Teléfono", value: perfil.telefono!),
              ],
            ),

            const SizedBox(height: 20),

            _ProfileSection(
              title: "Datos Físicos",
              icon: Icons.fitness_center_outlined,
              children: [
                Row(
                  children: [
                    Expanded(child: _StatBox(label: "PESO", value: "${perfil.peso ?? '-'} kg")),
                    const SizedBox(width: 15),
                    Expanded(child: _StatBox(label: "ALTURA", value: "${perfil.altura ?? '-'} m")),
                  ],
                ),
                const SizedBox(height: 15),
                _ProfileInfoTile(icon: Icons.flag_outlined, label: "Objetivo", value: perfil.objetivo ?? "-"),
                _ProfileInfoTile(icon: Icons.star_outline, label: "Nivel", value: perfil.nivelExperiencia ?? "-"),
              ],
            ),

            const SizedBox(height: 20),

            _ProfileSection(
              title: "Configuración",
              icon: Icons.settings_outlined,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF2EBD85),
                  title: const Text("Notificaciones Push", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: _notificacionesEnabled,
                  onChanged: _toggleNotificaciones,
                ),
                const Divider(height: 1),
                
                // ✅ WIDGET OPTIMIZADO PARA MODO VACACIÓN
                _VacationSwitch(initialValue: perfil.activo),
              ],
            ),

            const SizedBox(height: 30),

            // 3. LOGOUT
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                   await ref.read(authProvider.notifier).logout();
                   if (context.mounted) {
                     Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (_) => false);
                   }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ✅ WIDGET ESPECIALIZADO: MODO VACACIÓN (Sin Lag)
class _VacationSwitch extends ConsumerStatefulWidget {
  final bool initialValue;
  const _VacationSwitch({required this.initialValue});

  @override
  ConsumerState<_VacationSwitch> createState() => _VacationSwitchState();
}

class _VacationSwitchState extends ConsumerState<_VacationSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant _VacationSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizamos si el valor del padre cambia (por recarga del perfil)
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.orangeAccent,
      title: const Text("Modo Vacación", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: const Text("Pausar rutinas temporalmente", style: TextStyle(fontSize: 12, color: Colors.grey)),
      value: _value,
      onChanged: (val) async {
        // 1. Cambio VISUAL INMEDIATO (Optimistic UI)
        setState(() => _value = val);

        try {
          // 2. Llamada a la API en segundo plano
          final api = ref.read(apiClientProvider);
          await api.post("auth/me/toggle-status", {});
          
          // 3. Refrescar el provider globalmente (para que la app se entere)
          ref.invalidate(perfilProvider);
        } catch (e) {
          // 4. Si falla, REVERTIMOS el cambio visual
          setState(() => _value = !val);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error al cambiar estado. Intenta de nuevo.")),
            );
          }
        }
      },
    );
  }
}

// --- WIDGETS AUXILIARES ---
class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _ProfileSection({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF2EBD85), size: 20), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)))]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileInfoTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: Colors.grey.shade400)),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)))])
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.2))]),
    );
  }
}