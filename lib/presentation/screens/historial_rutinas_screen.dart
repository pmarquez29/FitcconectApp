import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/progreso_provider.dart';

class HistorialRutinasScreen extends ConsumerWidget {
  const HistorialRutinasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reutilizamos el provider de progreso
    final progresoAsync = ref.watch(progresoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Historial de Rutinas", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        elevation: 0,
      ),
      body: progresoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (data) {
          final historial = data.rutinasHechas;
          if (historial.isEmpty) {
            return const Center(child: Text("Aún no has completado ninguna rutina.", style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: historial.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rutina = historial[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Color(0xFF2EBD85), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rutina.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rutina.fecha.isNotEmpty 
                                ? rutina.fecha.split('T').first 
                                : "Fecha desconocida", 
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}