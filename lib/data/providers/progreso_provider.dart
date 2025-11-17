// data/providers/progreso_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/progreso_repository.dart';
import '../providers/api_provider.dart';
import '../../model/progreso.dart';

final progresoRepositoryProvider = Provider<ProgresoRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ProgresoRepository(api);
});

final progresoProvider = FutureProvider<ProgresoData>((ref) async {
  final repo = ref.watch(progresoRepositoryProvider);
  final data = await repo.obtenerProgreso();
  return ProgresoData.fromJson(data);
});
