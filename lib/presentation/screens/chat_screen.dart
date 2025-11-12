import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/mensaje_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../model/mensaje.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(listaChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.blue,
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text("No hay conversaciones aún."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final usuario = chat["usuario"];
              final ultimo = chat["ultimoMensaje"];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[200],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  "${usuario["nombre"] ?? ""} ${usuario["apellido"] ?? ""}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ultimo?["contenido"] ?? "Sin mensajes",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  (ultimo?["fecha_envio"] ?? "").toString().split("T").first,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ConversacionScreen(usuarioId: chat["id"]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ConversacionScreen extends ConsumerStatefulWidget {
  final int usuarioId;
  const ConversacionScreen({super.key, required this.usuarioId});

  @override
  ConsumerState<ConversacionScreen> createState() =>
      _ConversacionScreenState();
}

class _ConversacionScreenState extends ConsumerState<ConversacionScreen> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(conversacionProvider.notifier).cargarConversacion(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    final mensajes = ref.watch(conversacionProvider);
    final notifier = ref.read(conversacionProvider.notifier);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Conversación"),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  onPressed: () {
                    final texto = controller.text.trim();
                    if (texto.isNotEmpty) {
                      notifier.enviarMensaje(widget.usuarioId, texto);
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
