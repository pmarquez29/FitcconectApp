import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/user.dart';
import '../repository/auth_repository.dart';
import 'api_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthRepository(api);
});

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState(isAuthenticated: false);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref ref;

  AuthNotifier(this._authRepository, this.ref) : super(AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      try {
        print("🔑 Restaurando sesión...");
        final api = ref.read(apiClientProvider);
        api.setToken(token);
        _authRepository.api = api;

        final userData = await _authRepository.getProfile();
        final user = User.fromJson(userData);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
        );
        print("✅ Sesión restaurada: ${user.email}");
      } catch (e) {
        print("⚠️ Error restaurando sesión: $e");
        state = AuthState.initial();
      }
    }
  }

  // ✅ NUEVO MÉTODO: Check Auth Status (Para recargar perfil/foto)
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      logout();
      return;
    }

    try {
      // Usamos el repositorio existente para pedir el perfil fresco
      final userData = await _authRepository.getProfile();
      final user = User.fromJson(userData);

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        user: user, // Aquí viene la foto actualizada
        error: null,
      );
    } catch (e) {
      print("⚠️ Error verificando estado: $e");
      // Opcional: logout() si el token expiró, o solo notificar error
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final token = await _authRepository.login(email, password);

      _authRepository.api.setToken(token);
      ref.read(apiClientProvider).setToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      final userData = await _authRepository.getProfile();
      final user = User.fromJson(userData);

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        user: user,
        isLoading: false,
      );

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    ref.read(apiClientProvider).setToken(""); 
    state = AuthState.initial();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo, ref);
});