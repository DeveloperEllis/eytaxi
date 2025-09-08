import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/excursion_reservations_page.dart';
import 'package:eytaxi/features/admin/presentation/screens/trip_requests_screen.dart';
// Ensure that TripRequestsScreen is defined in the imported file.

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header mejorado
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar/Icono
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Título
                    const Text(
                      'Administrador',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Subtítulo
                    Text(
                      'Panel de control',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Opciones del menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.local_taxi,
                  title: 'Solicitudes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TripRequestsScreen(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.person_pin,
                  title: 'Drivers',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implementar página de drivers
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.tour,
                  title: 'Excursiones',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExcursionReservationsPage(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implementar página de configuración
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.analytics,
                  title: 'Reportes',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implementar página de reportes
                  },
                ),
              ],
            ),
          ),
          
          // Footer del drawer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue.shade700,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
