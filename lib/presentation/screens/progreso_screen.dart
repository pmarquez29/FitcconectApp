import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../data/providers/progreso_provider.dart';
import '../../model/progreso.dart';

class ProgresoScreen extends ConsumerWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progresoAsync = ref.watch(progresoProvider);

    return Scaffold(
      body: progresoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (progreso) => _buildUI(context, progreso),
      ),
    );
  }

  Widget _buildUI(BuildContext context, ProgresoData progreso) {
    final actividad = progreso.actividadSemanal;
    final hoy = progreso.rutinaHoy;
    final rapidas = progreso.rutinasRapidas;
    final hechas = progreso.rutinasHechas;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -----------------------------
            // HEADER
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("PROGRESO PERSONAL",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150?img=12"),
                )
              ],
            ),

            const SizedBox(height: 20),

            // -----------------------------
            // TARJETA DE PROGRESO TOTAL
            // -----------------------------
            _tarjetaProgresoTotal(progreso),

            const SizedBox(height: 25),

            // -----------------------------
            // ACTIVIDAD SEMANAL
            // -----------------------------
            const Text("Actividad semanal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _graficoSemanal(actividad),

            const SizedBox(height: 25),

            // -----------------------------
            // RUTINA HOY
            // -----------------------------
            const Text("Rutina de hoy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            hoy == null ? _noHayRutina() : _tarjetaRutinaHoy(hoy),

            const SizedBox(height: 25),

            // -----------------------------
            // REVISION RAPIDA
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Revisión rápida",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("VER TODO", style: TextStyle(color: Colors.blue))
              ],
            ),
            const SizedBox(height: 10),

            _listaRutinasRapidas(rapidas),

            const SizedBox(height: 25),

            // -----------------------------
            // RUTINAS HECHAS
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Completados",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("VER TODO", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 10),

            _listaRutinasHechas(hechas),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TARJETA PROGRESO TOTAL
  // ============================================================================
  Widget _tarjetaProgresoTotal(ProgresoData p) {
    final totalSemanas = p.actividadSemanal.length;
    final completadas = p.actividadSemanal
        .where((e) => e.valor > 0)
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black87, Colors.blueGrey],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Círculo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent, width: 4),
            ),
            child: Center(
              child: Text(
                completadas.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Texto
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Semana",
                  style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("$completadas / $totalSemanas completadas",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // ============================================================================
  // GRAFICO SEMANAL
  // ============================================================================
  Widget _graficoSemanal(List<ActividadSemanal> actividad) {
    if (actividad.isEmpty) {
      return const Text("Aún no hay actividad semanal registrada.");
    }

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: actividad
            .map((e) => Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        height: (e.valor / 200) * 150,
                        duration: const Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.blueAccent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("S${e.semana}", style: const TextStyle(fontSize: 12))
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ============================================================================
  // TARJETA RUTINA HOY
  // ============================================================================
  Widget _tarjetaRutinaHoy(RutinaHoy r) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.nombre,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(r.tiempoRestante),
                ]),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Continuar"),
                )
              ],
            ),

            const SizedBox(height: 12),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: r.progreso,
              backgroundColor: Colors.grey.shade300,
              progressColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _noHayRutina() {
    return const Text("No tienes rutina asignada para hoy.");
  }

  // ============================================================================
  // LISTA RUTINAS RAPIDAS
  // ============================================================================
  Widget _listaRutinasRapidas(List<RutinaRapida> rapidas) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rapidas.length,
        itemBuilder: (_, i) {
          final r = rapidas[i];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: r.progreso,
                            strokeWidth: 6,
                            color: Colors.blue,
                          ),
                        ),
                        const Icon(Icons.fitness_center,
                            color: Colors.blue, size: 32)
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      r.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                        onPressed: () {}, child: const Text("Ver")),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================================
  // LISTA RUTINAS HECHAS
  // ============================================================================
  Widget _listaRutinasHechas(List<RutinaHecha> hechas) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hechas.length,
        itemBuilder: (_, i) {
          final r = hechas[i];
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
                    const Icon(Icons.check_circle,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(
                      r.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
