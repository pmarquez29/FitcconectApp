import 'dart:convert';

class AlumnoPerfil {
  final String nombreCompleto;
  final String email;
  final String fechaNacimiento;
  final String genero;
  final String? telefono;
  final String? fotoBase64;
  final String? objetivo;
  final double? peso;
  final double? altura;
  final String? nivelExperiencia;
  final String nombreInstructor;
  final bool activo; // 👈 nuevo

  AlumnoPerfil({
    required this.nombreCompleto,
    required this.email,
    required this.fechaNacimiento,
    required this.genero,
    this.telefono,
    this.fotoBase64,
    this.objetivo,
    this.peso,
    this.altura,
    this.nivelExperiencia,
    required this.nombreInstructor,
    required this.activo, // 👈 nuevo
  });

  factory AlumnoPerfil.fromUserJson(Map<String, dynamic> json) {
    final alumnoInfo = json['alumno_info'] ?? {};
    final instructor = json['Instructor'] ?? {};

    String? fotoBase64;
    final foto = json['foto'];
    if (foto != null && foto is Map && foto["data"] is List) {
      final bytes = List<int>.from(foto["data"]);
      if (bytes.isNotEmpty) {
        fotoBase64 = "data:image/png;base64," + base64Encode(bytes);
      }
    }

    return AlumnoPerfil(
      nombreCompleto: "${json['nombre']} ${json['apellido']}",
      email: json['email'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] ?? '',
      genero: json['genero'] ?? '',
      telefono: json['telefono'],
      fotoBase64: fotoBase64,
      objetivo: alumnoInfo['objetivo'],
      peso: (alumnoInfo['peso'] as num?)?.toDouble(),
      altura: (alumnoInfo['altura'] as num?)?.toDouble(),
      nivelExperiencia: alumnoInfo['nivel_experiencia'],
      nombreInstructor: instructor["nombre"] != null
          ? "${instructor["nombre"]} ${instructor["apellido"]}"
          : "No asignado",
      activo: json['activo'] ?? true, // 👈 nuevo
    );
  }
}
