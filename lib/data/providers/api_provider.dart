import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Instancia global única de ApiClient, compartida por toda la app
final _apiClientInstance = ApiClient();

/// Provider que expone el cliente global
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return _apiClientInstance;
});
