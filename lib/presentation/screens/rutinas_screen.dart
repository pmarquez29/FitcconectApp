import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/providers/rutina_provider.dart';
import '/model/rutina.dart';

class RutinasScreen extends ConsumerWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinasAsync = ref.watch(rutinasAlumnoProvider);

    final dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    final hoy = DateTime.now().weekday - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/logo.png", height: 50),
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.notifications_none, size: 30),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "RUTINAS",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // --- DÍAS ---
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dias.length,
                  itemBuilder: (context, index) {
                    final esHoy = index == hoy;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: esHoy ? Colors.blue : Colors.blue[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                "${DateTime.now().day + (index - hoy)}\n${dias[index]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: esHoy ? Colors.white : Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- RUTINAS ---
              Expanded(
                child: rutinasAsync.when(
                  data: (rutinas) {
                    if (rutinas.isEmpty) {
                      return const Center(child: Text("No tienes rutinas asignadas"));
                    }
                    return ListView.builder(
                      itemCount: rutinas.length,
                      itemBuilder: (context, index) {
                        final r = rutinas[index];
                        return _RutinaCard(rutina: r);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text("Error: ${err.toString()}")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RutinaCard extends StatelessWidget {
  final Rutina rutina;

  const _RutinaCard({required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    image: rutina.imagen != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(rutina.imagen!)),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage("assets/rutina_placeholder.png"),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      rutina.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${rutina.duracion} min",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
