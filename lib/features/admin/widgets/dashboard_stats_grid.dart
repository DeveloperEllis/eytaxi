import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_dashboard_service.dart';
import 'package:eytaxi/features/admin/widgets/dashboard_nav_card.dart';
import 'package:eytaxi/features/admin/driver_page.dart';
import 'package:eytaxi/features/admin/pendingdriverpage.dart';
import 'package:eytaxi/features/admin/pendingrequestpage.dart';
import 'package:eytaxi/features/admin/request_page.dart';
import 'package:eytaxi/features/admin/requestwhitdriver.dart';
import 'package:eytaxi/features/admin/excursion_reservations_page.dart';

class DashboardStatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const DashboardStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid columns
        int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: _buildStatCards(),
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  List<Widget> _buildStatCards() {
    return [
      DashboardNavCard(
        label: 'Solicitudes',
        value: stats.totalRequests,
        icon: Icons.assignment,
        color: Colors.blue.shade600,
        page: const RequestsPage(title: ''),
      ),
      DashboardNavCard(
        label: 'Pendientes',
        value: stats.pendingRequests,
        icon: Icons.pending_actions,
        color: Colors.orange.shade600,
        page: const PendingRequestsPage(),
      ),
      DashboardNavCard(
        label: 'Conductores',
        value: stats.totalDrivers,
        icon: Icons.person,
        color: Colors.green.shade600,
        page: const DriversPage(title: ''),
      ),
      DashboardNavCard(
        label: 'Drivers Pend.',
        value: stats.pendingDrivers,
        icon: Icons.person_search,
        color: Colors.deepPurple.shade600,
        page: const PendingDriversPage(),
      ),
      DashboardNavCard(
        label: 'Solicitudes Aceptadas',
        value: stats.acceptedRequests,
        icon: Icons.check_circle,
        color: Colors.teal.shade600,
        page: const RequestsWithResponsesPage(),
      ),
      DashboardNavCard(
        label: 'Reservas Excursiones',
        value: stats.excursionReservations,
        icon: Icons.tour,
        color: Colors.pink.shade400,
        page: const ExcursionReservationsPage(),
      ),
    ];
  }
}
