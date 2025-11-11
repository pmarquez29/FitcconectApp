import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  String? token;

  String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:4000/api";
    } else {
      return "http://localhost:4000/api";
    }
  }

  void setToken(String newToken) {
    token = newToken;
    print("🔐 [ApiClient] Token configurado: ${newToken.substring(0, 15)}...");
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token!.isNotEmpty) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      print("❌ POST $endpoint → ${res.statusCode}: ${res.body}");
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }
  }

  Future<dynamic> get(String endpoint) async {
    print("📡 GET $endpoint");
    print("🪪 Token actual: ${token?.substring(0, 15)}");

    final res = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token!.isNotEmpty) "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print("❌ GET $endpoint → ${res.statusCode}: ${res.body}");
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }
  }
}
