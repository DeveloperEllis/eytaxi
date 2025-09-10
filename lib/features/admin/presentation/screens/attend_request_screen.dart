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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

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
      _filteredDrivers =
          _availableDrivers.where((driver) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Aceptado', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverDetails(Map<String, dynamic> data) {
    final List<String> vehiclePhotos = (data['vehiclePhotos'] as List?)
        ?.where((url) => url != null && url.toString().isNotEmpty)
        .map((url) => url.toString())
        .toList() ?? <String>[];
    
    String? profile = data['profilePhoto'] as String?;
    // Clean and validate profile photo URL
    if (profile != null && profile.isNotEmpty && !profile.startsWith('http')) {
      profile = null; // Invalid URL format
    }
    
    final String name = '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with profile photo and name
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: profile != null
                            ? Image.network(
                                profile,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(child: Icon(Icons.person, size: 50)),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.person, size: 50)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isEmpty ? 'Conductor' : name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Single card with all driver information
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phone with contact buttons
                          Row(
                            children: [
                              Icon(Icons.phone, size: 20, color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['phoneNumber']?.toString() ?? 'No disponible',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              // Phone call button
                              IconButton(
                                onPressed: () {
                                  final phone = data['phoneNumber'];
                                  if (phone != null && phone.toString().isNotEmpty) {
                                    launchUrl(Uri.parse('tel:$phone'));
                                  }
                                },
                                icon: Icon(Icons.phone, color: Colors.blue.shade700),
                                tooltip: 'Llamar',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // WhatsApp button
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
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green.shade50,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // License
                          Row(
                            children: [
                              Icon(Icons.credit_card, size: 20, color: Colors.orange.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['licenseNumber']?.toString() ?? 'No disponible',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Capacity
                          Row(
                            children: [
                              Icon(Icons.group, size: 20, color: Colors.purple.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${data['vehicleCapacity'] ?? 'N/A'} pasajeros',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Routes
                          if ((data['routes'] as List?) != null && (data['routes'] as List).isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.route, size: 20, color: Colors.teal.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var route in (data['routes'] as List))
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            route.toString(),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Vehicle photos
                          if (vehiclePhotos.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.photo_camera, size: 20, color: Colors.indigo.shade600),
                                const SizedBox(width: 8),
                                const Text(
                                  'Fotos del vehículo',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: vehiclePhotos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final url = vehiclePhotos[i];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: GestureDetector(
                                      onTap: () => _showImagePreview(context, url),
                                      child: Image.network(
                                        url,
                                        width: 160,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 160,
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade200,
                                          width: 160,
                                          height: 120,
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.directions_car, size: 30),
                                                SizedBox(height: 4),
                                                Text('Error al cargar', style: TextStyle(fontSize: 10)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Action buttons below the card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Implement reject functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conductor rechazado'),
                              backgroundColor: Colors.orange,
                            ),
                          );
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, Color color, List<Widget> children) {
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
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          if (label.isNotEmpty) ...[
            Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
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

  Future<void> _assignDriver(String driverId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
