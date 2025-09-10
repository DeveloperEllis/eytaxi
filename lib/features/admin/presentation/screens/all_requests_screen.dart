import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_trip_request_service.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/features/admin/presentation/screens/attend_request_screen.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_detail_dialog.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_card_widget.dart';
import 'dart:developer' as developer;

class AllRequestsScreen extends StatefulWidget {
  const AllRequestsScreen({super.key});

  @override
  State<AllRequestsScreen> createState() => _AllRequestsScreenState();
}

class _AllRequestsScreenState extends State<AllRequestsScreen> {
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
        '🚀 AllRequestsScreen: Iniciando carga de solicitudes',
        name: 'AllRequestsScreen',
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final requests = await _service.getAllTripRequests();

      if (mounted) {
        setState(() {
          _requests = requests;
          _filteredRequests = requests;
          _isLoading = false;
        });

        developer.log(
          '✅ AllRequestsScreen: ${requests.length} solicitudes cargadas',
          name: 'AllRequestsScreen',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ AllRequestsScreen: Error al cargar solicitudes: $e',
        name: 'AllRequestsScreen',
      );
      developer.log(
        '📚 AllRequestsScreen: StackTrace: $stackTrace',
        name: 'AllRequestsScreen',
      );

      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar las solicitudes: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _filterRequests() {
    setState(() {
      _filteredRequests =
          _requests.where((request) {
            // Filtro por búsqueda (usando 'nombre' en lugar de 'name')
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
        title: const Text(
          'Todas las Solicitudes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
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
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Buscador
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar solicitudes...',
              hintText: 'ID, origen, destino, contacto',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterRequests();
            },
          ),

          const SizedBox(height: 12),

          // Filtro por estado
          Row(
            children: [
              const Text(
                'Estado: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _statusFilter,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pendientes'),
                    ),
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('Aceptados'),
                    ),
                    DropdownMenuItem(
                      value: 'started',
                      child: Text('Iniciados'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completados'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelados'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Rechazados'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value!;
                    });
                    _filterRequests();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filtro por tipo de taxi
          Row(
            children: [
              const Text(
                'Tipo: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _taxiTypeFilter,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'colectivo',
                      child: Text('Colectivo'),
                    ),
                    DropdownMenuItem(value: 'privado', child: Text('Privado')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _taxiTypeFilter = value!;
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
                  ? 'No hay solicitudes registradas'
                  : 'No se encontraron solicitudes con los filtros aplicados',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (_requests.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _statusFilter = 'todos';
                    _taxiTypeFilter = 'todos';
                    _filteredRequests = _requests;
                  });
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
        padding: const EdgeInsets.all(8),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(_filteredRequests[index]);
        },
      ),
    );
  }

  Widget _buildRequestCard(TripRequest request) {
    return TripRequestCardWidget(
      request: request,
      onTap: () => _showRequestDetails(request),
    );
  }

  void _showRequestDetails(TripRequest request) {
    showDialog(
      context: context,
      builder:
          (context) => TripRequestDetailDialog(
            request: request,
            onAttendRequest: (request) => _attendRequest(request),

            onDelete: (request) => _deleteTripRequest(request),
          ),
    );
  }

  void _attendRequest(TripRequest request) {
    Navigator.pop(context); // Cerrar el diálogo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendRequestScreen(request: request),
      ),
    ).then((result) {
      // Recargar solicitudes si hubo cambios
      if (result == true) {
        _loadRequests();
      }
    });
  }

  Future<void> _deleteTripRequest(TripRequest request) async {
    try {
      await _service.deleteTripRequest(request.id!);

      if (mounted) {
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
}
