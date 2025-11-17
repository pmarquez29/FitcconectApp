import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../providers/dashboard_alumno_provider.dart';
import '../../model/alumno.dart';

final perfilProvider = FutureProvider<AlumnoPerfil>((ref) async {
  final api = ref.read(apiClientProvider);

  // 1) Dashboard: instructor, disciplina, nombre, apellido
  final dashboard = await ref.watch(dashboardAlumnoProvider.future);

  // 2) Datos de auth/me
  final me = await api.get("auth/me");

  // 3) Foto segura
  String? fotoBase64;
  final foto = me["foto"];
  if (foto != null && foto is Map && foto["data"] is List) {
    final bytes = List<int>.from(foto["data"]);
    if (bytes.isNotEmpty) {
      fotoBase64 = "data:image/png;base64,${base64Encode(bytes)}";
    }
  }

  return AlumnoPerfil(
    nombreCompleto: "${dashboard.alumno.nombre} ${dashboard.alumno.apellido}",
    email: me["email"] ?? "",
    fechaNacimiento: me["fecha_nacimiento"] ?? "",
    genero: me["genero"] ?? "",
    telefono: me["telefono"],
    fotoBase64: fotoBase64,
    objetivo: me["alumno_info"]?["objetivo"],
    peso: (me["alumno_info"]?["peso"] as num?)?.toDouble(),
    altura: (me["alumno_info"]?["altura"] as num?)?.toDouble(),
    nivelExperiencia: me["alumno_info"]?["nivel_experiencia"],
    nombreInstructor: dashboard.alumno.instructor ?? "No asignado",

    activo: me["activo"] ?? true,     // 👈 NUEVO
  );
});
