import 'dart:async';
import 'package:eytaxi/core/services/driver_services.dart';
import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/models/guest_contact_model.dart';
import 'package:eytaxi/models/trip_request_model.dart';
import 'package:eytaxi/models/ubicacion_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/active_requests_card.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final DriverServices _supabaseService = DriverServices();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  List<TripRequest> activeRequests = [];
  StreamSubscription<SupabaseStreamEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    final driverState = Provider.of<ThemeNotifier>(context, listen: false);
    if (driverState.isOnline) {
      _loadPendingRequests();
      _subscribeToRequests();
    }

    // Escuchar cambios en isOnline
    Provider.of<ThemeNotifier>(context, listen: false).addListener(_handleDriverStateChange);
  }

  void _handleDriverStateChange() {
    final driverState = Provider.of<ThemeNotifier>(context, listen: false);
    if (driverState.isOnline) {
      _loadPendingRequests();
      _subscribeToRequests();
    } else {
      _subscription?.cancel();
      setState(() {
        activeRequests = [];
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    Provider.of<ThemeNotifier>(context, listen: false).removeListener(_handleDriverStateChange);
    super.dispose();
  }

  Future<void> _loadPendingRequests() async {
    final driverState = Provider.of<ThemeNotifier>(context, listen: false);
    if (!driverState.isOnline) {
      setState(() {
        activeRequests = [];
      });
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final requests = await _supabaseService.fetchPendingRequests();
      setState(() {
        activeRequests = requests;
        print('Loaded activeRequests: ${activeRequests.map((r) => 'ID=${r.id}, Contact=${r.contact?.address}, ExtraInfo=${r.contact?.extraInfo}').toList()}');
      });
    } catch (e) {
      print('Error loading pending requests: $e');
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error al cargar las solicitudes pendientes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _subscribeToRequests() {
    final driverState = Provider.of<ThemeNotifier>(context, listen: false);
    if (!driverState.isOnline) {
      _subscription?.cancel();
      setState(() {
        activeRequests = [];
      });
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('No user authenticated for subscription');
      return;
    }

    _subscription?.cancel();

    _subscription = Supabase.instance.client
        .from('trip_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen(
          (List<Map<String, dynamic>> data) async {
            final driverState = Provider.of<ThemeNotifier>(context, listen: false);
            if (!mounted || !driverState.isOnline) {
              setState(() {
                activeRequests = [];
              });
              return;
            }

            try {
              // Obtener respuestas del conductor
              final driverResponses = await Supabase.instance.client
                  .from('driver_responses')
                  .select('request_id')
                  .eq('driver_id', user.id);

              final respondedRequestIds = driverResponses
                  .map((response) => response['request_id'] as String)
                  .toSet();

              // Cargar ubicaciones para origen_id y destino_id
              final uniqueLocationIds = data
                  .expand((json) => [json['origen_id'] as int, json['destino_id'] as int])
                  .toSet();
              final ubicacionesResponse = await Supabase.instance.client
                  .from('ubicaciones_cuba')
                  .select('id, nombre, codigo, tipo, provincia, region')
                  .inFilter('id', uniqueLocationIds.toList());

              final ubicacionesMap = {
                for (var ub in ubicacionesResponse) ub['id']: Ubicacion.fromJson(ub)
              };

              // Cargar contactos para contact_id
              final uniqueContactIds = data
                  .map((json) => json['contact_id'] as String)
                  .toSet();
              final contactsResponse = await Supabase.instance.client
                  .from('guest_contacts')
                  .select('id, name, method, contact, address, extra_info, created_at')
                  .inFilter('id', uniqueContactIds.toList());

              final contactsMap = {
                for (var contact in contactsResponse) contact['id']: GuestContact.fromJson(contact)
              };

              if (!mounted) return;

              setState(() {
                activeRequests = data
                    .where((json) =>
                        !respondedRequestIds.contains(json['id']) &&
                        json['driver_id'] == null)
                    .map((json) {
                      print('Stream JSON: $json');
                      final trip = TripRequest.fromJson({
                        ...json,
                        'origen': ubicacionesMap[json['origen_id']]?.toJson(),
                        'destino': ubicacionesMap[json['destino_id']]?.toJson(),
                        'contact': contactsMap[json['contact_id']]?.toJson(),
                      });
                      print('Stream Parsed TripRequest: ID=${trip.id}, Contact=${trip.contact?.address}, ExtraInfo=${trip.contact?.extraInfo}');
                      return trip;
                    })
                    .toList();
                print('Stream activeRequests: ${activeRequests.map((r) => 'ID=${r.id}, Contact=${r.contact?.address}, ExtraInfo=${r.contact?.extraInfo}').toList()}');
              });
            } catch (e) {
              print('Error processing subscription data: $e');
              if (mounted) {
                Future.microtask(() {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text('Error al procesar datos: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            }
          },
          onError: (error) {
            print('Error in request subscription: $error');
            if (mounted) {
              Future.microtask(() {
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar las solicitudes: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
            Future.delayed(const Duration(seconds: 5), () {
              final driverState = Provider.of<ThemeNotifier>(context, listen: false);
              if (mounted && driverState.isOnline) {
                print('Reattempting subscription...');
                _subscribeToRequests();
              }
            });
          },
          onDone: () {
            print('Stream closed, attempting to reconnect...');
            Future.delayed(const Duration(seconds: 5), () {
              final driverState = Provider.of<ThemeNotifier>(context, listen: false);
              if (mounted && driverState.isOnline) {
                _subscribeToRequests();
              }
            });
          },
        );
  }

  Future<void> _handleRequestAccepted(TripRequest request) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final hasResponded = await _supabaseService.hasDriverResponded(request.id!, user.id);
      if (hasResponded) {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Ya has respondido a esta solicitud'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await _supabaseService.acceptTripRequest(request.id!, user.id);
      if (success) {
        setState(() {
          activeRequests.removeWhere((r) => r.id == request.id);
        });
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Solicitud aceptada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Solicitud guardada localmente, se sincronizará cuando haya conexión'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error accepting request: $e');
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error al aceptar la solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRequestRejected(TripRequest request) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final hasResponded = await _supabaseService.hasDriverResponded(request.id!, user.id);
      if (hasResponded) {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Ya has respondido a esta solicitud'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await _supabaseService.rejectTripRequest(request.id!, user.id);
      if (success) {
        setState(() {
          activeRequests.removeWhere((r) => r.id == request.id);
        });
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Solicitud rechazada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Acción guardada localmente, se sincronizará cuando haya conexión'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error rejecting request: $e');
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error al rechazar la solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = Provider.of<ThemeNotifier>(context);
    print('Passing to ActiveRequestsCard: ${activeRequests.map((r) => 'ID=${r.id}, Contact=${r.contact?.address}, ExtraInfo=${r.contact?.extraInfo}').toList()}');
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8),
        children: [
          _buildRequestsSection(),
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActiveRequestsCard(
          requests: activeRequests,
          onRequestAccepted: _handleRequestAccepted,
          onRequestRejected: _handleRequestRejected,
        ),
      ],
    );
  }
}