import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/rutina.dart';
import '../../data/providers/rutina_provider.dart';
import '../widgets/registrar_progreso_sheet.dart';

class RutinaDetalleScreen extends ConsumerWidget {
  final Rutina rutina;

  const RutinaDetalleScreen({super.key, required this.rutina});

  ImageProvider _getImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const AssetImage("assets/rutina_placeholder.png");
    }
    try {
      final cleanBase64 = base64String.contains(',') ? base64String.split(',').last : base64String;
      return MemoryImage(base64Decode(cleanBase64));
    } catch (_) {
      return const AssetImage("assets/rutina_placeholder.png");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 SOLUCIÓN BUG "RUTINA ANTERIOR": 
    // Usamos el ID de la rutina para crear un estado único.
    final detalleAsync = ref.watch(rutinaDetalleProvider(rutina.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // APP BAR
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                rutina.nombre,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: _getImageProvider(rutina.imagen), fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENIDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 SOLUCIÓN BUG OVERFLOW: Usamos Wrap
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DetailBadge(icon: Icons.star, text: rutina.nivel, color: Colors.orangeAccent),
                      _DetailBadge(icon: Icons.flag, text: rutina.objetivo, color: Colors.blueAccent),
                      _DetailBadge(icon: Icons.timer, text: "${rutina.duracion} min", color: const Color(0xFF2EBD85)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text("Lista de Ejercicios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 15),

                  // LISTA DINÁMICA
                  detalleAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
                    ),
                    error: (err, _) => Text("Error: $err", style: const TextStyle(color: Colors.red)),
                    data: (data) {
                      final ejercicios = data["ejercicios"] as List;
                      final asignacionId = data["asignacion_id"];

                      if (ejercicios.isEmpty) {
                        return const Text("No hay ejercicios disponibles.");
                      }

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ejercicios.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _EjercicioItemReal(
                            ejercicio: ejercicios[index],
                            onTap: () async {
                              final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => RegistrarProgresoSheet(
                                // 🔴 CORRECCIÓN AQUÍ: Usar "progreso_id" en lugar de "id"
                                preSelectedEjercicioId: ejercicios[index]["progreso_id"], 
                                asignacionId: asignacionId, 
                              ), 
                            );

                              if (result == true) {
                                // Recargamos SOLO esta rutina y la lista general
                                ref.refresh(rutinaDetalleProvider(rutina.id));
                                ref.refresh(rutinasAlumnoProvider);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _EjercicioItemReal extends StatelessWidget {
  final dynamic ejercicio;
  final VoidCallback onTap;

  const _EjercicioItemReal({required this.ejercicio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool completado = ejercicio["completado"] ?? false;
    final String nombre = ejercicio["nombre"] ?? "Ejercicio";
    
    // Tratamos de mostrar algo informativo, si no hay datos registrados mostramos 'Pendiente'
    final String subtexto = completado 
        ? "Completado" 
        : "Toca para registrar";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completado ? const Color(0xFFF0FDF4) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completado ? const Color(0xFF2EBD85).withOpacity(0.3) : Colors.grey.shade200
          ),
        ),
        child: Row(
          children: [
            // Checkbox visual
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: completado ? const Color(0xFF2EBD85) : Colors.white,
                shape: BoxShape.circle,
                border: completado ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.check, 
                size: 16, 
                color: completado ? Colors.white : Colors.transparent
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      color: completado ? const Color(0xFF1E293B) : const Color(0xFF1E293B)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtexto, 
                    style: TextStyle(color: completado ? const Color(0xFF2EBD85) : Colors.grey, fontSize: 12)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Badge auxiliar
class _DetailBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailBadge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Vital para Wrap
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}