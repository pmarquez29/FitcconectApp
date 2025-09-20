import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Mock data
  final alumno = {
    "nombre": "Juan Pérez",
    "edad": 24,
    "genero": "Masculino",
    "fechaNacimiento": "15/03/2001",
    "email": "juan.perez@example.com",
    "instructor": "Carlos Gómez",
    "totalEntrenamientos": 85,
    "ejerciciosDominados": 12,
  };

  bool notificaciones = true;
  bool modoVacaciones = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=8"),
                ),
                const SizedBox(width: 16),
                Text(
                  alumno["nombre"]! as String,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección Cuenta
            const Text("Cuenta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  _InfoTile(title: "Edad", value: "${alumno["edad"]} años"),
                  _InfoTile(title: "Género", value: alumno["genero"] as String),
                  _InfoTile(title: "Fecha de nacimiento", value: alumno["fechaNacimiento"] as String),
                  _InfoTile(title: "Correo electrónico", value: alumno["email"]! as String),
                  _InfoTile(title: "Instructor", value: alumno["instructor"]! as String),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección General
            const Text("General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Notificaciones"),
                    value: notificaciones,
                    onChanged: (val) => setState(() => notificaciones = val),
                  ),
                  SwitchListTile(
                    title: const Text("Modo vacaciones"),
                    value: modoVacaciones,
                    onChanged: (val) => setState(() => modoVacaciones = val),
                  ),
                  _InfoTile(
                      title: "Total entrenamientos",
                      value: "${alumno["totalEntrenamientos"]}"),
                  _InfoTile(
                      title: "Ejercicios dominados",
                      value: "${alumno["ejerciciosDominados"]}"),
                  ListTile(
                    title: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    onTap: () {
                      // Aquí se implementará el logout real
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sesión cerrada")),
                      );
                    },
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

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
