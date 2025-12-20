import '../api/api_client.dart';
import '../../model/rutina.dart';

class RutinaRepository {
  final ApiClient api;

  RutinaRepository(this.api);

  Future<List<Rutina>> obtenerRutinasAlumno() async {
    print("🚀 RutinaRepository -> obteniendo rutinas del alumno...");
    print("🪪 Token usado: ${api.token?.substring(0, 15)}...");
    
    final data = await api.get("rutinas/alumno/mis-rutinas");

    print("✅ Respuesta backend: ${data is List ? data.length : 'Formato inesperado'} rutinas");
    return (data as List).map((r) => Rutina.fromJson(r)).toList();
  }
  Future<Map<String, dynamic>> obtenerDetalleRutina(int rutinaId) async {
    final data = await api.get("rutinas/alumno/detalle/$rutinaId");
    return data as Map<String, dynamic>;
  }
}
