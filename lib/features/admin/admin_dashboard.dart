import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/presentation/screens/trip_requests_screen.dart';
import 'package:eytaxi/features/admin/presentation/screens/pending_requests_screen.dart';
import 'package:eytaxi/features/admin/request_page.dart';
import 'package:eytaxi/features/admin/driver_page.dart';
import 'package:eytaxi/features/admin/excursion_reservations_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _currentPage = const TripRequestsScreen();
  String _currentTitle = 'Gestión de Solicitudes';

  void _changePage(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
    Navigator.pop(context); // Cerrar el drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: _buildDrawer(),
      body: _currentPage,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header
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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Administrador',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Panel de control',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Opciones del menú - SOLICITUDES PRIMERO
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
       
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard Solicitudes',
                  onTap: () => _changePage(
                    const TripRequestsScreen(),
                    'Gestión de Solicitudes',
                  ),
                ),
                
                _buildMenuItem(
                  icon: Icons.person_pin,
                  title: 'Conductores',
                  onTap: () => _changePage(
                    const DriversPage(title: 'Conductores'),
                    'Conductores',
                  ),
                ),
                
                _buildMenuItem(
                  icon: Icons.tour,
                  title: 'Excursiones',
                  onTap: () => _changePage(
                    const ExcursionReservationsPage(),
                    'Excursiones',
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
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

  Widget _buildMenuItem({
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
