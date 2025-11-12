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

/// Cargar conversación (alumno ↔ instructor)
final conversacionProvider =
    StateNotifierProvider<ConversacionNotifier, List<Mensaje>>((ref) {
  final repo = ref.watch(mensajeRepositoryProvider);
  return ConversacionNotifier(repo, ref);
});

class ConversacionNotifier extends StateNotifier<List<Mensaje>> {
  final MensajeRepository repo;
  final Ref ref;

  ConversacionNotifier(this.repo, this.ref) : super([]);

  Future<void> cargarConversacion(int usuarioId) async {
    final mensajes = await repo.obtenerConversacion(usuarioId);
    state = mensajes;

    repo.onNuevoMensaje((nuevo) {
      state = [...state, nuevo];
    });
  }

  Future<void> enviarMensaje(int destinatarioId, String contenido) async {
    final nuevo =
        await repo.enviarMensaje(destinatarioId: destinatarioId, contenido: contenido);
    state = [...state, nuevo];
  }
}

/// Lista de chats (para instructor o alumno)
final listaChatsProvider = FutureProvider<List<dynamic>>((ref) async {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(mensajeRepositoryProvider);
  final rol = auth.user?.rol ?? '';
  final instructorId = auth.user?.alumnoInfo?.instructorId;

  return await repo.obtenerChats(rol, instructorId);
});

