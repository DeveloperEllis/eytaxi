import 'package:eytaxi/core/styles/button_style.dart';
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
        print(
          'DEBUG: Trip ${trip.id} - Status: "${trip.status.name}" - Type: ${trip.status.runtimeType}',
        );
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
      body:
          isLoading
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
    final shortId = tripId.length > 8 ? tripId.substring(0, 8) : tripId;

    // Simplificar status - usar directamente el valor del enum
    final status = trip.status.name.toLowerCase();

    // DEBUG: imprime el status actual
    print('DEBUG-CARD: trip.id=${trip.id} status="$status"');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con fondo suave
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    'Viaje #$shortId',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (precio != '0')
                  Text(
                    '\$${_formatPrice(precio)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rutas con diseño limpio
                Column(
                  children: [
                    // Origen
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            origenNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Línea simple
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Container(
                          width: 1,
                          height: 12,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 11),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Destino
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            destinoNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Info básica en grid simple
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleInfo(
                        Icons.local_taxi,
                        tipoTaxi.toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleInfo(
                        Icons.people,
                        '${cantidadPersonas} Personas',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Footer minimalista
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSimpleInfo(
                      Icons.calendar_month,
                      _formatFechaCompacta(trip.tripDate),
                    ),

                    if (status == 'accepted' || status == 'started')
                      _buildCleanActionButton(trip, status),
                  ],
                ),
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

    print(
      'DEBUG-BUTTON: trip.id=${trip.id} status="$status" canStart=$canStart canComplete=$canComplete',
    );

    if (!canStart && !canComplete) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed:
          isCurrentlyUpdating
              ? null
              : () async {
                // Mostrar diálogo de confirmación antes de la acción
                final confirmed = await _showConfirmationDialog(
                  context,
                  canStart ? 'Iniciar Viaje' : 'Finalizar Viaje',
                  canStart
                      ? '¿Está seguro que desea iniciar este viaje?\n\nEsto marcará el viaje como "En Progreso".'
                      : '¿Está seguro que desea finalizar este viaje?\n\nEsto completará el viaje y no podrá revertirse.',
                  canStart ? Icons.play_arrow : Icons.stop,
                  canStart ? Colors.green : Colors.orange,
                );

                if (!confirmed) return;

                print(
                  'DEBUG-ACTION: Button pressed for trip ${trip.id} with status $status',
                );
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
                    success = await _dataSource.completeTrip(
                      trip.id.toString(),
                    );
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
                    print(
                      'DEBUG-ACTION: Reloading trips after successful update',
                    );
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 3,
      ),
      icon:
          isCurrentlyUpdating
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Icon(canStart ? Icons.play_arrow : Icons.stop, size: 18),
      label: Text(
        canStart ? 'Iniciar Viaje' : 'Finalizar Viaje',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirmar',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Métodos auxiliares para diseño minimalista
  Widget _buildSimpleInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanActionButton(TripRequest trip, String status) {
    final canStart = status == 'accepted';
    final canComplete = status == 'started';
    final isCurrentlyUpdating = isUpdatingStatus && selectedTrip?.id == trip.id;

    if (!canStart && !canComplete) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed:
          isCurrentlyUpdating
              ? null
              : () async {
                final confirmed = await _showConfirmationDialog(
                  context,
                  canStart ? 'Iniciar Viaje' : 'Finalizar Viaje',
                  canStart
                      ? '¿Está seguro que desea iniciar este viaje?'
                      : '¿Está seguro que desea finalizar este viaje?',
                  canStart ? Icons.play_arrow : Icons.stop,
                  canStart ? Colors.green : Colors.orange,
                );

                if (!confirmed) return;

                setState(() {
                  selectedTrip = trip;
                  isUpdatingStatus = true;
                });

                try {
                  bool success = false;
                  if (canStart) {
                    success = await _dataSource.startTrip(trip.id.toString());
                  } else if (canComplete) {
                    success = await _dataSource.completeTrip(
                      trip.id.toString(),
                    );
                  }

                  if (success) {
                    await Future.delayed(const Duration(milliseconds: 500));
                    await _loadTrips();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            canStart ? 'Viaje iniciado' : 'Viaje finalizado',
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    throw Exception('Error al actualizar el viaje');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child:
          isCurrentlyUpdating
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Text(
                canStart ? 'Iniciar' : 'Finalizar',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }
}
