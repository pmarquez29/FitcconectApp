import '../api/api_client.dart';

class AuthRepository {
  final ApiClient api;

  AuthRepository(this.api);

  Future<String> login(String email, String password) async {
    final data = await api.post("auth/login", {
      "email": email,
      "password": password,
    });
    
    print("🔍 Respuesta completa del backend: $data"); // ← Agrega esta línea
    print("🔍 Tipo de token: ${data["token"].runtimeType}"); // ← Y esta
    
    final token = data["token"];
    api.setToken(token);
    return token;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final result = await api.get("auth/me");
    print("🔍 Respuesta de profile: $result"); // ← Agrega esta línea
    return result;
  }
}
