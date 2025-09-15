import 'package:eytaxi/features/admin/presentation/widgets/trip_request_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/features/admin/data/services/admin_driver_service.dart';
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body:
          _isLoading
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TripRequestCardWidget(
                      request: widget.request,
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),

                    // Información del cliente/guest
                    if (widget.request.contact != null) ...[
                      _buildClientInfoSection(),
                      const SizedBox(height: 24),
                    ],

                    // Información del conductor asignado
                    if (widget.request.driver != null) ...[
                      _buildAssignedDriverSection(),
                      const SizedBox(height: 24),
                    ],

                    // Taxistas que han aceptado
                    if (_acceptedDrivers.isNotEmpty) ...[
                      _buildAcceptedDriversSection(),
                      const SizedBox(height: 24),
                    ],

                    // Buscador y lista de todos los taxistas
                    _buildAllDriversSection(),
                  ],
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
                _buildContactActionButton(
                  contact.method ?? '',
                  contact.contact ?? '',
                ),
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

  Widget _buildClientDetailRow(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
            ],
          ],
        ),
      ),
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
        ));
    } else if (methodLower.contains('phone') || methodLower.contains('tel')) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          onPressed: () => _launchPhone(contact),
          icon: Icon(Icons.phone, color: Colors.blue.shade700, size: 20),
          tooltip: 'Llamar',
      ));
    } else {
      // Para otros métodos como email, etc.
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          onPressed: () => _launchGenericContact(method, contact),
          icon: Icon(Icons.contact_mail, color: Colors.grey.shade700, size: 20),
          tooltip: 'Contactar',
        ));
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
          ..._acceptedDrivers.map(
            (driver) => _buildDriverCard(driver, isAccepted: true),
          ),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          ..._filteredDrivers.map(
            (driver) => _buildDriverCard(driver, isAccepted: false),
          ),
      ],
    );
  }

  Widget _buildDriverCard(dynamic driver, {required bool isAccepted}) {
    // Normalize data from either a Driver model or an accepted-driver map
    Map<String, dynamic> data;
    if (isAccepted) {
      final raw = driver['driver'] as Map<String, dynamic>;
      data = {
        'id': raw['id'] ?? raw['driver_id'] ?? '',
        'nombre': raw['nombre'] ?? raw['first_name'] ?? '',
        'apellidos': raw['apellidos'] ?? raw['last_name'] ?? '',
        'phoneNumber': raw['phone_number'] ?? raw['phoneNumber'] ?? raw['phone'] ?? '',
        'licenseNumber': raw['license_number'] ?? raw['licenseNumber'] ?? '',
        'vehicleCapacity': raw['vehicle_capacity'] ?? raw['vehicleCapacity'] ?? 0,
        'routes': raw['routes'] ?? <String>[],
        'profilePhoto': raw['photo_url'] ?? raw['photoUrl'] ?? raw['photo'] ?? '',
        'vehiclePhotos': raw['vehicle_photo_url'] != null ? [raw['vehicle_photo_url'].toString()] : (raw['vehiclePhotos'] ?? <String>[]),
      };
    } else {
      final Driver d = driver as Driver;
      data = {
        'id': d.id,
        'nombre': d.nombre,
        'apellidos': d.apellidos,
        'phoneNumber': d.phoneNumber,
        'licenseNumber': d.licenseNumber,
        'vehicleCapacity': d.vehicleCapacity,
        'routes': d.routes,
        'profilePhoto': d.photoUrl,
        'vehiclePhotos': d.vehiclePhotoUrl.isNotEmpty ? [d.vehiclePhotoUrl] : <String>[],
      };
    }

    final String name = '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
    final String phone = (data['phoneNumber'] ?? 'No disponible').toString();
    final String? profile = (data['profilePhoto'] as String?)?.isEmpty == true ? null : data['profilePhoto'] as String?;

    return InkWell(
      onTap: () => _showDriverDetails(data),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Profile image with better error handling
              SizedBox(
                width: 44,
                height: 44,
                child: ClipOval(
                  child: profile != null && profile.startsWith('http')
                      ? Image.network(
                          profile,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isAccepted ? Colors.green.shade50 : Colors.blue.shade50,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isAccepted ? Colors.green.shade700 : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading profile image: $error');
                            return Container(
                              color: isAccepted ? Colors.green.shade50 : Colors.blue.shade50,
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  color: isAccepted ? Colors.green.shade700 : Colors.blue.shade700,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: isAccepted ? Colors.green.shade50 : Colors.blue.shade50,
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: isAccepted ? Colors.green.shade700 : Colors.blue.shade700,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Conductor' : name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              if (isAccepted)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDriverDetails(Map<String, dynamic> data) async {
  final supabase = Supabase.instance.client;

  // 🔹 Resolver foto de perfil
  String? profileUrl;
  if (data['profilePhoto'] != null && data['profilePhoto'].toString().isNotEmpty) {
    final profile = data['profilePhoto'].toString();
    if (profile.startsWith('http')) {
      profileUrl = profile; // URL pública
    } else {
      // Generar URL firmada desde Supabase Storage (válida por 1 hora)
      profileUrl = await supabase.storage.from('drivers').createSignedUrl(profile, 3600);
    }
    debugPrint("Profile photo URL: $profileUrl");
  }

  // 🔹 Resolver fotos del vehículo
  final List<String> vehiclePhotos = (data['vehiclePhotos'] as List? ?? [])
      .where((url) => url != null && url.toString().isNotEmpty)
      .map((url) => url.toString())
      .toList();

  final List<String> resolvedVehicleUrls = [];
  for (final v in vehiclePhotos) {
    if (v.startsWith('http')) {
      resolvedVehicleUrls.add(v);
    } else {
      final signed = await supabase.storage.from('drivers').createSignedUrl(v, 3600);
      resolvedVehicleUrls.add(signed);
    }
  }

  // Mostrar el diálogo
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                // ------------------- BODY -------------------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información básica
                        _buildDriverInfoCard(data),
                        
                        const SizedBox(height: 16),
                        
                        // Fotos del vehículo
                        if (resolvedVehicleUrls.isNotEmpty) ...[
                          _buildVehiclePhotosCard(resolvedVehicleUrls),
                          const SizedBox(height: 16),
                        ],
                        
                        // Botones de acción
                        _buildActionButtons(data),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // ------------------- BOTÓN CERRAR -------------------
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildDriverInfoCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Teléfono
            _buildInfoRow(
              Icons.phone,
              'Teléfono',
              data['phoneNumber']?.toString() ?? 'No disponible',
              Colors.green,
              actions: [
                IconButton(
                  onPressed: () {
                    final phone = data['phoneNumber'];
                    if (phone != null && phone.toString().isNotEmpty) {
                      launchUrl(Uri.parse('tel:$phone'));
                    }
                  },
                  icon: Icon(Icons.phone, color: Colors.blue.shade700),
                  tooltip: 'Llamar',
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    final phone = data['phoneNumber'];
                    if (phone != null && phone.toString().isNotEmpty) {
                      final cleanPhone = phone.toString().replaceAll(RegExp(r'[^\d+]'), '');
                      launchUrl(Uri.parse('https://wa.me/$cleanPhone'), mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green.shade700),
                  tooltip: 'WhatsApp',
                  iconSize: 18,
                ),
              ],
            ),

            const Divider(height: 24),

            // Licencia
            _buildInfoRow(
              Icons.badge,
              'Licencia',
              data['licenseNumber']?.toString() ?? 'No disponible',
              Colors.orange,
            ),

            const Divider(height: 24),

            // Capacidad
            _buildInfoRow(
              Icons.group,
              'Capacidad del vehículo',
              '${data['vehicleCapacity'] ?? 'N/A'} pasajeros',
              Colors.purple,
            ),

            // Rutas
            if ((data['routes'] as List?)?.isNotEmpty ?? false) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.route,
                'Rutas disponibles',
                (data['routes'] as List).join(', '),
                Colors.teal,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color, {List<Widget>? actions}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
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
              const SizedBox(height: 2),
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
        if (actions != null) ...actions,
      ],
    );
  }

  Widget _buildVehiclePhotosCard(List<String> vehicleUrls) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.indigo.shade600),
                const SizedBox(width: 8),
                Text(
                  'Fotos del Vehículo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vehicleUrls.length,
                itemBuilder: (context, index) {
                  final url = vehicleUrls[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _showImagePreview(context, url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _assignDriver(data['id']?.toString() ?? '', isRejection: true);
            },
            icon: const Icon(Icons.close),
            label: const Text('Rechazar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              final driverId = data['id']?.toString();
              if (driverId != null && driverId.isNotEmpty) {
                _assignDriver(driverId);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Asignar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 50),
                        SizedBox(height: 8),
                        Text(
                          'Error al cargar imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _assignDriver(String driverId, {bool isRejection = false}) async {
    final bool? confirmed = await showDialog<bool>(
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
}
 
