import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/repository/dashboard_repository.dart';
import '/data/providers/api_provider.dart';
import '/data/providers/auth_provider.dart';
import '/model/dashboard_alumno.dart';

final dashboardAlumnoProvider = FutureProvider<DashboardAlumno>((ref) async {
  final auth = ref.watch(authProvider);
  final api = ref.watch(apiClientProvider);
  final repo = DashboardRepository(api);

  // 🔸 Esperar a que el usuario esté autenticado
  if (!auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    print("⏳ Esperando autenticación antes de pedir dashboard...");
    await Future.delayed(const Duration(milliseconds: 300));
  }

  if (!auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    throw Exception("Usuario no autenticado");
  }

  // 🔄 Sincronizamos token con el ApiClient global
  api.setToken(auth.token!);

  print("📡 [Dashboard] Solicitando datos con token activo...");
  return await repo.getDashboardAlumno();
});
