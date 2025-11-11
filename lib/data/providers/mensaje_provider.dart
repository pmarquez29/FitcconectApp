import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/mensaje_repository.dart';
import 'api_provider.dart';
import 'auth_provider.dart';
import '/model/mensaje.dart';

/// Repositorio global
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

/// Chat actual (mensajes)
final conversacionProvider =
    StateNotifierProvider<ConversacionNotifier, List<Mensaje>>((ref) {
  final repo = ref.watch(mensajeRepositoryProvider);
  final auth = ref.watch(authProvider);
  final instructorId = auth.user?.alumnoInfo?.instructorId;

  final notifier = ConversacionNotifier(repo, ref);
  if (instructorId != null) notifier.cargarConversacion(instructorId);

  return notifier;
});

class ConversacionNotifier extends StateNotifier<List<Mensaje>> {
  final MensajeRepository repo;
  final Ref ref;

  ConversacionNotifier(this.repo, this.ref) : super([]);

  Future<void> cargarConversacion(int usuarioId) async {
    final mensajes = await repo.obtenerConversacion(usuarioId);
    state = mensajes;

    repo.onNuevoMensaje((nuevo) {
      // Solo agregar si pertenece a esta conversación
      final auth = ref.read(authProvider);
      if ((nuevo.remitenteId == usuarioId &&
              nuevo.destinatarioId == auth.user!.id) ||
          (nuevo.destinatarioId == usuarioId &&
              nuevo.remitenteId == auth.user!.id)) {
        state = [...state, nuevo];
      }
    });
  }

  Future<void> enviarMensaje(int destinatarioId, String contenido) async {
    final nuevo =
        await repo.enviarMensaje(destinatarioId: destinatarioId, contenido: contenido);
    state = [...state, nuevo];
  }
}

/// Lista de chats con alertas del sistema
final listaChatsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(mensajeRepositoryProvider);
  return await repo.obtenerChats();
});
