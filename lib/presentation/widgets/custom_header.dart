import 'dart:convert'; // Necesario para base64Decode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/notificaciones_provider.dart';
import 'notificaciones_sheet.dart';

class CustomHeader extends ConsumerWidget {
  final String title;
  final String subtitle;
  final bool showNotification;
  final VoidCallback? onProfileTap;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle = "",
    this.showNotification = true,
    this.onProfileTap,
  });

  /// 🔹 Función auxiliar para procesar la imagen de forma segura
  ImageProvider _getUserImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const AssetImage("assets/avatar.jpg");
    }
    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last.trim();
      }
      return MemoryImage(base64Decode(cleanBase64));
    } catch (e) {
      return const AssetImage("assets/avatar.jpg");
    }
  }
@override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationListenerProvider);
    ref.listen(notificacionesListProvider, (_, __) {}); 

    final notifCount = ref.watch(notificationCountProvider);
    final user = ref.watch(authProvider).user;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. TEXTOS Y LOGO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/logo.png",
                  height: 30, // Ajustado para que se vea elegante
                  errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: Color(0xFF2EBD85)),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // 2. ACCIONES
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CAMPANITA
              if (showNotification) ...[
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: () {
                        // Abrir Sheet de Notificaciones
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const NotificacionesSheet(),
                        );
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.notifications_outlined, size: 24, color: Color(0xFF64748B)),
                      ),
                    ),
                    if (notifCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Center(
                            child: Text(
                              notifCount > 9 ? '9+' : '$notifCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
              ],

              // AVATAR MENU
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) async {
                  if (value == 'profile') {
                    // ✅ 3. EJECUTAR EL CALLBACK AL SELECCIONAR PERFIL
                    if (onProfileTap != null) {
                      onProfileTap!();
                    }
                  } else if (value == 'logout') {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage: _getUserImage(user?.foto),
                    child: (user?.foto == null || user!.foto!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(user?.nombre ?? "Mi Perfil")
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}