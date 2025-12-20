import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/mensaje_provider.dart';
import 'conversacion_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  // Helper para imágenes Base64 (El mismo que usamos en Rutinas)
  ImageProvider _getImageProvider(dynamic fotoData) {
    if (fotoData == null) return const AssetImage("assets/avatar.jpg");
    
    try {
      if (fotoData is String) {
        // Si es URL
        if (fotoData.startsWith("http")) return NetworkImage(fotoData);
        
        // Si es Base64
        final clean = fotoData.contains(',') ? fotoData.split(',').last : fotoData;
        if (clean.length > 20) {
           return MemoryImage(base64Decode(clean));
        }
      }
      // Si el backend envía Buffer (lista de enteros)
      if (fotoData is Map && fotoData["data"] is List) {
         final bytes = List<int>.from(fotoData["data"]);
         return MemoryImage(base64Decode(base64Encode(bytes))); // Re-encode para MemoryImage
      }
    } catch (_) {}
    
    return const AssetImage("assets/avatar.jpg");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(listaChatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Mensajes", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      
      body: RefreshIndicator( // ✅ AGREGADO
        onRefresh: () async {
           // Forzamos recarga del provider
           ref.refresh(listaChatsProvider);
        },
        color: const Color(0xFF2EBD85),
        child: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text("No hay mensajes aún", style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: chats.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 80, endIndent: 20),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final usuario = chat["usuario"];
              final ultimo = chat["ultimoMensaje"];
              final tipo = chat["tipo"];
              final isSistema = tipo == "sistema";

              // 🕒 Formateo de hora inteligente
              String hora = "";
              if (ultimo != null && ultimo["fecha_envio"] != null) {
                final fecha = DateTime.tryParse(ultimo["fecha_envio"].toString()) ?? DateTime.now();
                hora = "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isSistema ? const Color(0xFFEFF6FF) : const Color(0xFFE2E8F0),
                      // ✅ FOTO DEL INSTRUCTOR / USUARIO
                      backgroundImage: isSistema ? null : _getImageProvider(usuario["foto"]),
                      child: isSistema 
                          ? const Icon(Icons.notifications_active, color: Colors.blueAccent)
                          : (usuario["foto"] == null ? const Icon(Icons.person, color: Colors.grey) : null),
                    ),
                    if (!isSistema)
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2EBD85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )
                  ],
                ),
                title: Text(
                  isSistema ? "NOTIFICACIONES" : "${usuario["nombre"]} ${usuario["apellido"] ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    ultimo?["contenido"] ?? "Sin mensajes",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blueGrey.shade400, 
                      fontWeight: FontWeight.w400, // Regular para leído, Bold para no leído si implementas esa lógica
                      fontSize: 14
                    ),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(hora, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                onTap: () {
                  // Navegar a la conversación pasando la foto
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversacionScreen(
                        usuarioId: chat["id"], 
                        nombreChat: isSistema ? "Notificaciones" : "${usuario["nombre"]}",
                        esSistema: isSistema,
                        fotoUsuario: isSistema ? null : usuario["foto"], // ✅ PASAMOS LA FOTO
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      )
    );
  }
}