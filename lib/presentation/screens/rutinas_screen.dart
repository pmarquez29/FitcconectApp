import 'package:flutter/material.dart';

class RutinasScreen extends StatelessWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    final rutinas = [
      {"nombre": "Fuerza Full Body", "duracion": "45 min", "imagen": Icons.fitness_center},
      {"nombre": "Cardio HIIT", "duracion": "30 min", "imagen": Icons.directions_run},
      {"nombre": "Yoga Relajante", "duracion": "40 min", "imagen": Icons.self_improvement},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.fitness_center, size: 40, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Rutinas", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.notifications, size: 28),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Días en tarjetas horizontales
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dias.length,
                  itemBuilder: (context, index) {
                    final esHoy = index == DateTime.now().weekday - 1;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Card(
                        color: esHoy ? Colors.blue : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            dias[index],
                            style: TextStyle(
                              color: esHoy ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Rutinas en tarjetas horizontales
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: rutinas.length,
                  itemBuilder: (context, index) {
                    final rutina = rutinas[index];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Card(
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Icon(rutina["imagen"] as IconData, size: 80, color: Colors.blue),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    rutina["nombre"] as String,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                rutina["duracion"] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
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
