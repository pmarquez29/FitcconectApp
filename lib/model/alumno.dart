class AlumnoPerfil {
  final String nombreCompleto;
  final String email;
  final String fechaNacimiento;
  final String genero;
  final String? telefono;
  final String? fotoBase64;
  final String? objetivo;
  final double? peso;
  final double? altura;
  final String? nivelExperiencia;
  final String nombreInstructor;
  final bool activo;          // 👈 NUEVO

  AlumnoPerfil({
    required this.nombreCompleto,
    required this.email,
    required this.fechaNacimiento,
    required this.genero,
    this.telefono,
    this.fotoBase64,
    this.objetivo,
    this.peso,
    this.altura,
    this.nivelExperiencia,
    required this.nombreInstructor,
    required this.activo,     // 👈 NUEVO
  });
}
