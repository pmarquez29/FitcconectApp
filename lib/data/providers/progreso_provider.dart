import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/logro.dart';
import '../repository/progreso_repository.dart';
import '../providers/api_provider.dart';
import '../../model/progreso.dart';

final progresoRepositoryProvider = Provider<ProgresoRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ProgresoRepository(api);
});

final progresoProvider = FutureProvider.autoDispose<ProgresoData>((ref) async {
  final repo = ref.watch(progresoRepositoryProvider);
  
  final responses = await Future.wait([
    repo.obtenerProgresoGeneral(),
    repo.obtenerProgresoSemanal(),
  ]);

  final generalData = responses[0] as Map<String, dynamic>;
  final weeklyData = responses[1] as List<dynamic>;

  return ProgresoData.fromCombined(generalData, weeklyData);
});

final logrosProvider = FutureProvider.autoDispose<List<Logro>>((ref) async {
  final repo = ref.watch(progresoRepositoryProvider);
  final data = await repo.obtenerLogros();
  return data.map((e) => Logro.fromJson(e)).toList();
});