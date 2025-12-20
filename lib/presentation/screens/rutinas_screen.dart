import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/notificaciones_provider.dart';
import '../../data/providers/rutina_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../model/rutina.dart';
import 'rutina_detalle_screen.dart';

class RutinasScreen extends ConsumerWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinasAsync = ref.watch(rutinasAlumnoProvider);
    final user = ref.watch(authProvider).user;
    
    // 🔥 TRUCO: Escuchamos el contador de notificaciones. 
    // Si cambia (llega una noti por socket), refrescamos las rutinas automáticamente.
    ref.listen(notificationCountProvider, (previous, next) {
      if (next > (previous ?? 0)) {
        print("🔔 Nueva notificación detectada, recargando rutinas...");
        ref.refresh(rutinasAlumnoProvider);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(rutinasAlumnoProvider),
          color: const Color(0xFF2EBD85),
          child: CustomScrollView(
            slivers: [
              // 1. APPBAR PERSONALIZADO (Sliver para que scrollee bonito)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/logo.png", 
                                height: 24, 
                                errorBuilder: (_,__,___) => const Icon(Icons.fitness_center, color: Color(0xFF2EBD85), size: 24)
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "FITCONNECT",
                                style: TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w900, 
                                  color: Color(0xFF94A3B8), 
                                  letterSpacing: 1.5
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tus Entrenamientos",
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.w800, 
                              color: Color(0xFF1E293B)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. CALENDARIO SEMANAL
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              const SliverToBoxAdapter(child: _WeeklyCalendar()),
              const SliverToBoxAdapter(child: SizedBox(height: 25)),

              // 3. LISTA DE RUTINAS
              rutinasAsync.when(
                data: (rutinas) {
                  if (rutinas.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _RutinaCardPro(rutina: rutinas[index]),
                          );
                        },
                        childCount: rutinas.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                ),
              ),
              
              // Espacio final para que el FAB o BottomNav no tapen
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
              ]
            ),
            child: Icon(Icons.assignment_late_outlined, size: 50, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Text(
            "Sin rutinas asignadas",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            "Desliza hacia abajo para actualizar",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ... (El widget _WeeklyCalendar se mantiene igual que antes) ...
class _WeeklyCalendar extends StatelessWidget {
  const _WeeklyCalendar();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Lunes
    final monday = now.subtract(Duration(days: today - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final labels = ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"];

    return SizedBox(
      height: 85,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = days[index];
          final isToday = date.day == now.day && date.month == now.month;

          return Container(
            width: 60,
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF2EBD85) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                if (isToday)
                  BoxShadow(color: const Color(0xFF2EBD85).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                else
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
              ],
              border: isToday ? null : Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white.withOpacity(0.8) : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${date.day}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isToday ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ... (El widget _RutinaCardPro se mantiene igual, llamando a RutinaDetalleScreen) ...
class _RutinaCardPro extends StatelessWidget {
  final Rutina rutina;

  const _RutinaCardPro({required this.rutina});

  ImageProvider _getImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const AssetImage("assets/rutina_placeholder.png");
    }
    try {
      final cleanBase64 = base64String.contains(',') ? base64String.split(',').last : base64String;
      return MemoryImage(base64Decode(cleanBase64));
    } catch (_) {
      return const AssetImage("assets/rutina_placeholder.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RutinaDetalleScreen(rutina: rutina)),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
          ],
          image: DecorationImage(
            image: _getImageProvider(rutina.imagen),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rutina.nivel.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text("${rutina.duracion} min", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rutina.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rutina.objetivo,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      if (rutina.progreso > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Completado", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                            Text("${rutina.progreso}%", style: const TextStyle(color: Color(0xFF2EBD85), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rutina.progreso / 100,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF2EBD85)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}