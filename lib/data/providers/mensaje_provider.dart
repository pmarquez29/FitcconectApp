import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/mensaje_repository.dart';
import 'api_provider.dart';
import 'auth_provider.dart';
import '/model/mensaje.dart';

final mensajeRepositoryProvider = Provider<MensajeRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final repo = MensajeRepository(api);
  final auth = ref.watch(authProvider);
  if (auth.token != null && auth.token!.isNotEmpty) {
    repo.conectarSocket(auth.token!);
  }
  ref.onDispose(() => repo.desconectarSocket());
  return repo;
});

final listaChatsProvider = FutureProvider<List<dynamic>>((ref) async {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(mensajeRepositoryProvider);
  final rol = auth.user?.rol ?? '';
  final instructorId = auth.user?.alumnoInfo?.instructorId;
  return await repo.obtenerChats(rol, instructorId);
});

final conversacionProvider = StateNotifierProvider.autoDispose<ConversacionNotifier, List<Mensaje>>((ref) {
  final repo = ref.watch(mensajeRepositoryProvider);
  final auth = ref.watch(authProvider);
  return ConversacionNotifier(repo, auth.user?.id);
});

class ConversacionNotifier extends StateNotifier<List<Mensaje>> {
  final MensajeRepository repo;
  final int? miUsuarioId;

  ConversacionNotifier(this.repo, this.miUsuarioId) : super([]);

  Future<void> cargarConversacion(int usuarioId, {bool esSistema = false}) async {
    state = []; // Reset
    final mensajes = await repo.obtenerConversacion(usuarioId, esSistema: esSistema);
    state = mensajes;

    // --- SOCKET LISTENERS ---
    
    // 1. Mensajes de Texto
    repo.onNuevoMensaje((nuevo) {
      if (!esSistema && (nuevo.remitenteId == usuarioId || nuevo.remitenteId == miUsuarioId)) {
         _agregarSiNoExiste(nuevo);
      }
    });

    // 2. Notificaciones (Rutinas, Alertas, Recordatorios)
    repo.onNuevaNotificacion((data) {
        final tipo = data['tipo'];
        final nuevo = Mensaje(
            id: data['id'],
            remitenteId: 0,
            destinatarioId: 0,
            contenido: "📢 *${data['titulo']}*\n${data['mensaje']}",
            fechaEnvio: data['created_at'],
            leido: false, // Llega como no leída
            tipo: tipo
        );

        if (esSistema) {
           // En chat sistema entra TODO
           _agregarSiNoExiste(nuevo);
        } else {
           // En chat instructor solo RECORDATORIOS
           if (tipo == 'recordatorio') _agregarSiNoExiste(nuevo);
        }
    });

    // 3. Confirmación envío
    repo.onMensajeEnviado((enviado) {
       if (!esSistema && enviado.destinatarioId == usuarioId) {
          _agregarSiNoExiste(enviado);
       }
    });
  }

  void _agregarSiNoExiste(Mensaje msg) {
    if (!state.any((m) => m.id == msg.id)) {
       state = [...state, msg];
    }
  }

  // ✅ NUEVO: Marcar como leído
  Future<void> marcarLeido(int id, {bool esNotificacion = false}) async {
    // 1. Actualizar UI inmediatamente
    state = [
      for (final msg in state)
        if (msg.id == id) 
          Mensaje(
            id: msg.id,
            remitenteId: msg.remitenteId,
            destinatarioId: msg.destinatarioId,
            contenido: msg.contenido,
            fechaEnvio: msg.fechaEnvio,
            leido: true, // Marcamos true
            tipo: msg.tipo
          )
        else msg
    ];

    // 2. Llamar backend
    await repo.marcarLeido(id, esNotificacion: esNotificacion);
  }

  Future<void> enviarMensaje(int destinatarioId, String contenido) async {
    // Optimistic UI... (igual que antes)
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = Mensaje(id: tempId, remitenteId: miUsuarioId ?? 0, destinatarioId: destinatarioId, contenido: contenido, fechaEnvio: DateTime.now().toIso8601String(), leido: false, tipo: 'chat');
    state = [...state, tempMsg];

    try {
      final nuevoReal = await repo.enviarMensaje(destinatarioId: destinatarioId, contenido: contenido);
      state = [for (final msg in state) if (msg.id == tempId) nuevoReal else msg];
    } catch (e) { print("Error enviando: $e"); }
  }
}