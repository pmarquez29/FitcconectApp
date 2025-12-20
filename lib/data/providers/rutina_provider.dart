import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/repository/rutina_repository.dart';
import '/data/providers/api_provider.dart';
import '/data/providers/auth_provider.dart';
import '/model/rutina.dart';

final rutinaRepositoryProvider = Provider<RutinaRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return RutinaRepository(api);
});

final rutinasAlumnoProvider = FutureProvider.autoDispose<List<Rutina>>((ref) async {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(rutinaRepositoryProvider);
  final api = ref.watch(apiClientProvider);

  // 🔸 Esperar a que el usuario esté autenticado
  if (!auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    print("⏳ Esperando autenticación antes de pedir rutinas...");
    await Future.delayed(const Duration(milliseconds: 300));
  }

  if (!auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    throw Exception("Usuario no autenticado");
  }

  // 🔄 Sincronizamos token con el ApiClient global
  api.setToken(auth.token!);

  print("📡 [Rutinas] Solicitando rutinas con token activo...");
  return await repo.obtenerRutinasAlumno();
});

// Provider que recibe el ID de la rutina (family) para cargar datos frescos cada vez
final rutinaDetalleProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, int>((ref, rutinaId) async {
  final repo = ref.watch(rutinaRepositoryProvider);
  // Asegúrate de que tu repo tenga el método obtenerDetalleRutina llamando al nuevo endpoint
  return await repo.obtenerDetalleRutina(rutinaId);
});
