import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiClient {
  String? token;

  String get baseUrl {
    // Si estamos en modo "Release" (APK generado o App Store), usa RENDER
    if (kReleaseMode) {
      return "https://fitconnectbackend-zrwg.onrender.com/api"; 
      // ⚠️ Asegúrate de que esta URL sea exacta (sin espacios extra)
    }
    
    // Si estamos en modo "Debug" (Programando en tu PC), usa LOCALHOST
    if (Platform.isAndroid) {
      return "http://10.0.2.2:4000/api";
    } else {
      return "http://localhost:4000/api";
    }
  }

  void setToken(String newToken) {
    token = newToken;
    
    if (newToken.isNotEmpty && newToken.length >= 15) {
      print("🔐 [ApiClient] Token configurado: ${newToken.substring(0, 15)}...");
    } else {
      print("🔐 [ApiClient] Token configurado: ${newToken.isEmpty ? 'VACÍO (Logout)' : newToken}");
    }
  }

  // --- GET ---
  Future<dynamic> get(String endpoint) async {
    print("📡 GET $endpoint");
    
    if (token != null && token!.length >= 15) {
       print("🪪 Token actual: ${token!.substring(0, 15)}...");
    } else {
       print("🪪 Token actual: ${token ?? 'NULO/VACÍO'}");
    }

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

  // --- POST ---
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    print("🚀 POST $endpoint");
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


  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    print("📝 PUT $endpoint");
    final res = await http.put(
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
      print("❌ PUT Error ${res.statusCode}: ${res.body}");
      throw Exception("Error ${res.statusCode}");
    }
  }

  // --- ✅ EXTRA RECOMENDADO: PATCH ---
  // (A veces se usa para actualizaciones parciales como 'marcar leído')
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    print("🔧 PATCH $endpoint");
    final res = await http.patch(
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
      print("❌ PATCH $endpoint → ${res.statusCode}: ${res.body}");
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }
  }
}