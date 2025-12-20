import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../data/providers/progreso_provider.dart';
import '../../model/progreso.dart';
// Importamos los componentes necesarios
import '../widgets/bar_chart_widget.dart'; 
import '../widgets/registrar_progreso_sheet.dart'; 
import 'historial_rutinas_screen.dart';

class ProgresoScreen extends ConsumerWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progresoAsync = ref.watch(progresoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(progresoProvider),
          color: const Color(0xFF2EBD85),
          child: progresoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
            error: (err, _) => Center(child: Text("Error cargando datos: $err")),
            data: (progreso) => _buildBody(context, progreso, ref),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProgresoData data, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          const Text(
            "Tu Rendimiento",
            style: TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.w800, 
              color: Color(0xFF1E293B),
              letterSpacing: -0.5
            ),
          ),
          const Text(
            "Resumen de tu actividad física",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // 2. TARJETA RUTINA ACTIVA (HOY)
          _RutinaActivaCard(rutina: data.rutinaHoy, parentContext: context, ref: ref),

          const SizedBox(height: 24),

          // 3. GRÁFICO SEMANAL
          const Text("Progreso Semanal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 5),
          const Text("Rutinas completadas por semana", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 15),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: data.progresoSemanal.isNotEmpty 
                // ✅ Pasamos los datos del nuevo endpoint
                ? WeeklyActivityChart(data: data.progresoSemanal) 
                : const Center(child: Text("Sin datos recientes.", style: TextStyle(color: Colors.grey))),
          ),

          const SizedBox(height: 24),

          // 4. HISTORIAL
          if (data.rutinasHechas.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Historial Reciente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                TextButton(
                  onPressed: () {
                    // ✅ NAVEGACIÓN A HISTORIAL
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistorialRutinasScreen()),
                    );
                  }, 
                  child: const Text("VER TODO", style: TextStyle(color: Color(0xFF2EBD85), fontWeight: FontWeight.bold))
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HistorialLista(lista: data.rutinasHechas.take(3).toList()), // Solo mostramos las 3 últimas
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS
// -----------------------------------------------------------------------------

class _RutinaActivaCard extends StatelessWidget {
  final RutinaHoy? rutina;
  final BuildContext parentContext;
  final WidgetRef ref;

  const _RutinaActivaCard({this.rutina, required this.parentContext, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (rutina == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.bed_outlined, color: Colors.grey, size: 30),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Descanso", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("No tienes rutina activa hoy", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      );
    }

    final r = rutina!;
    final porcentaje = (r.progreso * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Color(0xFF2EBD85), size: 14),
                    SizedBox(width: 4),
                    Text("EN PROGRESO", style: TextStyle(color: Color(0xFF2EBD85), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Icono visual
              Icon(Icons.fitness_center, color: Colors.white.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            r.nombre,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${r.completados} de ${r.totalEjercicios} ejercicios completados",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearPercentIndicator(
                    lineHeight: 6.0,
                    percent: r.progreso > 1.0 ? 1.0 : r.progreso, // Evitar overflow
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    progressColor: const Color(0xFF2EBD85),
                    barRadius: const Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text("$porcentaje%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // ✅ FUNCIONALIDAD: ABRIR SHEET DE REGISTRO
                await showModalBottomSheet(
                  context: parentContext,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const RegistrarProgresoSheet(
                    // Sin ID específico, carga la lista general
                  ),
                );
                // Al volver, recargar datos para actualizar la barra
                ref.refresh(progresoProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EBD85),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text("CONTINUAR (${r.tiempoRestante})", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class _HistorialLista extends StatelessWidget {
  final List<RutinaHecha> lista;

  const _HistorialLista({required this.lista});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lista.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = lista[i];
        // Parsear fecha
        String fechaStr = "";
        try {
          final dt = DateTime.parse(r.fecha);
          fechaStr = "${dt.day}/${dt.month}";
        } catch (_) {}

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF2EBD85), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  r.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                ),
              ),
              Text(
                fechaStr,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

