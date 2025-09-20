import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rutinaHoy = {
      "nombre": "Full Body Strength",
      "tiempoRestante": "25 min",
      "progreso": 0.6
    };

    final rutinasRapidas = [
      {"nombre": "Cardio HIIT", "progreso": 0.4, "icono": Icons.directions_run},
      {"nombre": "Yoga Relajante", "progreso": 0.7, "icono": Icons.self_improvement},
      {"nombre": "Core Express", "progreso": 0.2, "icono": Icons.sports_gymnastics},
    ];

    final rutinasHechas = [
      {"nombre": "Piernas Killer", "icono": Icons.fitness_center},
      {"nombre": "Cardio Extremo", "icono": Icons.directions_bike},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.fitness_center, size: 40, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Progreso", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.notifications, size: 28),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Rutina de hoy
              const Text("Rutina de Hoy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rutinaHoy["nombre"] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(rutinaHoy["tiempoRestante"] as String),
                          ]),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("Continuar"),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearPercentIndicator(
                        lineHeight: 8,
                        percent: rutinaHoy["progreso"] as double,
                        backgroundColor: Colors.grey[300]!,
                        progressColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Rutinas rápidas
              const Text("Rutinas Rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: rutinasRapidas.length,
                  itemBuilder: (context, index) {
                    final rutina = rutinasRapidas[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularPercentIndicator(
                                radius: 40,
                                lineWidth: 6,
                                percent: rutina["progreso"] as double,
                                center: Icon(rutina["icono"] as IconData, size: 40, color: Colors.blue),
                                progressColor: Colors.blue,
                              ),
                              const SizedBox(height: 10),
                              Text(rutina["nombre"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text("Ver"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Rutinas hechas
              const Text("Rutinas Hechas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: rutinasHechas.length,
                  itemBuilder: (context, index) {
                    final rutina = rutinasHechas[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(rutina["icono"] as IconData, size: 50, color: Colors.green),
                              const SizedBox(height: 10),
                              Text(rutina["nombre"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Completado"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
