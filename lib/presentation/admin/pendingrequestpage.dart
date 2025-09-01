import 'package:eytaxi/data/repositories/taxista_repository.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  Future<void> _assignDriverToTrip(TripRequest request, Driver driver) async {
    final client = Supabase.instance.client;
    try {
      final response = await client
          .from('trip_requests')
          .update({
            'driver_id': driver.id,
            'status': 'accepted',
          })
          .eq('id', request.id!)
          .select();
      if (response is List && response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Driver ${driver.nombre} asignado a la solicitud ${request.id}')),
        );
        await fetchPendingRequests();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar la solicitud. Verifica RLS o permisos.')),
        );
      }
    } catch (e) {
      print('Error al actualizar trip_requests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asignar chofer: $e')),
      );
    }
  }

  Future<void> _showAssignDriverDialog(TripRequest request) async {
    final repo = TaxistaRepository();
    List<Driver> drivers = [];
    try {
      drivers = await repo.fetchAllDrivers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener conductores: $e')),
      );
      print(e);
      return;
    }
    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay conductores disponibles.')),
      );
      return;
    }
    Driver? selectedDriver;
    String search = '';
    List<Driver> filteredDrivers = drivers;
    final Map<String, bool> expandedStates = {};
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            filteredDrivers =
                drivers.where((d) {
                  final query = search.toLowerCase();
                  return d.nombre.toLowerCase().contains(query) ||
                      d.apellidos.toLowerCase().contains(query) ||
                      d.email.toLowerCase().contains(query) ||
                      d.phoneNumber.toLowerCase().contains(query);
                }).toList();
            return AlertDialog(
              title: const Text('Asignar driver'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre, email o teléfono',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          filteredDrivers.isEmpty
                              ? const Center(
                                child: Text('No se encontraron conductores.'),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredDrivers.length,
                                itemBuilder: (context, index) {
                                  final driver = filteredDrivers[index];
                                  final photoUrl = driver.photoUrl ?? '';
                                  final isExpanded =
                                      expandedStates[driver.id] ?? false;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: isExpanded ? 4 : 1,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            child: (photoUrl.isNotEmpty)
                                                ? ClipOval(
                                                    child: Image.network(
                                                      photoUrl,
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.person, size: 28, color: Colors.grey);
                                                      },
                                                    ),
                                                  )
                                                : const Icon(Icons.person),
                                          ),
                                          title: Text(
                                            '${driver.nombre} ${driver.apellidos}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(driver.email),
                                          trailing: IconButton(
                                            icon: Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.blue,
                                            ),
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      expandedStates[driver.id ?? ''] =
                                                          !isExpanded,
                                                ),
                                          ),
                                          onTap: () {
                                            selectedDriver = driver;
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        AnimatedSize(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child:
                                              isExpanded
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 8,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              const Icon(
                                                                Icons.phone,
                                                                size: 18,
                                                                color: Colors.green,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(
                                                                'Tel: ',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  driver.phoneNumber,
                                                                  style: const TextStyle(fontSize: 15),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.blue.shade50,
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                    child: IconButton(
                                                                      icon: const Icon(Icons.call, color: Colors.blue, size: 26),
                                                                      tooltip: 'Llamar',
                                                                      onPressed: () async {
                                                                        final tel = driver.phoneNumber.replaceAll(' ', '');
                                                                        final url = 'tel:$tel';
                                                                        if (await canLaunchUrl(Uri.parse(url))) {
                                                                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.green.shade50,
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                    child: IconButton(
                                                                      icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 26),
                                                                      tooltip: 'WhatsApp',
                                                                      onPressed: () async {
                                                                        final tel = driver.phoneNumber.replaceAll(' ', '');
                                                                        final url = 'https://wa.me/$tel';
                                                                        if (await canLaunchUrl(Uri.parse(url))) {
                                                                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.people,
                                                                size: 18,
                                                                color:
                                                                    Colors.teal,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Capacidad: ',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                driver
                                                                    .vehicleCapacity
                                                                    .toString(),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .check_circle,
                                                                size: 18,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Disponible: ',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                driver.isAvailable
                                                                    ? 'Sí'
                                                                    : 'No',
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Icon(
                                                                Icons.map,
                                                                size: 18,
                                                                color:
                                                                    Colors.purple,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Rutas: ',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  driver
                                                                          .routes
                                                                          .isNotEmpty
                                                                      ? driver
                                                                          .routes
                                                                          .join(
                                                                            ', ',
                                                                          )
                                                                      : 'N/A',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 12),
                                                          Align(
                                                            alignment: Alignment.centerRight,
                                                            child: ElevatedButton.icon(
                                                              icon: const Icon(Icons.person_add_alt_1),
                                                              label: const Text('Asignar chofer'),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.blue.shade700,
                                                                foregroundColor: Colors.white,
                                                              ),
                                                              onPressed: () async {
                                                                final confirm = await showDialog<bool>(
                                                                  context: context,
                                                                  builder: (context) => AlertDialog(
                                                                    title: const Text('Confirmar asignación'),
                                                                    content: const Text('¿Seguro que deseas asignar este chofer a este viaje?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.of(context).pop(false),
                                                                        child: const Text('Cancelar'),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed: () => Navigator.of(context).pop(true),
                                                                        child: const Text('Asignar'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                                if (confirm == true) {
                                                                  await _assignDriverToTrip(request, driver);
                                                                  Navigator.of(context).pop();
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selectedDriver != null) {
      // TODO: Assign driver to trip request in backend
      print('Asignar driver: ${selectedDriver!.id} a solicitud ${request.id}');
      // Assignment logic will be implemented next
    }
  }

  void _launchContact(String metodo, String contacto) async {
    final lower = metodo.toLowerCase();
    if (lower.contains('whatsapp')) {
      final url = 'https://wa.me/$contacto';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else if (lower.contains('mail') || lower.contains('correo')) {
      final url = 'mailto:$contacto';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else if (lower.contains('tel') ||
        lower.contains('llama') ||
        lower.contains('phone')) {
      final url = 'tel:$contacto';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  List<TripRequest> pendingRequests = [];
  String searchOrigen = '';
  String searchDestino = '';
  String taxiTypeFilter = 'todos';
  bool isLoading = false;
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    setState(() => isLoading = true);
    final client = Supabase.instance.client;
    final response = await client
        .from('trip_requests')
        .select(
          '*,origen:origen_id(*),destino:destino_id(*), contact:guest_contacts!contact_id(id,name,method,contact,address,extra_info)',
        )
        .eq('status', 'pending');
    final List<TripRequest> requests =
        (response as List)
            .map((json) => TripRequest.fromJson(json as Map<String, dynamic>))
            .toList();
    setState(() {
      pendingRequests = requests;
      isLoading = false;
    });
  }

  List<TripRequest> get filteredRequests {
    return pendingRequests.where((req) {
      final origen = req.origen?.nombre.toLowerCase() ?? '';
      final destino = req.destino?.nombre.toLowerCase() ?? '';
      final provinciaOrigen = req.origen?.provincia.toLowerCase() ?? '';
      final provinciaDestino = req.destino?.provincia.toLowerCase() ?? '';
      final taxiType = req.taxiType.toLowerCase();
      final matchOrigen =
          searchOrigen.isEmpty ||
          origen.contains(searchOrigen.toLowerCase()) ||
          provinciaOrigen.contains(searchOrigen.toLowerCase());
      final matchDestino =
          searchDestino.isEmpty ||
          destino.contains(searchDestino.toLowerCase()) ||
          provinciaDestino.contains(searchDestino.toLowerCase());
      final matchTipo = taxiTypeFilter == 'todos' || taxiType == taxiTypeFilter;
      return matchOrigen && matchDestino && matchTipo;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Pendientes'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText:
                                          'Buscar origen (municipio o provincia)',
                                      prefixIcon: const Icon(Icons.location_on),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchOrigen = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText:
                                          'Buscar destino (municipio o provincia)',
                                      prefixIcon: const Icon(Icons.flag),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchDestino = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_taxi,
                                  color: Colors.blue,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tipo:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: taxiTypeFilter,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'todos',
                                            child: Text('Todos'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'privado',
                                            child: Text('Privado'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'colectivo',
                                            child: Text('Colectivo'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            taxiTypeFilter = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final req = filteredRequests[index];
                        final isExpanded = _expandedStates[req.id!] ?? false;
                        final nombre = req.contact?.name ?? '';
                        final direccion = req.contact?.address ?? '';
                        final metodo = req.contact?.method ?? '';
                        final contact = req.contact?.contact ?? '';
                        final extraInfo = req.contact?.extraInfo ?? '';
                        final descripcion =
                            nombre + direccion + metodo + contact + extraInfo;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color:
                                  isExpanded
                                      ? Colors.blue.shade400
                                      : Colors.grey.shade200,
                              width: isExpanded ? 1.5 : 1,
                            ),
                          ),
                          elevation: isExpanded ? 6 : 2,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blue.shade50,
                                        child: Icon(
                                          Icons.local_taxi,
                                          color:
                                              (req.taxiType == 'privado')
                                                  ? Colors.blue
                                                  : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    156,
                                                    7,
                                                  ),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        req.taxiType == 'privado'
                                            ? 'Privado'
                                            : 'Colectivo',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              (req.taxiType == 'privado')
                                                  ? Colors.blue
                                                  : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    156,
                                                    7,
                                                  ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  '${req.origen?.nombre ?? ''} (${req.origen?.provincia ?? ''})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    '→ ${req.destino?.nombre ?? ''} (${req.destino?.provincia ?? ''})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.blue.shade400,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () =>
                                            _expandedStates[req.id!] =
                                                !isExpanded,
                                      ),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                alignment: Alignment.topCenter,
                                child:
                                    isExpanded
                                        ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.info_outline,
                                                    color: Colors.blue,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'ID: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${req.id ?? ''}',
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.people,
                                                    color: Colors.purple,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Personas: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${req.cantidadPersonas}',
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.teal,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Fecha: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${req.tripDate}',
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              if (descripcion.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 6.0,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.grey
                                                          .withOpacity(0.13),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Datos de contacto
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .person,
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      nombre,
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color:
                                                                        Colors
                                                                            .teal,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      direccion,
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .phone_android,
                                                                    color:
                                                                        Colors
                                                                            .green,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    metodo,
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      contact,
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .info_outline,
                                                                    color:
                                                                        Colors
                                                                            .orange,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      extraInfo,
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Icono lateral derecho según método de contacto
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                20,
                                                              ),
                                                          child: Builder(
                                                            builder: (context) {
                                                              Widget icono;
                                                              if (metodo
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    'whatsapp',
                                                                  )) {
                                                                icono = IconButton(
                                                                  onPressed:
                                                                      () => _launchContact(
                                                                        metodo,
                                                                        contact,
                                                                      ),
                                                                  icon: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .whatsapp,
                                                                    size: 36,
                                                                    color:
                                                                        AppColors
                                                                            .confirmed,
                                                                  ),
                                                                );
                                                              } else if (metodo
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'mail',
                                                                      ) ||
                                                                  metodo
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'correo',
                                                                      )) {
                                                                icono = IconButton(
                                                                  icon: const Icon(
                                                                    Icons.email,
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                    size: 36,
                                                                  ),
                                                                  tooltip:
                                                                      'Enviar correo',
                                                                  onPressed:
                                                                      () => _launchContact(
                                                                        metodo,
                                                                        contact,
                                                                      ),
                                                                );
                                                              } else if (metodo
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'tel',
                                                                      ) ||
                                                                  metodo
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'llama',
                                                                      ) ||
                                                                  metodo
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'phone',
                                                                      )) {
                                                                icono = IconButton(
                                                                  icon: const Icon(
                                                                    Icons.phone,
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                    size: 36,
                                                                  ),
                                                                  tooltip:
                                                                      'Llamar',
                                                                  onPressed:
                                                                      () => _launchContact(
                                                                        metodo,
                                                                        contact,
                                                                      ),
                                                                );
                                                              } else {
                                                                icono = IconButton(
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .contact_mail,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    size: 36,
                                                                  ),
                                                                  tooltip:
                                                                      'Contactar',
                                                                  onPressed:
                                                                      () => _launchContact(
                                                                        metodo,
                                                                        contact,
                                                                      ),
                                                                );
                                                              }
                                                              return icono;
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // Botón Asignar driver
                                              const SizedBox(height: 16),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    _showAssignDriverDialog(
                                                      req,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.person_add_alt_1,
                                                  ),
                                                  label: const Text(
                                                    'Asignar driver',
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 18,
                                                          vertical: 10,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
