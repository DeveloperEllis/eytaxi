import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/data/admin_trip_request_service.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_detail_dialog.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_card_widget.dart';
import 'package:eytaxi/features/admin/presentation/screens/attend_request_screen.dart';
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

      final requests = await _service.getPendingRequests();
      
      if (mounted) {
        setState(() {
          _requests = requests;
          _filteredRequests = requests;
          _isLoading = false;
        });
        
        developer.log('✅ PendingRequestsScreen: ${requests.length} solicitudes pendientes cargadas', name: 'PendingRequestsScreen');
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
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'Información',
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
              labelText: 'Buscar solicitudes pendientes...',
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
                    DropdownMenuItem(value: 'colectivo', child: Text('Colectivo')),
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
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _requests.isEmpty
                  ? '¡Excelente! No hay solicitudes pendientes'
                  : 'No se encontraron solicitudes con los filtros aplicados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_requests.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
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
      showTimeElapsed: true, // Siempre mostrar tiempo transcurrido en pending requests
    );
  }

  void _showRequestDetails(TripRequest request) {
    showDialog(
      context: context,
      builder: (context) => TripRequestDetailDialog(
        request: request,
        customTitle: 'Solicitud Pendiente #${request.id?.substring(0, 8) ?? 'N/A'}',
        onAttendRequest: (request) => _attendRequest(request),
        onUpdateStatus: (request) => _showUpdateStatusDialog(request),
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

  void _showUpdateStatusDialog(TripRequest request) {
    final currentStatus = request.status.name;
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Actualizar Estado'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Nuevo Estado',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
              DropdownMenuItem(value: 'accepted', child: Text('Aceptado')),
              DropdownMenuItem(value: 'started', child: Text('Iniciado')),
              DropdownMenuItem(value: 'completed', child: Text('Completado')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
              DropdownMenuItem(value: 'rejected', child: Text('Rechazado')),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedStatus != currentStatus
                  ? () => _updateStatus(request.id!, selectedStatus)
                  : null,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String requestId, String newStatus) async {
    try {
      await _service.updateTripRequestStatus(requestId, newStatus);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Solicitudes Pendientes'),
          ],
        ),
        content: const Text(
          'Esta pantalla muestra solicitudes que:\n\n'
          '• No han recibido respuesta de ningún taxista\n'
          '• Solo han sido rechazadas por todos los taxistas que respondieron\n\n'
          'Estas solicitudes necesitan atención para encontrar un conductor disponible.',
        ),
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
