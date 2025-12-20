class Notificacion {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo; // 'recordatorio', 'rutina', 'alerta', etc.
  final String fecha;
  final bool leido;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fecha,
    required this.leido,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      titulo: json['titulo'] ?? "Notificación",
      mensaje: json['mensaje'] ?? "",
      tipo: json['tipo'] ?? "sistema",
      fecha: json['created_at'] ?? "",
      leido: json['leido'] == true,
    );
  }
}