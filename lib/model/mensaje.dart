class Mensaje {
  final int id;
  final int remitenteId;
  final int destinatarioId;
  final String contenido;
  final String fechaEnvio;
  final bool leido;
  final String tipo; // ✅ NUEVO: 'chat', 'recordatorio' o 'sistema'

  Mensaje({
    required this.id,
    required this.remitenteId,
    required this.destinatarioId,
    required this.contenido,
    required this.fechaEnvio,
    required this.leido,
    this.tipo = 'chat', // Por defecto es chat
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: _toInt(json['id']),
      remitenteId: _toInt(json['remitente_id']),
      destinatarioId: _toInt(json['destinatario_id']),
      contenido: json['contenido']?.toString() ?? '',
      fechaEnvio: json['fecha_envio']?.toString() ?? json['created_at']?.toString() ?? '',
      leido: json['leido'] == true || json['leido'] == 1,
      tipo: json['tipo'] ?? 'chat', // Si viene del backend (recordatorio), lo usa
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