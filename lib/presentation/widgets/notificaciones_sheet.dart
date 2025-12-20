import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/notificaciones_provider.dart';
import '../../model/notificacion.dart';

class NotificacionesSheet extends ConsumerWidget {
  const NotificacionesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificacionesAsync = ref.watch(notificacionesListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // CABECERA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Notificaciones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(width: 8),
                    // Contador pequeño
                    if (notificacionesAsync.asData?.value.isNotEmpty ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF2EBD85).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "${notificacionesAsync.asData!.value.length} nuevas",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF2EBD85), fontWeight: FontWeight.bold),
                        ),
                      )
                  ],
                ),
                // Botón cerrar
                IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          const Divider(),
          
          // LISTA
          Expanded(
            child: notificacionesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2EBD85))),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (lista) {
                if (lista.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.done_all, size: 50, color: Colors.grey.shade300),
                      ),
                      const SizedBox(height: 15),
                      const Text("¡Estás al día!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      const Text("No tienes notificaciones pendientes.", style: TextStyle(color: Colors.grey)),
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: lista.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final notif = lista[index];
                    // Usamos Dismissible para poder deslizar para borrar también
                    return Dismissible(
                      key: Key(notif.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        ref.read(notificacionesListProvider.notifier).marcarUnaComoLeida(notif.id);
                      },
                      child: _NotificacionItem(
                        notificacion: notif,
                        onTap: () {
                          // Al tocar, se marca leída y desaparece
                          ref.read(notificacionesListProvider.notifier).marcarUnaComoLeida(notif.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificacionItem extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback onTap;

  const _NotificacionItem({required this.notificacion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4), // Fondo verdoso suave (indicando nuevo)
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2EBD85).withOpacity(0.3)),
          boxShadow: [
             BoxShadow(color: const Color(0xFF2EBD85).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2EBD85).withOpacity(0.2)),
              ),
              child: Icon(
                _getIcono(notificacion.tipo), 
                color: const Color(0xFF2EBD85), 
                size: 20
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notificacion.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                      const CircleAvatar(radius: 4, backgroundColor: Color(0xFF2EBD85)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notificacion.mensaje,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatFecha(notificacion.fecha),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcono(String tipo) {
    switch (tipo) {
      case 'rutina': return Icons.fitness_center;
      case 'recordatorio': return Icons.event_note;
      case 'alerta': return Icons.warning_amber_rounded;
      default: return Icons.notifications;
    }
  }

  String _formatFecha(String dateStr) {
    try {
      final now = DateTime.now();
      final date = DateTime.parse(dateStr).toLocal();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return "Hace ${diff.inMinutes} min";
      if (diff.inHours < 24) return "Hace ${diff.inHours} horas";
      return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) { return ""; }
  }
}