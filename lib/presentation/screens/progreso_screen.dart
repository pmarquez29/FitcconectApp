import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../data/providers/progreso_provider.dart';
import '../../model/progreso.dart';
import '../../model/logro.dart'; // Asegúrate de importar el modelo Logro
import '../widgets/bar_chart_widget.dart';
import '../widgets/registrar_progreso_sheet.dart'; 
import 'historial_rutinas_screen.dart';

class ProgresoScreen extends ConsumerWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos ambos providers para redibujar si hay cambios
    final progresoAsync = ref.watch(progresoProvider);
    final logrosAsync = ref.watch(logrosProvider); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             // Al deslizar hacia abajo, recargamos todo
             ref.refresh(progresoProvider);
             ref.refresh(logrosProvider);
          },
          color: const Color(0xFF2EBD85),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- TITULO ---
                      const Text(
                        "Tu Rendimiento",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Resumen de tu actividad física",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // --- 1. DATA PRINCIPAL (GRÁFICOS Y TARJETAS) ---
                      progresoAsync.when(
                        data: (data) => _buildMainStats(context, data, ref),
                        loading: () => const SizedBox(
                          height: 300, 
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85)))
                        ),
                        error: (e, _) => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                          child: Text("Error cargando progreso: $e", style: TextStyle(color: Colors.red.shade800)),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- 2. SECCIÓN LOGROS (GAMIFICACIÓN) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Mis Logros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          // Contador pequeño de medallas
                          logrosAsync.maybeWhen(
                            data: (lista) {
                              final obtenidos = lista.where((l) => l.obtenido).length;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED), // Fondo naranja muy suave
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5))
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.emoji_events, size: 14, color: Color(0xFFB45309)),
                                    const SizedBox(width: 4),
                                    Text("$obtenidos / ${lista.length}", style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                            orElse: () => const SizedBox(),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // LISTA HORIZONTAL DE MEDALLAS
                      logrosAsync.when(
                        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                        error: (_,__) => const SizedBox(), // Ocultar si falla silenciosamente
                        data: (logros) {
                          if (logros.isEmpty) return const Text("No hay logros configurados.", style: TextStyle(color: Colors.grey));
                          
                          return SizedBox(
                            height: 130, // Altura suficiente para el diseño nuevo
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: logros.length,
                              separatorBuilder: (_,__) => const SizedBox(width: 15),
                              itemBuilder: (ctx, i) => _LogroCard(logro: logros[i]),
                            ),
                          );
                        }
                      ),

                      const SizedBox(height: 80), // Espacio final
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para agrupar las estadísticas principales
  Widget _buildMainStats(BuildContext context, ProgresoData data, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CONTADOR TOTAL (Diseño Premium)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TOTAL COMPLETADO", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("${data.totalRutinasCompletadas}", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Text("Rutinas", style: TextStyle(color: Color(0xFF2EBD85), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
              )
            ],
          ),
        ),

        const SizedBox(height: 30),

        // GRÁFICO SEMANAL
        const Text("Progreso Semanal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
          child: data.progresoSemanal.isNotEmpty 
              ? WeeklyActivityChart(data: data.progresoSemanal) 
              : const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Sin datos recientes.", style: TextStyle(color: Colors.grey)))),
        ),

        const SizedBox(height: 30),

        // RUTINA ACTIVA
        const Text("En Curso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 15),
        _RutinaActivaCard(rutina: data.rutinaHoy, parentContext: context, ref: ref),
        
        const SizedBox(height: 30),

        // HISTORIAL
        if (data.rutinasHechas.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Historial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialRutinasScreen())), 
                  child: const Text("VER TODO", style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold))
                ),
              ],
            ),
            const SizedBox(height: 10),
            _HistorialLista(lista: data.rutinasHechas.take(3).toList()),
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ WIDGET DE LOGRO PREMIUM
// -----------------------------------------------------------------------------
class _LogroCard extends StatelessWidget {
  final Logro logro;

  const _LogroCard({required this.logro});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = logro.obtenido;
    
    return Tooltip(
      // Mensaje flotante con detalles
      message: isUnlocked 
          ? "${logro.nombre}\nConseguido el ${logro.fecha != null ? logro.fecha!.split('T')[0] : ''}" 
          : "${logro.nombre}\n${logro.descripcion}",
      triggerMode: TooltipTriggerMode.tap,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E293B).withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(color: Colors.white),
      
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Fondo degradado si está desbloqueado
          gradient: isUnlocked 
              ? const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFFBEB)], // Blanco a Crema suave
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                )
              : null,
          color: isUnlocked ? null : const Color(0xFFF1F5F9), // Gris plano si bloqueado
          borderRadius: BorderRadius.circular(16),
          // Borde Dorado brillante si desbloqueado
          border: isUnlocked 
              ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: isUnlocked ? [
            BoxShadow(color: Colors.orange.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICONO / MEDALLA
            Container(
              height: 50, 
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Efecto de brillo interior para la medalla
                gradient: isUnlocked 
                    ? const RadialGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)])
                    : null,
                color: isUnlocked ? null : Colors.grey.shade200,
              ),
              child: Center(
                child: isUnlocked 
                    ? Text(logro.icono, style: const TextStyle(fontSize: 28)) // Emoji Real
                    : Icon(Icons.lock, color: Colors.grey.shade400, size: 24), // Candado
              ),
            ),
            const SizedBox(height: 12),
            // NOMBRE DEL LOGRO
            Text(
              logro.nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                // Color más fuerte si está desbloqueado
                color: isUnlocked ? const Color(0xFF1E293B) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS ANTERIORES (Mantener igual para funcionalidad)
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Descanso", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("No tienes rutina activa hoy", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
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
                    percent: r.progreso > 1.0 ? 1.0 : r.progreso, 
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
                await showModalBottomSheet(
                  context: parentContext,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const RegistrarProgresoSheet(),
                );
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
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Color(0xFF2EBD85), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
              ),
              Text(fechaStr, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}