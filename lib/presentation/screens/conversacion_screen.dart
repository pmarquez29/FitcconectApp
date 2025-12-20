import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/mensaje_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../model/mensaje.dart';

class ConversacionScreen extends ConsumerStatefulWidget {
  final int usuarioId;
  final String nombreChat;
  final bool esSistema;
  final dynamic fotoUsuario;

  const ConversacionScreen({
    super.key, 
    required this.usuarioId,
    this.nombreChat = "Chat",
    this.esSistema = false,
    this.fotoUsuario,
  });

  @override
  ConsumerState<ConversacionScreen> createState() => _ConversacionScreenState();
}

class _ConversacionScreenState extends ConsumerState<ConversacionScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ✅ CORRECCIÓN CRÍTICA: Usamos microtask para evitar el error "StateNotifier.state=" durante el build
    Future.microtask(() {
      ref.read(conversacionProvider.notifier).cargarConversacion(
        widget.usuarioId, 
        esSistema: widget.esSistema
      );
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  ImageProvider _getImageProvider(dynamic fotoData) {
    if (fotoData == null) return const AssetImage("assets/avatar.jpg");
    try {
      if (fotoData is String && fotoData.isNotEmpty) {
         // Limpieza preventiva del base64
         final clean = fotoData.contains(',') ? fotoData.split(',').last : fotoData;
         return MemoryImage(base64Decode(clean));
      }
    } catch (_) {}
    return const AssetImage("assets/avatar.jpg");
  }

  @override
  Widget build(BuildContext context) {
    final mensajes = ref.watch(conversacionProvider);
    final auth = ref.watch(authProvider);

    // Auto-scroll al recibir mensajes nuevos
    ref.listen(conversacionProvider, (prev, next) {
      if (next.length > (prev?.length ?? 0)) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: widget.esSistema ? null : _getImageProvider(widget.fotoUsuario),
              child: widget.esSistema 
                  ? const Icon(Icons.notifications_active, size: 20, color: Colors.white)
                  : (widget.fotoUsuario == null ? const Icon(Icons.person, size: 20, color: Colors.white) : null),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.nombreChat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (!widget.esSistema)
                    const Text("En línea", style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: mensajes.isEmpty 
            ? const Center(child: Text("Escribe el primer mensaje...", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                final esMio = msg.remitenteId == auth.user?.id;
                
                // Detectar si es recordatorio o sistema
                final esSistemaMsg = msg.remitenteId == 0 || msg.tipo == 'recordatorio' || msg.tipo == 'sistema';

                if (esSistemaMsg) {
                  // Marcar como leído si es necesario (sin bloquear el build)
                  if (!msg.leido && widget.esSistema) {
                     WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(conversacionProvider.notifier).marcarLeido(msg.id, esNotificacion: true);
                     });
                  }
                  return _SystemBubble(mensaje: msg);
                }

                return _MensajeBubble(mensaje: msg, esMio: esMio);
              },
            ),
          ),

          if (!widget.esSistema)
            _InputBar(
              controller: _controller,
              onSend: () {
                final texto = _controller.text.trim();
                if (texto.isNotEmpty) {
                  ref.read(conversacionProvider.notifier).enviarMensaje(widget.usuarioId, texto);
                  _controller.clear();
                }
              },
            ),
        ],
      ),
    );
  }
}

// 🔔 BURBUJA DE SISTEMA
class _SystemBubble extends StatelessWidget {
  final Mensaje mensaje;
  const _SystemBubble({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    // Colores según estado leído
    final isUnread = !mensaje.leido;
    final bgColor = isUnread ? const Color(0xFFFFF7ED) : const Color(0xFFFEF9C3);
    final borderColor = isUnread ? Colors.orangeAccent : const Color(0xFFFDE047);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: bgColor, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
          border: Border.all(color: borderColor, width: 1), 
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: isUnread ? Colors.deepOrange : const Color(0xFF854D0E)),
                const SizedBox(width: 6),
                Text(
                  isUnread ? "NUEVA NOTIFICACIÓN" : "NOTIFICACIÓN",
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: isUnread ? Colors.deepOrange : const Color(0xFF854D0E).withOpacity(0.7), 
                    letterSpacing: 1.0
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              mensaje.contenido,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF451A03), height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(mensaje.fechaEnvio),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// 💬 BURBUJA DE CHAT
class _MensajeBubble extends StatelessWidget {
  final Mensaje mensaje;
  final bool esMio;

  const _MensajeBubble({required this.mensaje, required this.esMio});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: esMio ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: esMio ? const Radius.circular(12) : Radius.zero,
            bottomRight: esMio ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(mensaje.contenido, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(
              _formatHora(mensaje.fechaEnvio),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHora(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      // Ajuste local para ver hora correcta
      final localDate = date.toLocal(); 
      return "${localDate.hour}:${localDate.minute.toString().padLeft(2, '0')}";
    } catch (_) { return ""; }
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Escribe un mensaje...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2EBD85),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper de fecha
String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr).toLocal();
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  } catch (_) { return ""; }
}