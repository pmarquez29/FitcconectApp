import '../api/api_client.dart';
import '../../model/estadistica.dart';

class AlumnoRepository {
  final ApiClient api;

  AlumnoRepository(this.api);

  Future<Estadistica> fetchEstadistica(int alumnoId) async {
    final data = await api.get("alumno/$alumnoId/dashboard");
    //return Estadistica.fromJson(data);
    return Estadistica.mock(); // Usar datos de prueba por ahora
  }
}
