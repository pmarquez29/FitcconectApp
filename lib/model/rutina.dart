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
      id: json["id"] is String ? int.tryParse(json["id"]) ?? 0 : json["id"] ?? 0,
      nombre: json["nombre"] ?? "",
      objetivo: json["objetivo"] ?? "",
      nivel: json["nivel"] ?? "",
      duracion: json["duracion"] ?? 0,
      progreso: json["progreso"] ?? 0,
      estado: json["estado"] ?? "",
      fechaInicio: json["fecha_inicio"],
      imagen: json["imagen"],
    );
  }
}
