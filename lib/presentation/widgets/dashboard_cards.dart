import 'package:flutter/material.dart';

class DashboardCards extends StatelessWidget {
  final String progreso;
  final String completado;
  final String total;
  final String pendientes;

  const DashboardCards({
    super.key,
    required this.progreso,
    required this.completado,
    required this.total,
    required this.pendientes,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _Card(title: "Progreso", value: progreso),
        _Card(title: "Completado", value: completado),
        _Card(title: "Rutinas", value: total),
        _Card(title: "Pendientes", value: pendientes),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String value;

  const _Card({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
