import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api/api_client.dart';
import '../data/repository/auth_repository.dart';

// ApiClient como provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// AuthRepository como provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return AuthRepository(api);
});

// Modelo de usuario
class AuthUser {
  final int id;
  final String nombre;
  final String rol;
  final String email;

  AuthUser({required this.id, required this.nombre, required this.rol, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json["id"],
      nombre: "${json["nombre"]} ${json["apellido"]}",
      rol: json["rol"],
      email: json["email"],
    );
  }
}

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final AuthUser? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});
}

// Notifier para manejar login/logout
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repo;

  AuthNotifier(this.repo) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      await repo.login(email, password);
      final profile = await repo.getProfile();
      final user = AuthUser.fromJson(profile);

      if (user.rol != "alumno") {
        state = AuthState(error: "Este usuario no es un alumno");
        return;
      }

      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: "Error al iniciar sesión: $e");
    }
  }

  void logout() {
    repo.api.setToken(""); // limpiar token
    state = AuthState();
  }
}

// Provider del AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});
