class Mensaje {
  final int id;
  final int remitenteId;
  final int destinatarioId;
  final String contenido;
  final String fechaEnvio;
  final bool leido;

  Mensaje({
    required this.id,
    required this.remitenteId,
    required this.destinatarioId,
    required this.contenido,
    required this.fechaEnvio,
    required this.leido,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] ?? 0,
      remitenteId: json['remitente_id'] ?? 0,
      destinatarioId: json['destinatario_id'] ?? 0,
      contenido: json['contenido'] ?? '',
      fechaEnvio: json['fecha_envio'] ?? '',
      leido: json['leido'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "remitente_id": remitenteId,
        "destinatario_id": destinatarioId,
        "contenido": contenido,
        "fecha_envio": fechaEnvio,
        "leido": leido,
      };
}
