class Rutina {
  final int id;
  final String nombre;
  final String objetivo;
  final String nivel;
  final int duracion;
  final int progreso;
  final String estado;
  final String? fechaInicio;
  final String? imagen;

  Rutina({
    required this.id,
    required this.nombre,
    required this.objetivo,
    required this.nivel,
    required this.duracion,
    required this.progreso,
    required this.estado,
    this.fechaInicio,
    this.imagen,
  });

  factory Rutina.fromJson(Map<String, dynamic> json) {
    return Rutina(
      id: _toInt(json["id"]),
      nombre: json["nombre"]?.toString() ?? "",
      objetivo: json["objetivo"]?.toString() ?? "",
      nivel: json["nivel"]?.toString() ?? "",
      duracion: _toInt(json["duracion"]),
      progreso: _toInt(json["progreso"]),
      estado: json["estado"]?.toString() ?? "",
      fechaInicio: json["fecha_inicio"]?.toString(),
      imagen: json["imagen"]?.toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
