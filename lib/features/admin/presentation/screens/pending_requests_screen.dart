import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_trip_request_service.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_detail_dialog.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_card_widget.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final AdminTripRequestService _service = AdminTripRequestService();
  List<TripRequest> _requests = [];
  List<TripRequest> _filteredRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _taxiTypeFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      developer.log('🚀 PendingRequestsScreen: Iniciando carga de solicitudes pendientes', name: 'PendingRequestsScreen');
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Obtener todas las solicitudes y filtrar las pendientes
      final allRequests = await _service.getAllTripRequests();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day); // Inicio del día de hoy
      
      final pendingRequests = allRequests.where((request) {
        // Solo solicitudes pendientes
        final isPending = request.status.name.toLowerCase() == 'pending';
        
        // Fecha de hoy en adelante (incluyendo hoy)
        final requestDate = DateTime(request.tripDate.year, request.tripDate.month, request.tripDate.day);
        final isFromToday = requestDate.isAtSameMomentAs(today) || requestDate.isAfter(today);
        
        return isPending && isFromToday;
      }).toList();
      
      if (mounted) {
        setState(() {
          _requests = pendingRequests;
          _filteredRequests = pendingRequests;
          _isLoading = false;
        });
        
        developer.log('✅ PendingRequestsScreen: ${pendingRequests.length} solicitudes pendientes cargadas', name: 'PendingRequestsScreen');
      }
    } catch (e, stackTrace) {
      developer.log('❌ PendingRequestsScreen: Error al cargar solicitudes: $e', name: 'PendingRequestsScreen');
      developer.log('📚 PendingRequestsScreen: StackTrace: $stackTrace', name: 'PendingRequestsScreen');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar las solicitudes pendientes: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _filterRequests() {
    setState(() {
      _filteredRequests = _requests.where((request) {
        // Filtro por búsqueda
        final matchesSearch = _searchQuery.isEmpty ||
            request.origen?.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
            request.destino?.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
            request.contact?.name?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
            request.id?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;

        // Filtro por tipo de taxi
        final matchesTaxiType = _taxiTypeFilter == 'todos' ||
            request.taxiType.toLowerCase() == _taxiTypeFilter.toLowerCase();

        return matchesSearch && matchesTaxiType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitudes Pendientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sección de búsqueda y filtros
          _buildSearchSection(),
          
          // Lista de solicitudes
          Expanded(
            child: _buildRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterRequests();
            },
            decoration: InputDecoration(
              hintText: 'Buscar por origen, destino, pasajero o ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filtro por tipo de taxi
          Row(
            children: [
              const Text('Tipo de taxi: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _taxiTypeFilter,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'colectivo', child: Text('Colectivo')),
                    DropdownMenuItem(value: 'privado', child: Text('Privado')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _taxiTypeFilter = value ?? 'todos';
                    });
                    _filterRequests();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando solicitudes pendientes...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _requests.isEmpty
                  ? 'No hay solicitudes pendientes'
                  : 'No se encontraron solicitudes con los filtros aplicados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (_requests.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _taxiTypeFilter = 'todos';
                  });
                  _filterRequests();
                },
                child: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          final request = _filteredRequests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TripRequestCardWidget(
              request: request,
              showTimeElapsed: true,
              onTap: () => _showRequestDetails(request),
            ),
          );
        },
      ),
    );
  }

  void _showRequestDetails(TripRequest request) {
    showDialog(
      context: context,
      builder: (context) => TripRequestDetailDialog(
        request: request,
        onAttendRequest: (request) => _navigateToEditRequest(request),
        onDelete: (request) => _deleteTripRequest(request),
      ),
    );
  }

  Future<void> _deleteTripRequest(TripRequest request) async {
    try {
      await _service.deleteTripRequestCascade(request.id!);
      
      if (mounted) {
        Navigator.pop(context); // Cerrar el diálogo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEditRequest(TripRequest request) {
    Navigator.pop(context); // Cerrar el diálogo de detalles
    context.push(AppRoutes.attend_request, extra: request).then((_) => _loadRequests());
  }
}
