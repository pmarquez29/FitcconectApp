import 'package:flutter/material.dart';
import '../../model/dashboard_alumno.dart';

class ModernStatsGrid extends StatelessWidget {
  final ProgresoInfo progreso;

  const ModernStatsGrid({super.key, required this.progreso});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Tarjeta Grande: PROGRESO ACTUAL
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2EBD85), // Verde principal
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2EBD85).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.show_chart, color: Colors.white, size: 28),
                    const SizedBox(height: 15),
                    const Text("Progreso Rutina", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      "${progreso.general.toInt()}%", 
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            
            // Columna Derecha: RUTINAS y PENDIENTES
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _StatRowSmall(
                    label: "Rutinas Fin.",
                    value: "${progreso.completadas}",
                    icon: Icons.emoji_events,
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.shade50,
                  ),
                  const SizedBox(height: 12),
                  _StatRowSmall(
                    label: "Asignadas",
                    value: "${progreso.totalRutinas}",
                    icon: Icons.assignment,
                    iconColor: Colors.blue,
                    bgColor: Colors.blue.shade50,
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class _StatRowSmall extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatRowSmall({
    required this.label, required this.value, required this.icon, required this.iconColor, required this.bgColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(value, style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}