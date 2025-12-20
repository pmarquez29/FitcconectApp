import '../api/api_client.dart';

class ProgresoRepository {
  final ApiClient api;

  ProgresoRepository(this.api);

  // Endpoint 1: Datos generales (Hoy, Historial, Total)
  Future<Map<String, dynamic>> obtenerProgresoGeneral() async {
    return await api.get("progreso/me");
  }

  // Endpoint 2: Datos del gráfico (Semanal)
  Future<List<dynamic>> obtenerProgresoSemanal() async {
    final response = await api.get("progreso/week-me");
    // Asumimos que el backend devuelve directamente la lista [ {semana:..., valor:...}, ... ]
    // Si devuelve { data: [...] }, ajusta aquí.
    if (response is List) return response;
    if (response is Map && response['progresoSemanal'] is List) {
       return response['progresoSemanal'];
    }
    return [];
  }
}