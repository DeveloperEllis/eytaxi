import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_trip_request_service.dart';
import 'dart:developer' as developer;

class TripRequestsScreen extends StatefulWidget {
  const TripRequestsScreen({super.key});

  @override
  State<TripRequestsScreen> createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  final AdminTripRequestService _service = AdminTripRequestService();
  Map<String, int> _requestCounts = {};
  Map<String, int> _taxiTypeCounts = {};
  int _totalRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRequestCounts();
  }

  Future<void> _loadRequestCounts() async {
    try {
      developer.log('🔄 TripRequestsScreen: Cargando contadores de solicitudes', name: 'TripRequestsScreen');
      
      // Usar el nuevo método que aplica los mismos filtros que las pantallas
      final realCounts = await _service.getRealRequestCounts();
      final taxiTypeCounts = await _service.getRequestCountsByTaxiType();
      
      if (mounted) {
        setState(() {
          _requestCounts = realCounts;
          _taxiTypeCounts = taxiTypeCounts;
          _totalRequestsCount = realCounts['all'] ?? 0;
        });
        
        developer.log('✅ TripRequestsScreen: Contadores reales cargados: $realCounts', name: 'TripRequestsScreen');
        developer.log('✅ TripRequestsScreen: Contadores taxi: $taxiTypeCounts', name: 'TripRequestsScreen');
        developer.log('✅ TripRequestsScreen: Total solicitudes: $_totalRequestsCount', name: 'TripRequestsScreen');
      }
    } catch (e) {
      developer.log('❌ TripRequestsScreen: Error al cargar contadores: $e', name: 'TripRequestsScreen');
    }
  }

  int _getTotalRequests() {
    return _totalRequestsCount;
  }

  int _getCountForStatus(String status) {
    return _requestCounts[status] ?? 0;
  }

  int _getCountForTaxiType(String taxiType) {
    return _taxiTypeCounts[taxiType] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = 2; // Mantener siempre 2 columnas

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: 6, // Número total de cajas
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildRequestBox(
                context,
                title: 'Solicitudes',
                subtitle: 'Total',
                icon: Icons.assignment,
                color: Colors.blue.shade600,
                count: _getTotalRequests(),
                onTap: () {
                  AppRoutes.router.go(AppRoutes.all_requests);
                },
              );
            case 1:
              return _buildRequestBox(
                context,
                title: 'Aceptadas',
                subtitle: 'Confirmadas',
                icon: Icons.check_circle,
                color: Colors.green.shade600,
                count: _getCountForStatus('accepted'),
                onTap:(){
                  AppRoutes.router.go(AppRoutes.accepted_requests);
                },
              );
            case 2:
              return _buildRequestBox(
                context,
                title: 'Pendientes',
                subtitle: 'Esperando',
                icon: Icons.pending_actions,
                color: Colors.orange.shade600,
                count: _getCountForStatus('pending'),
                onTap: () {
                  AppRoutes.router.go(AppRoutes.pending_requests);
                },
              );
            case 3:
              return _buildRequestBox(
                context,
                title: 'En Curso',
                subtitle: 'Activas',
                icon: Icons.directions_car,
                color: Colors.purple.shade600,
                count: _getCountForStatus('in_progress'),
                onTap: () {
                  AppRoutes.router.go(AppRoutes.in_progress_requests);
                },
              );
            case 4:
              return _buildRequestBox(
                context,
                title: 'Colectivo',
                subtitle: 'Compartido',
                icon: Icons.groups,
                color: Colors.deepPurple.shade600,
                count: _getCountForTaxiType('colectivo'),
                onTap: () => _showComingSoon(context, 'Solicitudes Colectivo'),
              );
            case 5:
              return _buildRequestBox(
                context,
                title: 'Privado',
                subtitle: 'Individual',
                icon: Icons.person,
                color: Colors.indigo.shade600,
                count: _getCountForTaxiType('privado'),
                onTap: () => _showComingSoon(context, 'Solicitudes Privadas'),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildRequestBox(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Ajustar al contenido mínimo
              children: [
                Flexible(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(22.5),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Esta funcionalidad se implementará próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}