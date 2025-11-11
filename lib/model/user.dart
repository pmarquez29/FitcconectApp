import 'dart:convert';

class User {
  final int id;
  final int disciplinaId;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String fechaNacimiento;
  final String genero;
  final String? telefono;
  final String fechaRegistro;
  final bool activo;
  final String? foto;
  final Disciplina? disciplina;
  final InstructorInfo? instructorInfo;
  final AlumnoInfo? alumnoInfo;

  User({
    required this.id,
    required this.disciplinaId,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    required this.fechaNacimiento,
    required this.genero,
    this.telefono,
    required this.fechaRegistro,
    required this.activo,
    this.foto,
    this.disciplina,
    this.instructorInfo,
    this.alumnoInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      disciplinaId: _parseInt(json['disciplina_id']),
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] ?? '',
      genero: json['genero'] ?? '',
      telefono: json['telefono'],
      fechaRegistro: json['fecha_registro'] ?? '',
      activo: json['activo'] ?? true,
      foto: _decodeFoto(json['foto']),
      disciplina: json['Disciplina'] != null 
          ? Disciplina.fromJson(json['Disciplina']) 
          : null,
      instructorInfo: json['instructor_info'] != null 
          ? InstructorInfo.fromJson(json['instructor_info']) 
          : null,
      alumnoInfo: json['alumno_info'] != null 
          ? AlumnoInfo.fromJson(json['alumno_info']) 
          : null,
    );
  }

  // Función auxiliar para convertir a int de forma segura
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  static String? _decodeFoto(dynamic value) {
    if (value == null) return null;
    if (value is String) return value; // si ya viene en base64
    if (value is Map && value['data'] is List) {
      final bytes = List<int>.from(value['data']);
      return "data:image/png;base64,${base64Encode(bytes)}";
    }
    return null;
  }
}

class Disciplina {
  final int id;
  final String nombre;
  final String descripcion;

  Disciplina({required this.id, required this.nombre, required this.descripcion});

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: User._parseInt(json['id']),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}

class InstructorInfo {
  final int usuarioId;
  final String? especialidad;
  final int experiencia;
  final String? certificaciones;

  InstructorInfo({
    required this.usuarioId,
    this.especialidad,
    required this.experiencia,
    this.certificaciones,
  });

  factory InstructorInfo.fromJson(Map<String, dynamic> json) {
    return InstructorInfo(
      usuarioId: User._parseInt(json['usuario_id']),
      especialidad: json['especialidad'],
      experiencia: User._parseInt(json['experiencia']),
      certificaciones: json['certificaciones'],
    );
  }
}

class AlumnoInfo {
  final int usuarioId;
  final int instructorId;
  final double? peso;
  final double? altura;
  final String? objetivo;
  final String? nivelExperiencia;

  AlumnoInfo({
    required this.usuarioId,
    required this.instructorId,
    this.peso,
    this.altura,
    this.objetivo,
    this.nivelExperiencia,
  });

  factory AlumnoInfo.fromJson(Map<String, dynamic> json) {
    return AlumnoInfo(
      usuarioId: User._parseInt(json['usuario_id']),
      instructorId: User._parseInt(json['instructor_id']),
      peso: _parseDouble(json['peso']),
      altura: _parseDouble(json['altura']),
      objetivo: json['objetivo'],
      nivelExperiencia: json['nivel_experiencia'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  
}