import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/dashboard_alumno.dart';

class ModernLineChart extends StatelessWidget {
  final List<RachaDia> racha;

  const ModernLineChart({super.key, required this.racha});

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, mostramos un estado vacío elegante
    if (racha.isEmpty) {
      return const SizedBox.shrink(); // O un container gris
    }

    // Mapeo seguro de puntos
    final puntos = racha.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.valor);
    }).toList();

    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Sombra suave para dar profundidad
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rendimiento Semanal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  SizedBox(height: 4),
                  Text("Progreso de ejercicios", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Últimos 7 días", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              )
            ],
          ),
          const SizedBox(height: 25),
          
          // Gráfico
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  // Eje Izquierdo (%)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Eje Inferior (Días)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < racha.length) {
                          // Mostrar día D1, D2...
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("D${racha[index].dia}", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (puntos.length - 1).toDouble(),
                minY: 0,
                maxY: 100, // Siempre escala de 0 a 100%
                lineBarsData: [
                  LineChartBarData(
                    spots: puntos,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF6366F1), // Morado Indigo
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false), // Sin puntos, más limpio
                    // Relleno degradado (Area Chart)
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.25),
                          const Color(0xFF6366F1).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                // Tooltip al tocar
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}%',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}