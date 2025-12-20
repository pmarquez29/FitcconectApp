import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/notificacion.dart';
import 'api_provider.dart';
import 'mensaje_provider.dart';

// 1. CONTADOR (Badge Rojo)
class NotificationCountNotifier extends StateNotifier<int> {
  NotificationCountNotifier() : super(0);
  
  void setConteo(int n) => state = n;
  void incrementar() => state++;
  void decrementar() => state = state > 0 ? state - 1 : 0;
  void limpiar() => state = 0;
}

final notificationCountProvider = StateNotifierProvider<NotificationCountNotifier, int>((ref) {
  return NotificationCountNotifier();
});

// 2. GESTOR DE LISTA (Solo No Leídas)
class NotificacionesListNotifier extends StateNotifier<AsyncValue<List<Notificacion>>> {
  final Ref ref;
  
  NotificacionesListNotifier(this.ref) : super(const AsyncValue.loading()) {
    cargarNotificaciones();
  }

  Future<void> cargarNotificaciones() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get("notificaciones");
      
      final listaCompleta = (response as List).map((e) => Notificacion.fromJson(e)).toList();
      
      // ✅ FILTRO: Solo mostramos las NO leídas
      final soloNoLeidas = listaCompleta.where((n) => !n.leido).toList();
      
      // Ordenar: Más recientes primero
      soloNoLeidas.sort((a, b) => DateTime.parse(b.fecha).compareTo(DateTime.parse(a.fecha)));

      // Sincronizar contador
      ref.read(notificationCountProvider.notifier).setConteo(soloNoLeidas.length);

      state = AsyncValue.data(soloNoLeidas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ✅ Marcar y Quitar de la lista
  Future<void> marcarUnaComoLeida(int id) async {
    // 1. Optimistic UI: Eliminar de la lista visualmente YA
    state.whenData((lista) {
      // Filtramos la que acabamos de tocar para que desaparezca
      final nuevaLista = lista.where((n) => n.id != id).toList();
      state = AsyncValue.data(nuevaLista);
      
      // Bajamos el contador rojo
      ref.read(notificationCountProvider.notifier).decrementar();
    });

    // 2. Petición al Backend (en segundo plano)
    try {
      final api = ref.read(apiClientProvider);
      await api.put("notificaciones/$id/leida", {});
    } catch (e) {
      print("Error marcando notif: $e");
      // Si falla, podrías recargar la lista completa: cargarNotificaciones();
    }
  }
  
  // ✅ Método para el Socket: Agrega la nueva al inicio
  void agregarNueva(Notificacion n) {
    state.whenData((lista) {
      // Como es nueva, asumimos que no está leída. La ponemos primera.
      state = AsyncValue.data([n, ...lista]);
      ref.read(notificationCountProvider.notifier).incrementar();
    });
  }
}

final notificacionesListProvider = StateNotifierProvider<NotificacionesListNotifier, AsyncValue<List<Notificacion>>>((ref) {
  return NotificacionesListNotifier(ref);
});

// 3. LISTENER SOCKET (Global)
final notificationListenerProvider = Provider<void>((ref) {
  try {
    final repo = ref.watch(mensajeRepositoryProvider);
    
    // Escuchar evento 'notification' del backend
    repo.onNuevaNotificacion((data) {
      print("🔔 SOCKET: Nueva notificación recibida: ${data['titulo']}");
      
      final nueva = Notificacion(
        id: data['id'],
        titulo: data['titulo'],
        mensaje: data['mensaje'],
        tipo: data['tipo'],
        fecha: data['created_at'] ?? DateTime.now().toIso8601String(),
        leido: false // Siempre llega como no leída
      );
      
      // Agregamos a la lista visible al instante
      ref.read(notificacionesListProvider.notifier).agregarNueva(nueva);
    });
    
  } catch (e) {
    print("Error listener notificaciones: $e");
  }
});