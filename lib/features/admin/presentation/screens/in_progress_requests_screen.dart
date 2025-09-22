import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_trip_request_service.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_detail_dialog.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_card_widget.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

class InProgressRequestsScreen extends StatefulWidget {
  const InProgressRequestsScreen({super.key});

  @override
  State<InProgressRequestsScreen> createState() =>
      _InProgressRequestsScreenState();
}

class _InProgressRequestsScreenState extends State<InProgressRequestsScreen> {
  final AdminTripRequestService _service = AdminTripRequestService();
  List<TripRequest> _requests = [];
  List<TripRequest> _filteredRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'todos';
  String _taxiTypeFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      developer.log(
        '🚀 InProgressRequestsScreen: Iniciando carga de solicitudes en curso',
        name: 'InProgressRequestsScreen',
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Obtener todas las solicitudes y filtrar las que tienen chofer asignado
      final allRequests = await _service.getAllTripRequests();

      final inProgressRequests =
          allRequests.where((request) {
            // Tiene chofer asignado (driver_id O external_driver_id)
            final hasDriver =
                request.driverId != null || request.externalDriverId != null;

            return hasDriver;
          }).toList();

      if (mounted) {
        setState(() {
          _requests = inProgressRequests;
          _filteredRequests = inProgressRequests;
          _isLoading = false;
        });

        developer.log(
          '✅ InProgressRequestsScreen: ${inProgressRequests.length} solicitudes en curso cargadas',
          name: 'InProgressRequestsScreen',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ InProgressRequestsScreen: Error al cargar solicitudes: $e',
        name: 'InProgressRequestsScreen',
      );
      developer.log(
        '📚 InProgressRequestsScreen: StackTrace: $stackTrace',
        name: 'InProgressRequestsScreen',
      );

      if (mounted) {
        setState(() {
          _errorMessage =
              'Error al cargar las solicitudes en curso: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _filterRequests() {
    setState(() {
      _filteredRequests =
          _requests.where((request) {
            // Filtro por búsqueda
            final matchesSearch =
                _searchQuery.isEmpty ||
                request.origen?.nombre.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ==
                    true ||
                request.destino?.nombre.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ==
                    true ||
                request.contact?.name?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ==
                    true ||
                request.id?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ==
                    true;

            // Filtro por estado
            final matchesStatus =
                _statusFilter == 'todos' ||
                request.status.name.toLowerCase() ==
                    _statusFilter.toLowerCase();

            // Filtro por tipo de taxi
            final matchesTaxiType =
                _taxiTypeFilter == 'todos' ||
                request.taxiType.toLowerCase() == _taxiTypeFilter.toLowerCase();

            return matchesSearch && matchesStatus && matchesTaxiType;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.router.go(AppRoutes.admin),
          tooltip: 'Volver',
        ),
        title: const Text(
          'Solicitudes En Curso',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 136, 73, 165),
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
          Expanded(child: _buildRequestsList()),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filtros en fila
          Row(
            children: [
              // Filtro por estado
              const Text(
                'Tipo: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // Filtro por tipo de taxi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _taxiTypeFilter,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'colectivo',
                          child: Text('Colectivo'),
                        ),
                        DropdownMenuItem(
                          value: 'privado',
                          child: Text('Privado'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _taxiTypeFilter = value ?? 'todos';
                        });
                        _filterRequests();
                      },
                    ),
                  ],
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
            Text('Cargando solicitudes en curso...'),
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
                  ? 'No hay solicitudes en curso'
                  : 'No se encontraron solicitudes con los filtros aplicados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            if (_requests.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _statusFilter = 'todos';
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
      builder:
          (context) => TripRequestDetailDialog(
            request: request,
            onAttendRequest: (request) => _navigateToEditRequest(request),
            onDelete: (request) => _deleteTripRequest(request),
          ),
    );
  }

  Future<void> _deleteTripRequest(TripRequest request) async {
    try {
      await _service.deleteTripRequest(request.id!);

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
    context
        .push(AppRoutes.attend_request, extra: request)
        .then((_) => _loadRequests());
  }
}
