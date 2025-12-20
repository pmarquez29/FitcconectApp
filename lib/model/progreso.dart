class ProgresoData {
  final int totalRutinasCompletadas;
  final RutinaHoy? rutinaHoy;
  final List<ProgresoSemanal> progresoSemanal; // Datos de 'week-me'
  final List<RutinaHecha> rutinasHechas;

  ProgresoData({
    required this.totalRutinasCompletadas,
    this.rutinaHoy,
    required this.progresoSemanal,
    required this.rutinasHechas,
  });

  // Ahora el fromJson recibe datos combinados
  factory ProgresoData.fromCombined(Map<String, dynamic> general, List<dynamic> semanal) {
    return ProgresoData(
      totalRutinasCompletadas: _toInt(general['totalRutinasCompletadas']),
      rutinaHoy: general['rutinaHoy'] != null ? RutinaHoy.fromJson(general['rutinaHoy']) : null,
      // Mapeamos la respuesta del endpoint week-me
      progresoSemanal: semanal.map((e) => ProgresoSemanal.fromJson(e)).toList(),
      rutinasHechas: (general['rutinasHechas'] as List?)
              ?.map((e) => RutinaHecha.fromJson(e))
              .toList() ?? [],
    );
  }
}

class ProgresoSemanal {
  final String etiqueta; // "Semana 1", "Semana 2"
  final int cantidad;    // Rutinas completadas

  ProgresoSemanal({required this.etiqueta, required this.cantidad});

  factory ProgresoSemanal.fromJson(Map<String, dynamic> json) {
    return ProgresoSemanal(
      etiqueta: json['semana']?.toString() ?? "",
      cantidad: _toInt(json['valor']),
    );
  }
}

class RutinaHoy {
  final String nombre;
  final double progreso;
  final String tiempoRestante;
  final int completados;
  final int totalEjercicios;

  RutinaHoy({
    required this.nombre,
    required this.progreso,
    required this.tiempoRestante,
    required this.completados,
    required this.totalEjercicios,
  });

  factory RutinaHoy.fromJson(Map<String, dynamic> json) {
    return RutinaHoy(
      nombre: json['nombre']?.toString() ?? "Entrenamiento",
      progreso: _toDouble(json['progreso']),
      tiempoRestante: json['tiempoRestante']?.toString() ?? "0 min",
      completados: _toInt(json['completados']),
      totalEjercicios: _toInt(json['totalEjercicios']),
    );
  }
}

class ActividadSemanal {
  final String dia; // Corregido: String para "Lun", "Mar"
  final int minutos; // Corregido: mapeado desde 'valor'

  ActividadSemanal({required this.dia, required this.minutos});

  factory ActividadSemanal.fromJson(Map<String, dynamic> json) {
    return ActividadSemanal(
      // El backend envía "semana": "Lun"
      dia: json['semana']?.toString() ?? "", 
      // El backend envía "valor": 45
      minutos: _toInt(json['valor']), 
    );
  }
}

class RutinaHecha {
  final String nombre;
  final String fecha;

  RutinaHecha({required this.nombre, required this.fecha});

  factory RutinaHecha.fromJson(Map<String, dynamic> json) {
    return RutinaHecha(
      nombre: json['nombre']?.toString() ?? "Rutina",
      fecha: json['fecha']?.toString() ?? "",
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class RutinaRapida {
  final String nombre;
  final double progreso;

  RutinaRapida({required this.nombre, required this.progreso});

  factory RutinaRapida.fromJson(Map<String, dynamic> json) {
    return RutinaRapida(
      nombre: json['nombre']?.toString() ?? "Rutina",
      progreso: _toDouble(json['progreso']),
    );
  }
}
