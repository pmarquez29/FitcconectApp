import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/mensaje_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../model/mensaje.dart';
import 'dart:convert';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(listaChatsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text("No hay conversaciones."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final usuario = chat["usuario"];
              final ultimo = chat["ultimoMensaje"];
              final esSistema = usuario == null || chat["id"] == 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: esSistema ? Colors.green : Colors.grey[300],
                  backgroundImage: !esSistema && usuario["foto"] != null
                      ? MemoryImage(base64Decode(usuario["foto"]["data"]
                          .cast<int>()
                          .join(',')))
                      : null,
                  child: esSistema
                      ? const Icon(Icons.smart_toy, color: Colors.white)
                      : null,
                ),
                title: Text(
                  esSistema
                      ? "SISTEMA FITCONNECT"
                      : "${usuario["nombre"]} ${usuario["apellido"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ultimo?["contenido"] ?? "Sin mensajes",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  ultimo?["fecha_envio"]?.toString().split("T").first ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                tileColor: esSistema ? Colors.greenAccent.shade100 : null,
                onTap: esSistema
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConversacionScreen(usuarioId: chat["id"]),
                          ),
                        ),
              );
            },
          );
        },
      ),
    );
  }
}

class ConversacionScreen extends ConsumerWidget {
  final int usuarioId;
  const ConversacionScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mensajes = ref.watch(conversacionProvider);
    final notifier = ref.read(conversacionProvider.notifier);
    final auth = ref.watch(authProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Conversación", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                final esAlumno = msg.remitenteId == auth.user?.id;

                return Align(
                  alignment:
                      esAlumno ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: esAlumno
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.contenido),
                  ),
                );
              },
            ),
          ),
          _inputField(controller, () {
            final texto = controller.text.trim();
            if (texto.isNotEmpty) {
              notifier.enviarMensaje(usuarioId, texto);
              controller.clear();
            }
          }),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, VoidCallback onSend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Escribe un mensaje...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
