import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eytaxi/features/driver/data/datasources/driver_requests_remote_datasource.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';

class ViajesPage extends StatefulWidget {
  const ViajesPage({super.key});

  @override
  State<ViajesPage> createState() => _ViajesPageState();
}

class _ViajesPageState extends State<ViajesPage> {
  late String driverId;
  late DriverRequestsRemoteDataSource _dataSource;
  List<TripRequest> tripRequests = [];
  bool isLoading = true;
  Set<String> expandedCards = {};
  TripRequest? selectedTrip;
  bool isUpdatingStatus = false;

  // Cambia a true si quieres ver una etiqueta DEBUG dentro de cada card
  final bool showDebug = true;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    driverId = user?.id ?? '';
    _dataSource = DriverRequestsRemoteDataSource(Supabase.instance.client);
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (driverId.isEmpty) return;
    setState(() => isLoading = true);

    try {
      print('DEBUG: Loading trips for driver $driverId');
      final trips = await _dataSource.fetchAcceptedRequests(driverId);
      print('DEBUG: Loaded ${trips.length} trips');
      
      for (var trip in trips) {
        print('DEBUG: Trip ${trip.id} - Status: "${trip.status.name}" - Type: ${trip.status.runtimeType}');
      }
      
      setState(() {
        tripRequests = trips;
      });
    } catch (e) {
      print('Error loading trips: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar viajes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tripRequests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tripRequests.length,
                    itemBuilder: (context, index) {
                      final trip = tripRequests[index];
                      return _buildTripCard(trip);
                    },
                  ),
                ),
      floatingActionButton: null,
    );
  }

  Widget _buildTripCard(TripRequest trip) {
    final tripId = trip.id.toString();
    final isExpanded = expandedCards.contains(tripId);
    final origenNombre = trip.origen?.nombre ?? 'Origen no especificado';
    final destinoNombre = trip.destino?.nombre ?? 'Destino no especificado';
    final contactNombre = trip.contact?.name ?? 'Pasajero';
    final metodoContacto = trip.contact?.method ?? '';
    final contacto = trip.contact?.contact ?? '';
    final direccion = trip.contact?.address ?? '';
    final datosExtras = trip.contact?.extraInfo ?? '';
    final precio = trip.price?.toString() ?? '0';
    final cantidadPersonas = trip.cantidadPersonas;
    final tipoTaxi = trip.taxiType;

    // Simplificar status - usar directamente el valor del enum
    final status = trip.status.name.toLowerCase();
    
    // DEBUG: imprime el status actual
    print('DEBUG-CARD: trip.id=${trip.id} status="$status"');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header: Estado y precio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEstadoChip(status),
                    if (precio != '0')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            Text(
                              _formatPrice(precio),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ruta compacta
                Row(
                  children: [
                    Icon(Icons.route, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$origenNombre → $destinoNombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Info compacta en una sola fila con botón a la derecha
                Row(
                  children: [
                    _buildCompactInfo(
                      Icons.calendar_today,
                      _formatFechaCompacta(trip.tripDate),
                    ),
                    const SizedBox(width: 12),
                    _buildCompactInfo(Icons.local_taxi, tipoTaxi.toUpperCase()),
                    const SizedBox(width: 12),
                    _buildCompactInfo(Icons.people, '$cantidadPersonas'),
                    const Spacer(), // Esto empuja el botón hacia la derecha
                    if (status == 'accepted' || status == 'started')
                      _buildTripActionButton(trip),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Botón expandir
          Material(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedCards.remove(tripId);
                  } else {
                    expandedCards.add(tripId);
                  }
                });
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Info Pasajero',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Información expandible (simplificada)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: _buildSimpleGuestInfo(
                contactNombre,
                metodoContacto,
                contacto,
                direccion,
                datosExtras,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripActionButton(TripRequest trip) {
    final status = trip.status.name.toLowerCase();
    final canStart = status == 'accepted';
    final canComplete = status == 'started';
    final isCurrentlyUpdating = isUpdatingStatus && selectedTrip?.id == trip.id;

    print('DEBUG-BUTTON: trip.id=${trip.id} status="$status" canStart=$canStart canComplete=$canComplete');

    if (!canStart && !canComplete) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: isCurrentlyUpdating
          ? null
          : () async {
              print('DEBUG-ACTION: Button pressed for trip ${trip.id} with status $status');
              setState(() {
                selectedTrip = trip;
                isUpdatingStatus = true;
              });

              try {
                bool success = false;
                if (canStart) {
                  print('DEBUG-ACTION: Starting trip ${trip.id}');
                  success = await _dataSource.startTrip(trip.id.toString());
                  if (success) {
                    print('DEBUG-ACTION: Trip started successfully');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viaje iniciado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } else if (canComplete) {
                  print('DEBUG-ACTION: Completing trip ${trip.id}');
                  success = await _dataSource.completeTrip(trip.id.toString());
                  if (success) {
                    print('DEBUG-ACTION: Trip completed successfully');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viaje finalizado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }

                if (success) {
                  print('DEBUG-ACTION: Reloading trips after successful update');
                  // Pequeño delay para asegurar que la DB se actualice completamente
                  await Future.delayed(const Duration(milliseconds: 800));
                  await _loadTrips();
                  print('DEBUG-ACTION: Trips reloaded');
                } else {
                  throw Exception('Error al actualizar el viaje');
                }
              } catch (e) {
                print('DEBUG-ACTION: Error occurred: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    isUpdatingStatus = false;
                    selectedTrip = null;
                  });
                }
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: canStart ? Colors.green : Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      icon: isCurrentlyUpdating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(
              canStart ? Icons.play_arrow : Icons.stop,
              size: 16,
            ),
      label: Text(
        canStart ? 'Empezar' : 'Finalizar',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Resto de helpers (idénticos a los tuyos, sólo se adaptó _buildEstadoChip a recibir status normalizado)

  Widget _buildCompactInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleGuestInfo(
    String nombre,
    String metodo,
    String contacto,
    String direccion,
    String datosExtras,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nombre.isNotEmpty) _buildSimpleInfoRow('Nombre:', nombre),
        if (metodo.isNotEmpty && contacto.isNotEmpty)
          _buildSimpleInfoRow('${_getContactLabel(metodo)}:', contacto),
        if (direccion.isNotEmpty) _buildSimpleInfoRow('Dirección:', direccion),
        if (datosExtras.isNotEmpty) _buildSimpleInfoRow('Notas:', datosExtras),
      ],
    );
  }

  Widget _buildSimpleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFechaCompacta(DateTime fecha) {
    return '${fecha.day}/${fecha.month} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _getContactLabel(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'phone':
      case 'telefono':
        return 'Teléfono';
      case 'email':
      case 'correo':
        return 'Email';
      case 'whatsapp':
        return 'WhatsApp';
      default:
        return 'Contacto';
    }
  }

  Widget _buildEstadoChip(String status) {
    Color color;
    String texto;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        texto = 'Pendiente';
        icon = Icons.schedule;
        break;
      case 'accepted':
        color = Colors.blue;
        texto = 'Aceptado';
        icon = Icons.check_circle_outline;
        break;
      case 'started':
        color = Colors.purple;
        texto = 'En Progreso';
        icon = Icons.directions_car;
        break;
      case 'finished':
        color = Colors.green;
        texto = 'Finalizado';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        texto = 'Cancelado';
        icon = Icons.cancel_outlined;
        break;
      case 'rejected':
        color = Colors.grey;
        texto = 'Rechazado';
        icon = Icons.do_not_disturb_outlined;
        break;
      default:
        color = Colors.grey;
        texto = status;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String precio) {
    try {
      final num = double.parse(precio);
      return num.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return precio;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airport_shuttle, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No tienes viajes asignados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus viajes aparecerán aquí cuando sean asignados',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
