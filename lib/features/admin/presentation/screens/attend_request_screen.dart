import 'package:flutter/material.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/features/admin/data/services/admin_driver_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AttendRequestScreen extends StatefulWidget {
  final TripRequest request;

  const AttendRequestScreen({
    super.key,
    required this.request,
  });

  @override
  State<AttendRequestScreen> createState() => _AttendRequestScreenState();
}

class _AttendRequestScreenState extends State<AttendRequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdminDriverService _driverService = AdminDriverService(Supabase.instance.client);
  
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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Cargar conductores que han respondido a esta solicitud
      final responses = await _driverService.getDriverResponsesForRequest(widget.request.id!);
      _acceptedDrivers = responses.where((r) => r['response'] == 'accepted').toList();

      // Cargar todos los conductores disponibles
      final available = await _driverService.getAvailableDrivers();
      _availableDrivers = available;
      _filteredDrivers = available;

    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDrivers = _availableDrivers.where((driver) {
        final name = '${driver.nombre} ${driver.apellidos}'.toLowerCase();
        final license = driver.licenseNumber.toLowerCase();
        return name.contains(query) || license.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atender Solicitud #${widget.request.id?.substring(0, 8) ?? 'N/A'}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de la solicitud
                    _buildRequestSummary(),
                    
                    const SizedBox(height: 24),
                    
                    // Información del cliente/guest
                    if (widget.request.contact != null) ...[
                      _buildClientInfoSection(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Taxistas que han aceptado
                    _buildAcceptedDriversSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Buscador y lista de todos los taxistas
                    _buildAllDriversSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildRequestSummary() {
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
                Icon(Icons.receipt_long, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Resumen de la Solicitud',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildStatusChip(widget.request.status.name),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Origen',
                    widget.request.origen?.nombre ?? 'No especificado',
                    Icons.my_location,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Destino',
                    widget.request.destino?.nombre ?? 'No especificado',
                    Icons.location_on,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Fecha del viaje',
                    DateFormat('dd/MM/yyyy HH:mm').format(widget.request.tripDate),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Pasajeros',
                    '${widget.request.cantidadPersonas} personas',
                    Icons.group,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Aceptado';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Confirmado';
        break;
      case 'started':
        color = Colors.indigo;
        label = 'En curso';
        break;
      case 'completed':
        color = Colors.purple;
        label = 'Completado';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelado';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildClientInfoSection() {
    final contact = widget.request.contact!;
    
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
                Icon(Icons.person, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Información del Cliente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nombre del cliente
            _buildClientDetailRow(
              'Nombre',
              contact.name ?? 'No especificado',
              Icons.account_circle,
              Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            // Método y contacto con botón de acción
            Row(
              children: [
                Expanded(
                  child: _buildClientDetailRow(
                    'Contacto',
                    '${_getContactMethodLabel(contact.method ?? '')} - ${contact.contact ?? 'No especificado'}',
                    Icons.contact_phone,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                _buildContactActionButton(contact.method ?? '', contact.contact ?? ''),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Dirección
            if (contact.address != null && contact.address!.isNotEmpty) ...[
              _buildClientDetailRow(
                'Dirección',
                contact.address!,
                Icons.location_on,
                Colors.red,
              ),
              const SizedBox(height: 12),
            ],
            
            // Información extra
            if (contact.extraInfo != null && contact.extraInfo!.isNotEmpty) ...[
              _buildClientDetailRow(
                'Información adicional',
                contact.extraInfo!,
                Icons.info,
                Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientDetailRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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

  Widget _buildContactActionButton(String method, String contact) {
    final methodLower = method.toLowerCase();
    
    if (methodLower.contains('whatsapp')) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          onPressed: () => _launchWhatsApp(contact),
          icon: FaIcon(
            FontAwesomeIcons.whatsapp,
            color: Colors.green.shade700,
            size: 20,
          ),
          tooltip: 'Abrir WhatsApp',
        ),
      );
    } else if (methodLower.contains('phone') || methodLower.contains('tel')) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          onPressed: () => _launchPhone(contact),
          icon: Icon(
            Icons.phone,
            color: Colors.blue.shade700,
            size: 20,
          ),
          tooltip: 'Llamar',
        ),
      );
    } else {
      // Para otros métodos como email, etc.
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          onPressed: () => _launchGenericContact(method, contact),
          icon: Icon(
            Icons.contact_mail,
            color: Colors.grey.shade700,
            size: 20,
          ),
          tooltip: 'Contactar',
        ),
      );
    }
  }

  Future<void> _launchWhatsApp(String contact) async {
    try {
      final cleanContact = contact.replaceAll(RegExp(r'[^\d+]'), '');
      final url = 'https://wa.me/$cleanContact';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String contact) async {
    try {
      final cleanContact = contact.replaceAll(RegExp(r'[^\d+]'), '');
      final url = 'tel:$cleanContact';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo realizar la llamada'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar la llamada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchGenericContact(String method, String contact) async {
    try {
      String url;
      final methodLower = method.toLowerCase();
      
      if (methodLower.contains('email') || methodLower.contains('mail')) {
        url = 'mailto:$contact';
      } else if (methodLower.contains('sms')) {
        url = 'sms:$contact';
      } else if (methodLower.contains('telegram')) {
        url = 'https://t.me/$contact';
      } else {
        // Fallback para métodos no reconocidos
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Método de contacto: $method - $contact'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        return;
      }
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir $method'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al contactar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getContactMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'phone':
        return 'Teléfono';
      case 'whatsapp':
        return 'WhatsApp';
      case 'telegram':
        return 'Telegram';
      case 'email':
      case 'mail':
        return 'Correo electrónico';
      case 'sms':
        return 'SMS';
      default:
        return method;
    }
  }

  Widget _buildAcceptedDriversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Taxistas que han Aceptado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_acceptedDrivers.length}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (_acceptedDrivers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade400),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No hay taxistas que hayan aceptado esta solicitud aún.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._acceptedDrivers.map((driver) => _buildDriverCard(driver, isAccepted: true)),
      ],
    );
  }

  Widget _buildAllDriversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.search, color: Colors.blue.shade600, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Asignar Taxista',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Buscador
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o licencia...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: (_) => _filterDrivers(),
        ),
        
        const SizedBox(height: 16),
        
        if (_filteredDrivers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade400),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No se encontraron taxistas disponibles.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._filteredDrivers.map((driver) => _buildDriverCard(driver, isAccepted: false)),
      ],
    );
  }

  Widget _buildDriverCard(dynamic driver, {required bool isAccepted}) {
    final String driverName;
    final String driverPhone;
    final String driverLicense;
    final int driverCapacity;
    final List<String> driverRoutes;
    final String? driverId;
    
    if (isAccepted) {
      final driverData = driver['driver'];
      driverName = '${driverData['nombre']} ${driverData['apellidos']}';
      driverPhone = driverData['phoneNumber'] ?? 'No disponible';
      driverLicense = driverData['licenseNumber'] ?? 'No disponible';
      driverCapacity = driverData['vehicleCapacity'] ?? 0;
      driverRoutes = (driverData['routes'] as List?)?.cast<String>() ?? [];
      driverId = driverData['id'];
    } else {
      final Driver driverObj = driver as Driver;
      driverName = '${driverObj.nombre} ${driverObj.apellidos}';
      driverPhone = driverObj.phoneNumber;
      driverLicense = driverObj.licenseNumber;
      driverCapacity = driverObj.vehicleCapacity;
      driverRoutes = driverObj.routes;
      driverId = driverObj.id;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar del conductor
            CircleAvatar(
              radius: 24,
              backgroundColor: isAccepted ? Colors.green.shade100 : Colors.blue.shade100,
              child: Icon(
                Icons.person,
                color: isAccepted ? Colors.green.shade700 : Colors.blue.shade700,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información del conductor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isAccepted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Aceptado',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          driverPhone,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(Icons.credit_card, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          driverLicense,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Capacidad: $driverCapacity personas',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  if (driverRoutes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.route, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Rutas: ${driverRoutes.join(', ')}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Botón de acción
            if (!isAccepted && driverId != null) 
              ElevatedButton(
                onPressed: _isAssigning 
                    ? null 
                    : () => _assignDriver(driverId!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAssigning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Asignar'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignDriver(String driverId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Asignación'),
        content: const Text(
          '¿Estás seguro de que deseas asignar este conductor a la solicitud?',
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
      setState(() {
        _isAssigning = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final success = await _driverService.assignDriverToRequest(
        requestId: widget.request.id!,
        driverId: driverId,
        adminId: user.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conductor asignado exitosamente'),
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
            content: Text('Error al asignar conductor: $e'),
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
