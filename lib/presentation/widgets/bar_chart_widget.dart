import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/progreso.dart';

class WeeklyActivityChart extends StatelessWidget {
  final List<ProgresoSemanal> data;

  const WeeklyActivityChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Escala del eje Y (Rutinas completadas)
    double maxY = 0;
    for (var item in data) {
      if (item.cantidad > maxY) maxY = item.cantidad.toDouble();
    }
    // Si el máximo es bajo (ej: 2), damos espacio hasta 4 o 5 para que se vea bien
    maxY = (maxY < 4) ? 4 : maxY + 1;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              // Usamos el color oscuro para el tooltip
              getTooltipColor: (_) => const Color(0xFF1E293B),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} rutinas',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        // Convertimos "Semana 1" -> "Sem 1" para ahorrar espacio
                        data[index].etiqueta.replaceAll("Semana", "Sem"), 
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1, // Mostrar cada entero (1, 2, 3...)
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(), 
                      style: const TextStyle(color: Colors.grey, fontSize: 10)
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1, // Líneas horizontales cada 1 rutina
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.cantidad.toDouble(),
                  // Color azul sólido para destacar las barras
                  color: const Color(0xFF3B82F6), 
                  width: 20, // Barras un poco más anchas
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: const Color(0xFFF1F5F9), // Fondo de carril vacío
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}