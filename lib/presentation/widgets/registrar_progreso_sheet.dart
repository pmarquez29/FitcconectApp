import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fitconnect/data/providers/api_provider.dart';

// Modelo simple local para el ejercicio
class EjercicioSimple {
  final int id;
  final String nombre;
  final bool completado;
  final int progresoId; // ID de la tabla seguimiento

  EjercicioSimple({required this.id, required this.nombre, required this.completado, required this.progresoId});

  factory EjercicioSimple.fromJson(Map<String, dynamic> json) {
    return EjercicioSimple(
      id: json['id'],
      nombre: json['nombre'],
      completado: json['completado'],
      progresoId: json['progreso_id'] ?? 0,
    );
  }
}

class RegistrarProgresoSheet extends ConsumerStatefulWidget {
  final int? preSelectedEjercicioId; // ID del ejercicio si venimos del detalle
  final int? asignacionId; // ID de la asignación si ya la sabemos
  const RegistrarProgresoSheet({
    super.key, 
    this.preSelectedEjercicioId,
    this.asignacionId
  });

  @override
  ConsumerState<RegistrarProgresoSheet> createState() => _RegistrarProgresoSheetState();
}

class _RegistrarProgresoSheetState extends ConsumerState<RegistrarProgresoSheet> {
  bool _loading = true;
  List<EjercicioSimple> _ejercicios = [];
  int? _selectedProgresoId;
  
  // Controladores
  final _seriesCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedProgresoId = widget.preSelectedEjercicioId; 
    _cargarEjercicios();
  }

  Future<void> _cargarEjercicios() async {
    try {
      final api = ref.read(apiClientProvider);
      
      // ✅ ENVIAR ID ESPECÍFICO
      String endpoint = "progreso/mis-ejercicios";
      if (widget.asignacionId != null) {
        endpoint += "?asignacion_id=${widget.asignacionId}";
      }

      final response = await api.get(endpoint); 
      
      final lista = (response as List).map((e) => EjercicioSimple.fromJson(e)).toList();
      
      if (mounted) {
        setState(() {
          _ejercicios = lista; // Ya no filtramos localmente, el backend trae lo correcto
          
          // Validación anti-crash
          if (widget.preSelectedEjercicioId != null) {
            final existe = _ejercicios.any((e) => e.progresoId == widget.preSelectedEjercicioId);
            if (existe) {
              _selectedProgresoId = widget.preSelectedEjercicioId;
            } else {
              _selectedProgresoId = null;
            }
          }
          
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      print("Error cargando ejercicios: $e");
    }
  }

Future<void> _guardarProgreso() async {
    if (_selectedProgresoId == null) return;

    try {
      final api = ref.read(apiClientProvider);
      
      // ✅ CAMBIO: Usamos el endpoint específico de alumno
      await api.post("progreso/alumno/registrar", {
        "progreso_id": _selectedProgresoId, // Enviamos el ID directo del seguimiento
        "series_completadas": int.tryParse(_seriesCtrl.text) ?? 0,
        "repeticiones_realizadas": _repsCtrl.text,
        "peso_utilizado": double.tryParse(_pesoCtrl.text) ?? 0,
        "dificultad_percibida": 5, 
        "completado": true
      });

      if (mounted) {
        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Ejercicio registrado! 💪"),
            backgroundColor: Color(0xFF2EBD85),
            behavior: SnackBarBehavior.floating,
          )
        );
        Navigator.pop(context, true); // Cierra y recarga
      }
    } catch (e) {
      // Manejo de error mejorado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString().replaceAll('Exception:', '')}"),
            backgroundColor: Colors.redAccent,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Registrar Avance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_ejercicios.isEmpty)
            const Center(child: Text("¡Rutina completada por hoy! 🎉", style: TextStyle(fontSize: 16, color: Colors.green)))
          else
            Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Selecciona Ejercicio",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: _selectedProgresoId,
                  items: _ejercicios.map((e) {
                    return DropdownMenuItem(value: e.progresoId, child: Text(e.nombre));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedProgresoId = val),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _seriesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDeco("Series", Icons.repeat),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _repsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDeco("Reps", Icons.fitness_center),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _pesoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco("Peso (kg)", Icons.monitor_weight_outlined),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardarProgreso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EBD85),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("MARCAR COMPLETADO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    );
  }
}