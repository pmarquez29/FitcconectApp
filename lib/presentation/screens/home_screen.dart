import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/dashboard_alumno_provider.dart';
import '../../model/dashboard_alumno.dart';
import '../widgets/custom_header.dart';
import '../widgets/activity_chart.dart';
import '../widgets/registrar_progreso_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardAlumnoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Gris azulado moderno
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(dashboardAlumnoProvider),
              color: const Color(0xFF10B981),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // 2. Tarjeta de Resumen Global "Pro"
                    _ProfessionalStatsSummary(progreso: data.progreso),

                    const SizedBox(height: 30),

                    // 3. Título: Próximo Reto
                    const Text("TU PRÓXIMO RETO", style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, 
                      color: Color(0xFF94A3B8), letterSpacing: 1.2
                    )),
                    const SizedBox(height: 15),

                    // 4. Tarjeta Verde (Rutina Actual)
                    if (data.rutinaActiva != null)
                      _ActiveRoutineGreenCard(rutina: data.rutinaActiva!)
                    else
                      const _NoRoutineCard(),

                    const SizedBox(height: 35),
                    
                    // 5. Gráfico de Rendimiento
                    const Text("RENDIMIENTO", style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, 
                      color: Color(0xFF94A3B8), letterSpacing: 1.2
                    )),
                    const SizedBox(height: 15),
                    ModernLineChart(racha: data.progreso.racha),

                    const SizedBox(height: 30),

                    // 6. Actividades Recientes
                    // (Aquí eliminamos la tarjeta duplicada que tenías antes)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Actividades recientes",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1E293B)
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Ver todo →", style: TextStyle(color: Color(0xFF64748B))),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (data.actividadesRecientes.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Sin actividad reciente", style: TextStyle(color: Colors.grey)),
                      ))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.actividadesRecientes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _ActivityTile(act: data.actividadesRecientes[index]);
                        },
                      ),
                    
                    const SizedBox(height: 80), // Espacio final
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

// ---------------------------------------------------------------------------
// 🔹 WIDGETS DE DISEÑO ESPECÍFICO
// ---------------------------------------------------------------------------

class _ProfessionalStatsSummary extends StatelessWidget {
  final ProgresoInfo progreso;
  const _ProfessionalStatsSummary({required this.progreso});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // LADO IZQUIERDO: Gráfico Circular
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progreso.totalRutinas > 0 
                      ? (progreso.completadas / progreso.totalRutinas) 
                      : 0.0,
                  strokeWidth: 10,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2EBD85)),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${progreso.general.toInt()}%",
                        style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)
                        ),
                      ),
                      const Text("TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(width: 20),
          
          // LADO DERECHO: Estadísticas Clave
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Objetivo Global", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  "Has completado ${progreso.completadas} de ${progreso.totalRutinas} rutinas.",
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // 🟢 CORRECCIÓN: Usamos Wrap para evitar Overflow
                Wrap(
                  spacing: 8.0,    // Espacio horizontal
                  runSpacing: 8.0, // Espacio vertical
                  children: [
                    _MiniBadge(
                      label: "Pendientes", 
                      val: "${progreso.pendientes}", 
                      color: Colors.orangeAccent
                    ),
                    _MiniBadge(
                      label: "Completadas", 
                      val: "${progreso.completadas}", 
                      color: const Color(0xFF2EBD85)
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final String val;
  final Color color;

  const _MiniBadge({required this.label, required this.val, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding ajustado para ser más compacto
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            "$val $label", 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))
          ),
        ],
      ),
    );
  }
}

class _ActiveRoutineGreenCard extends ConsumerWidget {
  final RutinaActiva rutina;
  const _ActiveRoutineGreenCard({required this.rutina});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF10B981)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, top: -20,
            child: CircleAvatar(radius: 90, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            left: -30, bottom: -30,
            child: CircleAvatar(radius: 70, backgroundColor: Colors.white.withOpacity(0.1)),
          ),

          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.orangeAccent, size: 16),
                      SizedBox(width: 6),
                      Text("RUTINA DE HOY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  rutina.nombre,
                  style: const TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white,
                    height: 1.1
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text("45 min estimados", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),

                const SizedBox(height: 30),

                // Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassStat(value: "${(rutina.progreso/10).ceil()}/10", label: "Ejercicios"),
                    const _GlassStat(value: "320", label: "Calorías"),
                    const _GlassStat(value: "28", label: "Minutos", unit: "min"),
                  ],
                ),

                const SizedBox(height: 30),

                // Barra de Progreso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tu progreso", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text("${rutina.progreso.toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (rutina.progreso / 100).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white), 
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const RegistrarProgresoSheet(), 
                      );

                      if (result == true) {
                        ref.refresh(dashboardAlumnoProvider);
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF10B981),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("CONTINUAR ENTRENAMIENTO", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;

  const _GlassStat({required this.value, required this.label, this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          if (unit != null)
             Text(unit!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActividadReciente act;
  const _ActivityTile({required this.act});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: act.completado ? const Color(0xFFFFEDD5) : const Color(0xFFF1F5F9), 
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fitness_center, 
              color: act.completado ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  "${act.fecha} • ${act.calorias ?? '-'} cal",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Hoy", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)), 
              const SizedBox(height: 2),
              Text("2:30 PM", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          )
        ],
      ),
    );
  }
}

class _NoRoutineCard extends StatelessWidget {
  const _NoRoutineCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Center(child: Text("Sin rutina asignada")),
    );
  }
}