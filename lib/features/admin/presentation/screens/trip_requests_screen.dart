import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/presentation/screens/all_requests_screen.dart';
import 'package:eytaxi/features/admin/presentation/screens/pending_requests_screen.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequestCounts();
  }

  Future<void> _loadRequestCounts() async {
    try {
      developer.log('🔄 TripRequestsScreen: Cargando contadores de solicitudes', name: 'TripRequestsScreen');
      
      setState(() {
        _isLoading = true;
      });

      final counts = await _service.getRequestCountsByStatus();
      final taxiTypeCounts = await _service.getRequestCountsByTaxiType();
      
      if (mounted) {
        setState(() {
          _requestCounts = counts;
          _taxiTypeCounts = taxiTypeCounts;
          _isLoading = false;
        });
        
        developer.log('✅ TripRequestsScreen: Contadores cargados: $counts', name: 'TripRequestsScreen');
        developer.log('✅ TripRequestsScreen: Contadores taxi: $taxiTypeCounts', name: 'TripRequestsScreen');
      }
    } catch (e) {
      developer.log('❌ TripRequestsScreen: Error al cargar contadores: $e', name: 'TripRequestsScreen');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _getTotalRequests() {
    return _requestCounts.values.fold(0, (sum, count) => sum + count);
  }

  int _getCountForStatus(String status) {
    return _requestCounts[status] ?? 0;
  }

  int _getCountForTaxiType(String taxiType) {
    return _taxiTypeCounts[taxiType] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Solicitudes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadRequestCounts,
            tooltip: 'Actualizar contadores',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildRequestBox(
              context,
              title: 'Solicitudes',
              subtitle: 'Ver todas',
              icon: Icons.list_alt,
              color: Colors.blue,
              count: _getTotalRequests(),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllRequestsScreen(),
                  ),
                );
                // Recargar contadores cuando se regrese de la pantalla
                if (result != null || mounted) {
                  _loadRequestCounts();
                }
              },
            ),
            _buildRequestBox(
              context,
              title: 'Pendientes',
              subtitle: 'Sin respuesta',
              icon: Icons.pending,
              color: Colors.orange,
              count: _getCountForStatus('pending'),
              onTap: () {
                // Navegar a solicitudes pendientes
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PendingRequestsScreen(),
                  ),
                );
              },
            ),
            _buildRequestBox(
              context,
              title: 'Aceptadas',
              subtitle: 'Confirmados',
              icon: Icons.check_circle,
              color: Colors.green,
              count: _getCountForStatus('accepted'),
              onTap: () {
                // TODO: Navegar a solicitudes aceptadas
                _showComingSoon(context, 'Solicitudes Aceptadas');
              },
            ),
            _buildRequestBox(
              context,
              title: 'En Curso',
              subtitle: 'En progreso',
              icon: Icons.directions_car,
              color: Colors.purple,
              count: _getCountForStatus('started'),
              onTap: () {
                // TODO: Navegar a solicitudes en curso
                _showComingSoon(context, 'Solicitudes En Curso');
              },
            ),
            _buildRequestBox(
              context,
              title: 'Colectivo',
              subtitle: 'Taxis compartidos',
              icon: Icons.group,
              color: Colors.deepPurple,
              count: _getCountForTaxiType('colectivo'),
              onTap: () {
                // TODO: Navegar a solicitudes colectivas
                _showComingSoon(context, 'Solicitudes Colectivas');
              },
            ),
            _buildRequestBox(
              context,
              title: 'Privado',
              subtitle: 'Taxis privados',
              icon: Icons.person,
              color: Colors.indigo,
              count: _getCountForTaxiType('privado'),
              onTap: () {
                // TODO: Navegar a solicitudes privadas
                _showComingSoon(context, 'Solicitudes Privadas');
              },
            ),
          ],
        ),
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
              children: [
                // Icono principal
                Container(
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
                
                const SizedBox(height: 8),
                
                // Título
                Text(
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
                
                const SizedBox(height: 2),
                
                // Subtítulo
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Contador
                Container(
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
