class DashboardAlumno {
  final AlumnoInfo alumno;
  final ProgresoInfo progreso;
  final RutinaActiva? rutinaActiva;
  final List<ActividadReciente> actividadesRecientes;

  DashboardAlumno({
    required this.alumno,
    required this.progreso,
    this.rutinaActiva,
    required this.actividadesRecientes,
  });

  factory DashboardAlumno.fromJson(Map<String, dynamic> json) {
    return DashboardAlumno(
      alumno: AlumnoInfo.fromJson(json["alumno"] ?? {}),
      progreso: ProgresoInfo.fromJson(json["progreso"] ?? {}),
      rutinaActiva: json["rutinaActiva"] != null
          ? RutinaActiva.fromJson(json["rutinaActiva"])
          : null,
      actividadesRecientes: (json["actividadesRecientes"] is List)
          ? (json["actividadesRecientes"] as List)
              .map((a) => ActividadReciente.fromJson(a))
              .toList()
          : [],
    );
  }
}

class AlumnoInfo {
  final int id;
  final String nombre;
  final String apellido;
  final String? disciplina;
  final String? instructor;

  AlumnoInfo({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.disciplina,
    this.instructor,
  });

  factory AlumnoInfo.fromJson(Map<String, dynamic> json) {
    return AlumnoInfo(
      id: _parseInt(json["id"]),
      nombre: json["nombre"] ?? "",
      apellido: json["apellido"] ?? "",
      disciplina: json["disciplina"],
      instructor: json["instructor"],
    );
  }
}

class ProgresoInfo {
  final double general;
  final int completadas;
  final int totalRutinas;
  final int pendientes;
  final List<RachaDia> racha;

  ProgresoInfo({
    required this.general,
    required this.completadas,
    required this.totalRutinas,
    required this.pendientes,
    required this.racha,
  });

  factory ProgresoInfo.fromJson(Map<String, dynamic> json) {
    final rachaJson = json["racha"];
    return ProgresoInfo(
      general: _parseDouble(json["general"]),
      completadas: _parseInt(json["completadas"]),
      totalRutinas: _parseInt(json["totalRutinas"]),
      pendientes: _parseInt(json["pendientes"]),
      racha: (rachaJson is List)
          ? rachaJson.map((r) => RachaDia.fromJson(r)).toList()
          : [],
    );
  }
}

class RachaDia {
  final int dia;
  final double valor;

  RachaDia({required this.dia, required this.valor});

  factory RachaDia.fromJson(Map<String, dynamic> json) {
    return RachaDia(
      dia: _parseInt(json["dia"]),
      valor: _parseDouble(json["valor"]),
    );
  }
}

class RutinaActiva {
  final String nombre;
  final String objetivo;
  final String nivel;
  final String fechaInicio;
  final double progreso;

  RutinaActiva({
    required this.nombre,
    required this.objetivo,
    required this.nivel,
    required this.fechaInicio,
    required this.progreso,
  });

  factory RutinaActiva.fromJson(Map<String, dynamic> json) {
    return RutinaActiva(
      nombre: json["nombre"] ?? "",
      objetivo: json["objetivo"] ?? "",
      nivel: json["nivel"] ?? "",
      fechaInicio: json["fecha_inicio"] ?? "",
      progreso: _parseDouble(json["progreso"]),
    );
  }
}

class ActividadReciente {
  final String nombre;
  final String fecha;
  final bool completado;
  final int? calorias;
  final int? tiempo;

  ActividadReciente({
    required this.nombre,
    required this.fecha,
    required this.completado,
    this.calorias,
    this.tiempo,
  });

  factory ActividadReciente.fromJson(Map<String, dynamic> json) {
    return ActividadReciente(
      nombre: json["nombre"] ?? "",
      fecha: json["fecha"] ?? "",
      completado: json["completado"] ?? false,
      calorias: _tryParseInt(json["calorias"]),
      tiempo: _tryParseInt(json["tiempo"]),
    );
  }
}

/// --- Helpers seguros ---
int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int? _tryParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
