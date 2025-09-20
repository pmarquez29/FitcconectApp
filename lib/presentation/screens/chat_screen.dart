import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {"nombre": "Carlos Pérez", "mensaje": "Nos vemos mañana", "foto": "https://i.pravatar.cc/150?img=5"},
      {"nombre": "Ana Gómez", "mensaje": "Buen trabajo hoy 💪", "foto": "https://i.pravatar.cc/150?img=6"},
      {"nombre": "Luis Ramos", "mensaje": "Recuerda hidratarte", "foto": "https://i.pravatar.cc/150?img=7"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.chat, size: 28, color: Colors.white),
            SizedBox(width: 8),
            Text("Chats"),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Lista de chats
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(chat["foto"]!)),
                  title: Text(chat["nombre"]!),
                  subtitle: Text(chat["mensaje"]!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversacionScreen(chat: chat),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConversacionScreen extends StatelessWidget {
  final Map<String, String> chat;

  const ConversacionScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final mensajes = [
      {"texto": "Hola, ¿cómo estás?", "esAlumno": false},
      {"texto": "Bien, gracias profe.", "esAlumno": true},
      {"texto": "Hoy hiciste un gran trabajo.", "esAlumno": false},
      {"texto": "Gracias 💪", "esAlumno": true},
    ];

    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(chat["foto"]!)),
            const SizedBox(width: 8),
            Text(chat["nombre"]!),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                final esAlumno = msg["esAlumno"] as bool;

                return Align(
                  alignment: esAlumno ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: esAlumno ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg["texto"] as String),
                  ),
                );
              },
            ),
          ),

          // Input de mensaje
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
                    // Aquí después se conectará a socket.io
                    controller.clear();
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
