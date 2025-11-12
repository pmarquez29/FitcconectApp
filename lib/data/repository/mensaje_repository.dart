import 'package:app_fitconnect/data/api/api_client.dart';
import '/model/mensaje.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MensajeRepository {
  final ApiClient api;
  IO.Socket? _socket;

  MensajeRepository(this.api);

  // --- SOCKET ---
  void conectarSocket(String token) {
    final serverUrl = api.baseUrl.replaceFirst('/api', '');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) => print("✅ Socket conectado"));
    _socket!.onDisconnect((_) => print("❌ Socket desconectado"));
  }

  void onNuevoMensaje(Function(Mensaje) callback) {
    _socket?.on("nuevoMensaje", (data) {
      callback(Mensaje.fromJson(data));
    });
  }

  void desconectarSocket() {
    _socket?.disconnect();
  }

  // --- REST ---
  Future<List<Mensaje>> obtenerConversacion(int usuarioId) async {
    final data = await api.get("mensajes/$usuarioId");
    return (data as List).map((m) => Mensaje.fromJson(m)).toList();
  }

  Future<Mensaje> enviarMensaje({
    required int destinatarioId,
    required String contenido,
  }) async {
    final data = await api.post("mensajes", {
      "destinatario_id": destinatarioId,
      "contenido": contenido,
    });
    return Mensaje.fromJson(data);
  }

  Future<List<dynamic>> obtenerChats(String rol, int? instructorId) async {
  print("🧠 Rol actual: $rol");
  print("🧩 instructorId: $instructorId");

  final List<dynamic> chats = [];

  if (rol == "alumno" && instructorId != null) {
    final conv = await obtenerConversacion(instructorId);
    print("💬 Mensajes con instructor: ${conv.length}");
    if (conv.isNotEmpty) {
      final ultimo = conv.last;
      chats.add({
        "id": instructorId,
        "tipo": "chat",
        "usuario": {"nombre": "Tu instructor", "apellido": ""},
        "ultimoMensaje": {
          "contenido": ultimo.contenido,
          "fecha_envio": ultimo.fechaEnvio,
        }
      });
    }
  } else {
    final data = await api.get("mensajes/chats");
    print("📥 Chats devueltos por API: ${data.length}");
    chats.addAll(data as List);
  }

  final notifs = await api.get("notificaciones");
  print("🔔 Notificaciones: ${notifs.length}");
    for (final n in notifs) {
      chats.add({
        "id": n["id"],
        "tipo": "sistema",
        "usuario": {
          "nombre": "SISTEMA FITCONNECT",
          "apellido": "",
          "icono": n["tipo"],
        },
        "ultimoMensaje": {
          "contenido": n["mensaje"],
          "fecha_envio": n["created_at"],
        },
        "color": n["tipo"] == "alerta"
            ? "yellow"
            : "green",
      });
    }

    // 🔹 Ordenar por fecha más reciente
    chats.sort((a, b) {
      final fechaA = DateTime.tryParse(a["ultimoMensaje"]["fecha_envio"] ?? "") ?? DateTime(0);
      final fechaB = DateTime.tryParse(b["ultimoMensaje"]["fecha_envio"] ?? "") ?? DateTime(0);
      return fechaB.compareTo(fechaA);
    });

    return chats;
  }
}
