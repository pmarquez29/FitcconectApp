import '../api/api_client.dart';

class ProgresoRepository {
  final ApiClient api;

  ProgresoRepository(this.api);

  Future<Map<String, dynamic>> obtenerProgreso() async {
    return await api.get("progreso/me");
  }
}
