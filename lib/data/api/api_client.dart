import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  String get baseUrl {
  if (Platform.isAndroid) {
    return "http://10.0.2.2:4000/api"; // Para emulador Android
  } else {
    return "http://localhost:4000/api"; // Para web/iOS
  }
}

  String? token;

  void setToken(String newToken) {
    token = newToken;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final res = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }
  }
}
