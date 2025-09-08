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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final stats = await _dashboardService.fetchDashboardStats();
      
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar las estadísticas: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const AdminDrawer(),
      body: _buildBody(),
      floatingActionButton: _buildRefreshButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Panel de Administración',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardStats,
          tooltip: 'Actualizar estadísticas',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando estadísticas...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardStats,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_stats == null) {
      return const Center(
        child: Text('No se pudieron cargar las estadísticas'),
      );
    }

    return DashboardStatsGrid(stats: _stats!);
  }

  Widget _buildRefreshButton() {
    return FloatingActionButton(
      onPressed: _isLoading ? null : _loadDashboardStats,
      backgroundColor: Colors.blue.shade700,
      child: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.refresh),
    );
  }
}
