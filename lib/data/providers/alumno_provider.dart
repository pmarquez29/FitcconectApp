import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/repository/alumno_repository.dart';
import '/model/estadistica.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final alumnoRepositoryProvider = Provider<AlumnoRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return AlumnoRepository(api);
});

/// Provider que carga las estadísticas del alumno logueado
final alumnoEstadisticaProvider =
    FutureProvider<Estadistica>((ref) async {
  final repo = ref.watch(alumnoRepositoryProvider);
  final auth = ref.watch(authProvider);

  if (auth.user == null) {
    throw Exception("Usuario no autenticado");
  }

  final data = await repo.fetchEstadistica(auth.user!.id);
  return data;
});
