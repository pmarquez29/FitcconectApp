class ProgresoData {
  final RutinaHoy? rutinaHoy;
  final List<ActividadSemanal> actividadSemanal;
  final List<RutinaRapida> rutinasRapidas;
  final List<RutinaHecha> rutinasHechas;

  ProgresoData({
    required this.rutinaHoy,
    required this.actividadSemanal,
    required this.rutinasRapidas,
    required this.rutinasHechas,
  });

  factory ProgresoData.fromJson(Map<String, dynamic> json) {
    return ProgresoData(
      rutinaHoy: json["rutinaHoy"] != null
          ? RutinaHoy.fromJson(json["rutinaHoy"])
          : null,
      actividadSemanal: (json["actividadSemanal"] as List<dynamic>? ?? [])
          .map((e) => ActividadSemanal.fromJson(e))
          .toList(),
      rutinasRapidas: (json["rutinasRapidas"] as List<dynamic>? ?? [])
          .map((e) => RutinaRapida.fromJson(e))
          .toList(),
      rutinasHechas: (json["rutinasHechas"] as List<dynamic>? ?? [])
          .map((e) => RutinaHecha.fromJson(e))
          .toList(),
    );
  }
}

class RutinaHoy {
  final String nombre;
  final String tiempoRestante;
  final double progreso;

  RutinaHoy({
    required this.nombre,
    required this.tiempoRestante,
    required this.progreso,
  });

  factory RutinaHoy.fromJson(Map<String, dynamic> json) {
    return RutinaHoy(
      nombre: json["nombre"]?.toString() ?? "Sin nombre",
      tiempoRestante: json["tiempoRestante"]?.toString() ?? "0 min",
      progreso: _toDouble(json["progreso"]) / 100, // de 0–100 → 0–1
    );
  }
}

class ActividadSemanal {
  final int semana;
  final double valor;

  ActividadSemanal({
    required this.semana,
    required this.valor,
  });

  factory ActividadSemanal.fromJson(Map<String, dynamic> json) {
    return ActividadSemanal(
      semana: _toInt(json["semana"]),
      valor: _toDouble(json["valor"]),
    );
  }
}

class RutinaRapida {
  final String nombre;
  final double progreso;

  RutinaRapida({
    required this.nombre,
    required this.progreso,
  });

  factory RutinaRapida.fromJson(Map<String, dynamic> json) {
    return RutinaRapida(
      nombre: json["nombre"]?.toString() ?? "Sin nombre",
      progreso: _toDouble(json["progreso"]), // ya viene 0–1
    );
  }
}

class RutinaHecha {
  final String nombre;

  RutinaHecha({
    required this.nombre,
  });

  factory RutinaHecha.fromJson(Map<String, dynamic> json) {
    return RutinaHecha(
      nombre: json["nombre"]?.toString() ?? "Sin nombre",
    );
  }
}

/// ------------------------------
/// HELPERS PELIGRO-CERO
/// ------------------------------

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
