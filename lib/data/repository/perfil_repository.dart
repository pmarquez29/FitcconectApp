import '../api/api_client.dart';
import '../../model/alumno.dart';

class PerfilRepository {
  final ApiClient api;

  PerfilRepository(this.api);

  Future<AlumnoPerfil> fetchPerfil() async {
    final data = await api.get("auth/me");
    return AlumnoPerfil.fromUserJson(data);
  }
}

