import 'package:flutter/material.dart';
import '../../model/estadistica.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estadistica = Estadistica.mock();

    return Scaffold(
      appBar: AppBar(title: const Text("FitConnect")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            DashboardCards(
              progreso: "${estadistica.progresoGeneral.toStringAsFixed(1)}%",
              completado: "${estadistica.completado}",
              total: "${estadistica.totalRutinas}",
              pendientes: "${estadistica.pendientes}",
            ),
            const SizedBox(height: 20),
            const Text("Progreso en Racha de Días", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            LineChartWidget(racha: estadistica.racha),
            const SizedBox(height: 20),
            const Text("Estado de Energía", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const BarChartWidget(),
          ],
        ),
      ),
    );
  }
}
