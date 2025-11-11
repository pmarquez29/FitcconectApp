import '../api/api_client.dart';
import '/model/dashboard_alumno.dart';

class DashboardRepository {
  final ApiClient api;

  DashboardRepository(this.api);

  Future<DashboardAlumno> getDashboardAlumno() async {
    final data = await api.get("dashboard-alumno/me");
    return DashboardAlumno.fromJson(data);
  }
}
