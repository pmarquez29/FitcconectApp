class Estadistica {
  final double progresoGeneral;
  final int completado;
  final int totalRutinas;
  final int pendientes;
  final List<Map<String, dynamic>> racha;

  Estadistica({
    required this.progresoGeneral,
    required this.completado,
    required this.totalRutinas,
    required this.pendientes,
    required this.racha,
  });
/*
  factory Estadistica.fromJson(Map<String, dynamic> json) {
    return Estadistica(
      progresoGeneral: json['progreso_general'] ?? 0,
      completado: json['completado'] ?? 0,
      totalRutinas: json['total'] ?? 0,
      pendientes: json['pendientes'] ?? 0,
      racha: List<Map<String, dynamic>>.from(json['racha'] ?? []),
    );
  }*/
  // Datos de prueba (mock)
  static Estadistica mock() {
    return Estadistica(
      progresoGeneral: 72.5,
      completado: 15,
      totalRutinas: 20,
      pendientes: 5,
      racha: [
        {"dia": 1, "valor": 1},
        {"dia": 2, "valor": 2},
        {"dia": 3, "valor": 2.5},
        {"dia": 4, "valor": 3},
        {"dia": 5, "valor": 4},
      ],
    );
  }
}
