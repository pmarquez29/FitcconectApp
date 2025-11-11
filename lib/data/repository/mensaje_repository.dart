import 'package:app_fitconnect/data/api/api_client.dart';
import '/model/mensaje.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MensajeRepository {
  final ApiClient api;
  IO.Socket? _socket;

  MensajeRepository(this.api);

  /// Conexión a Socket.IO
  void conectarSocket(String token) {
    final serverUrl = api.baseUrl.replaceFirst('/api', ''); // Ej: http://10.0.2.2:4000

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) => print('✅ Socket conectado al servidor'));
    _socket!.onDisconnect((_) => print('❌ Socket desconectado'));
  }

  /// Escuchar nuevos mensajes en tiempo real
  void onNuevoMensaje(Function(Mensaje) callback) {
    _socket?.on('nuevoMensaje', (data) {
      final mensaje = Mensaje.fromJson(data);
      callback(mensaje);
    });
  }

  void desconectarSocket() {
    _socket?.disconnect();
  }

  /// Obtener conversación (REST)
  Future<List<Mensaje>> obtenerConversacion(int usuarioId) async {
    final data = await api.get("mensajes/$usuarioId");
    return (data as List).map((m) => Mensaje.fromJson(m)).toList();
  }

  /// Enviar mensaje (solo REST — el backend lo emitirá por socket)
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

  /// Obtener lista de chats
  Future<List<dynamic>> obtenerChats() async {
    final data = await api.get("mensajes/chats");
    return data as List;
  }
}
