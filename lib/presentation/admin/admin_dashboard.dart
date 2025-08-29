import 'package:eytaxi/presentation/admin/driver_page.dart';
import 'package:eytaxi/presentation/admin/pendingdriverpage.dart';
import 'package:eytaxi/presentation/admin/pendingrequestpage.dart';
import 'package:eytaxi/presentation/admin/request_page.dart';
import 'package:eytaxi/presentation/admin/requestwhitdriver.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eytaxi/presentation/admin/excursion_reservations_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int excursionReservations = 0;
  int totalRequests = 0;
  int pendingRequests = 0;
  int totalDrivers = 0;
  int pendingDrivers = 0;
  int acceptedRequests = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    // Reservas de excursiones
    final client = Supabase.instance.client;
    final excursionRes = await client.from('reservas_excursiones').select();

    // Solicitudes de viaje
    final requests = await client.from('trip_requests').select();
    final pendingReqs = await client
        .from('trip_requests')
        .select()
        .eq('status', 'pending');

    // Conductores
    final drivers = await client.from('drivers').select();
    final pendingDrvs = await client
        .from('drivers')
        .select()
        .eq('driver_status', 'pending');

    // Solicitudes aceptadas: cuentan cuántas tienen choferes interesados
    final accepted = await client
        .from('driver_responses')
        .select('request_id')
        .not('request_id', 'is', null);

    setState(() {
      excursionReservations = (excursionRes as List).length;
      totalRequests = (requests as List).length;
      pendingRequests = (pendingReqs as List).length;
      totalDrivers = (drivers as List).length;
      pendingDrivers = (pendingDrvs as List).length;
      acceptedRequests = (accepted as List).length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Administrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Panel de control',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.tour),
              title: const Text('Reservas Excursiones'),
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
            // Aquí puedes agregar más opciones en el futuro
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1100
                      ? 4
                      : constraints.maxWidth > 800
                          ? 3
                          : 2;
                  return GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.18,
                    ),
                    children: [
                        _buildNavCard(
                          context,
                          'Solicitudes',
                          totalRequests,
                          Icons.assignment,
                          Colors.blue.shade600,
                          const RequestsPage(title: ''),
                        ),
                        _buildNavCard(
                          context,
                          'Pendientes',
                          pendingRequests,
                          Icons.pending_actions,
                          Colors.orange.shade600,
                          const PendingRequestsPage(),
                        ),
                        _buildNavCard(
                          context,
                          'Conductores',
                          totalDrivers,
                          Icons.person,
                          Colors.green.shade600,
                          const DriversPage(title: ''),
                        ),
                        _buildNavCard(
                          context,
                          'Drivers Pend.',
                          pendingDrivers,
                          Icons.person_search,
                          Colors.deepPurple.shade600,
                          const PendingDriversPage(),
                        ),
                        _buildNavCard(
                          context,
                          'Solicitudes Aceptadas',
                          acceptedRequests,
                          Icons.check_circle,
                          Colors.teal.shade600,
                          const RequestsWithResponsesPage(),
                        ),
                        _buildNavCard(
                          context,
                          'Reservas Excursiones',
                          excursionReservations,
                          Icons.tour,
                          Colors.pink.shade400,
                          const ExcursionReservationsPage(),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2.5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
