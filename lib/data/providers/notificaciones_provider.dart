import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/notificacion.dart';
import 'api_provider.dart';
import 'mensaje_provider.dart';

// 1. CONTADOR (Badge Rojo)
// ✅ CAMBIO: Usamos .autoDispose para que se resetee a 0 al salir
final notificationCountProvider = StateNotifierProvider.autoDispose<NotificationCountNotifier, int>((ref) {
  return NotificationCountNotifier();
});

class NotificationCountNotifier extends StateNotifier<int> {
  NotificationCountNotifier() : super(0);
  
  void setConteo(int n) => state = n;
  void incrementar() => state++;
  void decrementar() => state = state > 0 ? state - 1 : 0;
  void limpiar() => state = 0;
}

// 2. GESTOR DE LISTA
// ✅ CAMBIO: Usamos .autoDispose para borrar la lista vieja al cerrar sesión
final notificacionesListProvider = StateNotifierProvider.autoDispose<NotificacionesListNotifier, AsyncValue<List<Notificacion>>>((ref) {
  return NotificacionesListNotifier(ref);
});

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
      
      // Filtro: Solo NO leídas
      final soloNoLeidas = listaCompleta.where((n) => !n.leido).toList();
      
      // Ordenar: Más recientes primero
      soloNoLeidas.sort((a, b) => DateTime.parse(b.fecha).compareTo(DateTime.parse(a.fecha)));

      // Sincronizar contador inicial con lo que trae el backend
      ref.read(notificationCountProvider.notifier).setConteo(soloNoLeidas.length);

      state = AsyncValue.data(soloNoLeidas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> marcarUnaComoLeida(int id) async {
    // Actualización optimista
    state.whenData((lista) {
      final nuevaLista = lista.where((n) => n.id != id).toList();
      state = AsyncValue.data(nuevaLista);
      // Bajamos el contador
      ref.read(notificationCountProvider.notifier).decrementar();
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.put("notificaciones/$id/leida", {});
    } catch (e) {
      print("Error marcando notif: $e");
    }
  }
  
  void agregarNueva(Notificacion n) {
    // 1. Subir contador siempre (para que se vea el badge en tiempo real)
    ref.read(notificationCountProvider.notifier).incrementar();

    // 2. Si la lista ya está cargada en memoria, la actualizamos manualmente
    if (state.hasValue) {
       final listaActual = state.value ?? [];
       if (!listaActual.any((element) => element.id == n.id)) {
          state = AsyncValue.data([n, ...listaActual]);
       }
    }
  }
}

// 3. LISTENER SOCKET (Global)
// Este provider se mantiene vivo o se recrea según donde se use, 
// pero al usar los providers autoDispose dentro, funcionará correctamente.
final notificationListenerProvider = Provider<void>((ref) {
  try {
    final repo = ref.watch(mensajeRepositoryProvider);
    
    repo.onNuevaNotificacion((data) {
      print("🔔 SOCKET: Nueva notificación recibida: ${data['titulo']}");
      
      final nueva = Notificacion(
        id: data['id'],
        titulo: data['titulo'],
        mensaje: data['mensaje'],
        tipo: data['tipo'] ?? 'sistema',
        fecha: data['created_at'] ?? DateTime.now().toIso8601String(),
        leido: false
      );
      
      // Llamamos al método del notifier
      ref.read(notificacionesListProvider.notifier).agregarNueva(nueva);
    });
    
  } catch (e) {
    print("Error listener notificaciones: $e");
  }
});