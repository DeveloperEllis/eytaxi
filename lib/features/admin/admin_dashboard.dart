import 'package:eytaxi/features/admin/presentation/screens/trip_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_dashboard_service.dart';
import 'package:eytaxi/features/admin/widgets/admin_drawer.dart';
import 'package:eytaxi/features/admin/widgets/dashboard_stats_grid.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminDashboardService _dashboardService = AdminDashboardService();
  DashboardStats? _stats;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const AdminDrawer(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Panel de Administración',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
    );
  }

  Widget _buildBody() {
    return Padding(padding: const EdgeInsets.all(16), child: _buildContent());
  }

  Widget _buildContent() {
    return Center(child: TripRequestsScreen());
  }
}
