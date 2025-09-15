import 'package:flutter/material.dart';
import 'package:eytaxi/features/admin/presentation/widgets/trip_request_card_widget.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/features/admin/data/services/admin_driver_service.dart';
import 'package:eytaxi/features/admin/data/admin_trip_request_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AttendRequestScreen extends StatefulWidget {
  final TripRequest request;

  const AttendRequestScreen({super.key, required this.request});

  @override
  State<AttendRequestScreen> createState() => _AttendRequestScreenState();
}

class _AttendRequestScreenState extends State<AttendRequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdminDriverService _driverService = AdminDriverService(
    Supabase.instance.client,
  );

  List<Map<String, dynamic>> _acceptedDrivers = [];
  List<Driver> _availableDrivers = [];
  List<Driver> _filteredDrivers = [];
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterDrivers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      // Cargar conductores que han respondido a esta solicitud
      final responses = await _driverService.getDriverResponsesForRequest(
        widget.request.id!,
      );
      _acceptedDrivers =
          responses.where((r) => r['response'] == 'accepted').toList();

      // Cargar todos los conductores disponibles
      final available = await _driverService.getAvailableDrivers();
      _availableDrivers = available;
      _filteredDrivers = available;
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar datos: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        _filteredDrivers =
            _availableDrivers.where((driver) {
              final name = '${driver.nombre} ${driver.apellidos}'.toLowerCase();
              final license = driver.licenseNumber.toLowerCase();
              return name.contains(query) || license.contains(query);
            }).toList();
      });
    }
  }

  Future<void> _deleteRequestCascade() async {
    try {
      final service = AdminTripRequestService();
      await service.deleteTripRequestCascade(widget.request.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Solicitud'),
        content: const Text('¿Estás seguro de que quieres eliminar esta solicitud? Se eliminarán también todas las respuestas de conductores asociadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRequestCascade();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Atender Solicitud #${widget.request.id?.substring(0, 8) ?? 'N/A'}',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : () => _confirmDeleteRequest(),
            tooltip: 'Eliminar solicitud',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Información de la solicitud
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del viaje
                            TripRequestCardWidget(
                              request: widget.request,
                              showTimeElapsed: true,
                              onTap: () {}, // No action needed in this screen
                            ),
                            
                            const SizedBox(height: 16),
                            
                            if (widget.request.driver != null) ...[
                              // Información del conductor asignado
                              const SizedBox(height: 16),
                              _buildAssignedDriverSection(),
                            ] else ...[
                              // Sección para asignar conductor
                              _buildDriverAssignmentSection(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAssignedDriverSection() {
    final driver = widget.request.driver!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drive_eta, color: Colors.orange.shade600, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Conductor Asignado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Asignado',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nombre del conductor
            _buildClientDetailRow(
              'Nombre',
              '${driver.nombre} ${driver.apellidos}'.trim(),
              Icons.person,
              Colors.orange,
            ),

            const SizedBox(height: 12),

            // Teléfono del conductor con botón de acción
            Row(
              children: [
                Expanded(
                  child: _buildClientDetailRow(
                    'Teléfono',
                    driver.phoneNumber,
                    Icons.phone,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () => _launchPhone(driver.phoneNumber),
                    icon: Icon(Icons.phone, color: Colors.blue.shade700, size: 20),
                    tooltip: 'Llamar al conductor',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () => _launchWhatsApp(driver.phoneNumber),
                    icon: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    tooltip: 'WhatsApp al conductor',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Licencia
            if (driver.licenseNumber.isNotEmpty) ...[
              _buildClientDetailRow(
                'Licencia',
                driver.licenseNumber,
                Icons.badge,
                Colors.purple,
              ),
              const SizedBox(height: 12),
            ],

            // Capacidad del vehículo
            if (driver.vehicleCapacity > 0) ...[
              _buildClientDetailRow(
                'Capacidad del vehículo',
                '${driver.vehicleCapacity} pasajeros',
                Icons.directions_car,
                Colors.indigo,
              ),
              const SizedBox(height: 16),
            ],

            // Botón de desvincular conductor
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAssigning ? null : _unlinkDriver,
                icon: _isAssigning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.link_off, size: 20),
                label: Text(_isAssigning ? 'Desvinculando...' : 'Desvincular Conductor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverAssignmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Text(
          'Conductores Disponibles',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Barra de búsqueda
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar conductor por nombre o licencia...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de conductores
        if (_filteredDrivers.isEmpty)
          const Center(
            child: Text(
              'No hay conductores disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredDrivers.length,
            itemBuilder: (context, index) {
              final driver = _filteredDrivers[index];
              return _buildDriverCard(driver);
            },
          ),
      ],
    );
  }

  Widget _buildDriverCard(Driver driver) {
    final isAccepted = _acceptedDrivers.any((r) => r['driver_id'] == driver.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAccepted ? Colors.green : Colors.blue,
          child: Icon(
            isAccepted ? Icons.check : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text('${driver.nombre} ${driver.apellidos}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Licencia: ${driver.licenseNumber}'),
            Text('Teléfono: ${driver.phoneNumber}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAccepted) ...[
              ElevatedButton(
                onPressed: _isAssigning ? null : () => _assignDriver(driver.id!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Asignar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _isAssigning ? null : () => _assignDriver(driver.id!, isRejection: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Rechazar'),
              ),
            ] else
              ElevatedButton(
                onPressed: _isAssigning ? null : () => _assignDriver(driver.id!),
                child: const Text('Asignar'),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildClientDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _assignDriver(String driverId, {bool isRejection = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRejection ? 'Confirmar Rechazo' : 'Confirmar Asignación'),
        content: Text(
          isRejection
              ? '¿Estás seguro de que deseas rechazar este conductor para la solicitud?'
              : '¿Estás seguro de que deseas asignar este conductor a la solicitud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (mounted) {
        setState(() {
          _isAssigning = true;
        });
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final success = isRejection
          ? await _driverService.RejectDriverToRequest(
              requestId: widget.request.id!,
              driverId: driverId,
              adminId: user.id,
            )
          : await _driverService.assignDriverToRequest(
              requestId: widget.request.id!,
              driverId: driverId,
              adminId: user.id,
            );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRejection
                  ? 'Conductor rechazado exitosamente'
                  : 'Conductor asignado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla anterior y notificar el cambio
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRejection
                  ? 'Error al rechazar conductor: $e'
                  : 'Error al asignar conductor: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  Future<void> _unlinkDriver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desvinculación'),
        content: const Text(
          '¿Estás seguro de que deseas desvincular este conductor de la solicitud? '
          'La solicitud volverá al estado pendiente si no hay otros conductores que la hayan aceptado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (mounted) {
        setState(() {
          _isAssigning = true;
        });
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Desvincular conductor actualizando driver_id a null
      await Supabase.instance.client
          .from('trip_requests')
          .update({
            'driver_id': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.request.id!);

      // Verificar si hay otros conductores que han aceptado esta solicitud
      final acceptedDriversResponse = await Supabase.instance.client
          .from('driver_responses')
          .select('driver_id')
          .eq('trip_request_id', widget.request.id!)
          .eq('response_type', 'accepted');

      // Si no hay otros conductores que hayan aceptado, cambiar status a pending
      if (acceptedDriversResponse.isEmpty) {
        await Supabase.instance.client
            .from('trip_requests')
            .update({
              'status': 'pending',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', widget.request.id!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conductor desvinculado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla anterior y notificar el cambio
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desvincular conductor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }
}