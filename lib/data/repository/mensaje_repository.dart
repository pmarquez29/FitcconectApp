import 'package:app_fitconnect/data/api/api_client.dart';
import '../../model/mensaje.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MensajeRepository {
  final ApiClient api;
  IO.Socket? _socket;

  MensajeRepository(this.api);

  // --- SOCKET ---
  void conectarSocket(String token) {
    if (_socket != null && _socket!.connected) return;

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
  }

  void onNuevoMensaje(Function(Mensaje) callback) {
    _socket?.off("nuevoMensaje");
    _socket?.on("nuevoMensaje", (data) => callback(Mensaje.fromJson(data)));
  }

  void onNuevaNotificacion(Function(Map<String, dynamic>) callback) {
    _socket?.off("notification");
    _socket?.on("notification", (data) {
      print("🔔 Notificación Socket: $data");
      callback(data);
    });
  }
  
  void onMensajeEnviado(Function(Mensaje) callback) {
    _socket?.off("mensajeEnviado");
    _socket?.on("mensajeEnviado", (data) => callback(Mensaje.fromJson(data)));
  }

  void desconectarSocket() {
    _socket?.disconnect();
  }

  // --- REST ---

  // ✅ Marcar mensaje o notificación como leído
  Future<void> marcarLeido(int id, {bool esNotificacion = false}) async {
    try {
      if (esNotificacion) {
        await api.put("notificaciones/$id/leida", {});
      } else {
        await api.put("mensajes/$id/leido", {});
      }
    } catch (e) {
      print("Error marcando leído: $e");
    }
  }

  Future<List<Mensaje>> obtenerConversacion(int usuarioId, {bool esSistema = false}) async {
    final List<Mensaje> listaFinal = [];

    // 🔴 CASO A: Chat de Notificaciones (SISTEMA)
    // Muestra TODAS las notificaciones para que el alumno no pierda nada.
    if (esSistema) {
      try {
        final notifsRaw = await api.get("notificaciones");
        final notificaciones = (notifsRaw as List)
            .map((n) => Mensaje(
                  id: n['id'],
                  remitenteId: 0,
                  destinatarioId: 0,
                  contenido: "📢 *${n['titulo']}*\n${n['mensaje']}",
                  fechaEnvio: n['created_at'],
                  leido: n['leido'], // Importante para la UI
                  tipo: n['tipo'] ?? 'sistema', 
                ))
            .toList();
        listaFinal.addAll(notificaciones);
      } catch (e) {
        print("Error notificaciones sistema: $e");
      }
    } 
    // 🔵 CASO B: Chat con Instructor
    // Muestra Mensajes + Recordatorios (Contexto de chat)
    else {
      // 1. Mensajes
      try {
        final mensajesRaw = await api.get("mensajes/$usuarioId");
        final mensajes = (mensajesRaw as List).map((m) => Mensaje.fromJson(m)).toList();
        listaFinal.addAll(mensajes);
      } catch (e) { print("Error chat: $e"); }

      // 2. Solo Recordatorios (para no saturar el chat con rutinas viejas)
      try {
        final notifsRaw = await api.get("notificaciones");
        final recordatorios = (notifsRaw as List)
            .where((n) => n['tipo'] == 'recordatorio')
            .map((n) => Mensaje(
                  id: n['id'],
                  remitenteId: 0, 
                  destinatarioId: 0,
                  contenido: "📅 *${n['titulo']}*\n${n['mensaje']}",
                  fechaEnvio: n['created_at'],
                  leido: n['leido'],
                  tipo: 'recordatorio', 
                ))
            .toList();
        listaFinal.addAll(recordatorios);
      } catch (e) { print("Error recordatorios: $e"); }
    }

    // Ordenar cronológicamente
    listaFinal.sort((a, b) {
      final fechaA = DateTime.tryParse(a.fechaEnvio) ?? DateTime(0);
      final fechaB = DateTime.tryParse(b.fechaEnvio) ?? DateTime(0);
      return fechaA.compareTo(fechaB);
    });

    return listaFinal;
  }

  // ... (enviarMensaje y obtenerChats igual que antes) ...
  Future<Mensaje> enviarMensaje({required int destinatarioId, required String contenido}) async {
    final data = await api.post("mensajes", {
      "destinatario_id": destinatarioId,
      "contenido": contenido,
    });
    return Mensaje.fromJson(data);
  }

  Future<List<dynamic>> obtenerChats(String rol, int? instructorId) async {
    final List<dynamic> chats = [];

    // 1. Chat Sistema
    try {
      final notifsRaw = await api.get("notificaciones");
      if ((notifsRaw as List).isNotEmpty) {
        // Ordenamos para sacar el último mensaje real de todo el sistema
        final notifs = (notifsRaw).toList();
        notifs.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
        
        final ultimo = notifs.first;
        chats.add({
          "id": -1, 
          "tipo": "sistema",
          "usuario": {"nombre": "Notificaciones", "apellido": "", "foto": null},
          "ultimoMensaje": {
            "contenido": ultimo['mensaje'],
            "fecha_envio": ultimo['created_at']
          }
        });
      }
    } catch (_) {}

    // 2. Chat Instructor
    if (rol == "alumno" && instructorId != null) {
      final data = await api.get("mensajes/chats"); 
      if (data is List) chats.addAll(data);
    }
    return chats;
  }
}