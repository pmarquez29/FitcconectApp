import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importamos providers
import '../../data/providers/auth_provider.dart';
import '../../data/providers/mensaje_provider.dart'; // Necesario para el listener de notificaciones
import '../../data/providers/notificaciones_provider.dart'; // Si usas uno separado para el contador

// Importamos pantallas
import '../screens/home_screen.dart';
import '../screens/rutinas_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/progreso_screen.dart';
import '../screens/perfil_screen.dart';
// Importamos widgets
import '../widgets/custom_header.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  // Títulos dinámicos según la pestaña
  final List<String> _titles = [
    "Inicio",        
    "Mis Rutinas",   
    "Mensajes",      
    "Mi Progreso",   
    "Perfil",        
  ];

  final List<String> _subtitles = [
    "Resumen de hoy",
    "Lista de entrenamientos",
    "Consulta con tu instructor",
    "Estadísticas y logros",
    "Datos personales",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationListenerProvider);
    
    final user = ref.watch(authProvider).user;
    final nombreUsuario = user?.nombre.split(' ')[0] ?? "Alumno";

    // Lista de pantallas
    final List<Widget> screens = [
      const HomeScreen(),
      const RutinasScreen(),
      const ChatScreen(),
      const ProgresoScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ HEADER GLOBAL: Persistente en todas las pestañas
            CustomHeader(
              // Si es Home (índice 0), mostramos saludo, si no, el título de la sección
              title: _selectedIndex == 0 
                  ? "Hola, $nombreUsuario 👋" 
                  : _titles[_selectedIndex],
              subtitle: _subtitles[_selectedIndex],
              // Ocultamos la campana en la pantalla de chat para evitar redundancia
              showNotification: _selectedIndex != 2, 
              onProfileTap: () {
                  _onItemTapped(4); // Cambiamos al índice 4 (Perfil)
                },
              ),

            // ✅ CUERPO CAMBIANTE
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
          ],
        ),
      ),
      
      // ✅ BARRA DE NAVEGACIÓN PROFESIONAL
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 0, 47, 255), // Verde FitConnect
          unselectedItemColor: const Color(0xFF94A3B8), // Gris azulado
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), 
              activeIcon: Icon(Icons.home_rounded),
              label: "Inicio"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded), 
              label: "Rutinas"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded), 
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: "Chat"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), 
              label: "Progreso"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), 
              activeIcon: Icon(Icons.person_rounded),
              label: "Perfil"
            ),
          ],
        ),
      ),
    );
  }
}