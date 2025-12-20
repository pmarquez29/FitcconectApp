import '../api/api_client.dart';
class AuthRepository {
  late ApiClient api;

  AuthRepository(this.api);

  Future<String> login(String email, String password) async {
    final data = await api.post("auth/login", {
      "email": email,
      "password": password,
    });
    
    print("🔍 Respuesta completa del backend: $data");
    print("🔍 Tipo de token: ${data["token"].runtimeType}");
    
    final token = data["token"];
    api.setToken(token);
    return token;
  }

  Future<Map<String, dynamic>> getProfile() async {
  final result = await api.get("auth/me");
  print("🔍 Respuesta completa de profile: $result");
  print("🔍 Tipo de cada campo:");
  result.forEach((key, value) {
    print("  $key: ${value.runtimeType} = $value");
  });
  return result;
}
}
