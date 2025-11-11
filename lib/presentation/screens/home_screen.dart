import 'package:app_fitconnect/data/providers/dashboard_alumno_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/dashboard_alumno.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/line_chart_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardAlumnoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Error: $err",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) {
          final alumno = data.alumno;
          final progreso = data.progreso;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CABECERA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/logo.png", height: 50),
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            NetworkImage("https://i.pravatar.cc/100?img=12"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- SALUDO Y DISCIPLINA ---
                  Text(
                    "¡Hola, ${alumno.nombre} 👋!",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D47A1),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alumno.disciplina != null
                        ? "Disciplina: ${alumno.disciplina}"
                        : "Sin disciplina asignada",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  if (alumno.instructor != null)
                    Text(
                      "Instructor: ${alumno.instructor}",
                      style: const TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 20),

                  // --- TARJETAS DE PROGRESO ---
                  DashboardCards(
                    progreso: "${progreso.general.toStringAsFixed(1)}%",
                    completado: "${progreso.completadas}",
                    total: "${progreso.totalRutinas}",
                    pendientes: "${progreso.pendientes}",
                  ),
                  const SizedBox(height: 25),

                  // --- GRÁFICO DE RACHA ---
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📈 Progreso en Racha de Días",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (progreso.racha.isEmpty)
                            const Text(
                              "Aún no hay datos de racha disponibles.",
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            LineChartWidget(
                              racha: progreso.racha
                                  .map((r) =>
                                      {"dia": r.dia, "valor": r.valor})
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- RUTINA ACTIVA ---
                  if (data.rutinaActiva != null)
                    _buildRutinaActivaCard(data.rutinaActiva!),

                  const SizedBox(height: 30),

                  // --- ACTIVIDADES RECIENTES ---
                  const Text(
                    "🕒 Actividades recientes",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1565C0)),
                  ),
                  const SizedBox(height: 10),

                  if (data.actividadesRecientes.isEmpty)
                    const Center(
                      child: Text(
                        "Aún no hay actividades registradas.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...data.actividadesRecientes
                        .map((act) => _ActividadTile(act: act))
                        .toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRutinaActivaCard(RutinaActiva rutina) {
    return Card(
      color: const Color(0xFF3DC682),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🏃‍♀️ Rutina Activa",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text(
              rutina.nombre,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              rutina.objetivo,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (rutina.progreso.clamp(0, 100)) / 100,
              color: Colors.white,
              backgroundColor: Colors.white24,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "CONTINUAR ENTRENAMIENTO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ActividadTile extends StatelessWidget {
  final ActividadReciente act;

  const _ActividadTile({required this.act});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              act.completado ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            act.completado ? Icons.check : Icons.close,
            color: act.completado ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          act.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${act.fecha} • ${act.calorias != null ? "${act.calorias} cal" : '-'}",
        ),
      ),
    );
  }
}
