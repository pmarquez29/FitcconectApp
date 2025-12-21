class Logro {
  final int id;
  final String nombre;
  final String descripcion;
  final String icono;
  final bool obtenido;
  final String? fecha;

  Logro({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.obtenido,
    this.fecha,
  });

  factory Logro.fromJson(Map<String, dynamic> json) {
    return Logro(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      icono: json['icono'] ?? "🏆",
      obtenido: json['obtenido'] ?? false,
      fecha: json['fecha'],
    );
  }
}