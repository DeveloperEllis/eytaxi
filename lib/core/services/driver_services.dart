import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eytaxi/models/trip_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverServices {
  final SupabaseClient client = Supabase.instance.client;

  Future<bool> hasDriverResponded(String requestId, String driverId) async {
    try {
      final response = await client
          .from('driver_responses')
          .select()
          .eq('request_id', requestId)
          .eq('driver_id', driverId);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking if driver has responded: $e');
      return false;
    }
  }

  Future<List<TripRequest>> fetchPendingRequests() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('No authenticated user for fetching pending requests');
        return [];
      }

      final response = await client
          .from('trip_requests')
          .select('''
          id,contact_id,driver_id,origen_id,destino_id,taxi_type,cantidad_personas,
          trip_date,status,price,distance_km,estimated_time_minutes,created_at,
          origen:ubicaciones_cuba!origen_id(id,nombre,codigo,region,tipo,provincia),
          destino:ubicaciones_cuba!destino_id(id,nombre,codigo,region,tipo,provincia),
          contact:guest_contacts!contact_id(id,name,method,contact,address,extra_info)
        ''')
          .eq('status', 'pending')
          .isFilter('driver_id', null);

      final driverResponses = await client
          .from('driver_responses')
          .select('request_id')
          .eq('driver_id', user.id);

      final respondedRequestIds =
          driverResponses
              .map((response) => response['request_id'] as String)
              .toSet();

      final requests =
          (response as List<dynamic>)
              .map((json) {
                final trip = TripRequest.fromJson(json as Map<String, dynamic>);
                return trip;
              })
              .where((request) => !respondedRequestIds.contains(request.id))
              .toList();

      return requests;
    } catch (e) {
      print('Error al obtener solicitudes (DriverServices): $e');
      return [];
    }
  }

  Future<bool> acceptTripRequest(String requestId, String driverId) async {
    final isConnected = await _isConnected();
    if (!isConnected) {
      await _saveActionOffline(requestId, driverId, 'accept');
      return false;
    }

    try {
      await client.from('driver_responses').insert({
        'request_id': requestId,
        'driver_id': driverId,
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error accepting trip request: $e');
      await _saveActionOffline(requestId, driverId, 'accept');
      return false;
    }
  }

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> rejectTripRequest(String requestId, String driverId) async {
    final isConnected = await _isConnected();
    if (!isConnected) {
      await _saveActionOffline(requestId, driverId, 'reject');
      return false;
    }

    try {
      await client.from('driver_responses').insert({
        'request_id': requestId,
        'driver_id': driverId,
        'status': 'rejected',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error rejecting trip request: $e');
      await _saveActionOffline(requestId, driverId, 'reject');
      return false;
    }
  }

  Future<void> _saveActionOffline(
    String requestId,
    String? driverId,
    String action,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final actions = prefs.getStringList('offline_driver_actions') ?? [];
    actions.add(
      jsonEncode({
        'request_id': requestId,
        'driver_id': driverId,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    await prefs.setStringList('offline_driver_actions', actions);
  }

  Future<void> syncOfflineTripRequests() async {
    if (!await _isConnected()) return;

    final prefs = await SharedPreferences.getInstance();
    final requests = prefs.getStringList('offline_trip_requests') ?? [];
    if (requests.isEmpty) return;

    final validRequests = <String>[];
    try {
      for (var requestJson in requests) {
        final request = jsonDecode(requestJson) as Map<String, dynamic>;
        // Validar y corregir taxi_type
        if (request['taxi_type'] != 'colectivo' &&
            request['taxi_type'] != 'privado') {
          print(
            'Invalid taxi_type in offline request: ${request['taxi_type']}, correcting to colectivo',
          );
          request['taxi_type'] = 'colectivo';
        }
        print(
          'Syncing offline trip request with taxi_type: ${request['taxi_type']}',
        );
        await client.from('trip_requests').insert(request);
        validRequests.add(requestJson);
      }
      // Solo eliminar las solicitudes que se sincronizaron con éxito
      await prefs.setStringList(
        'offline_trip_requests',
        requests.where((r) => !validRequests.contains(r)).toList(),
      );
    } catch (e) {
      print('Error syncing offline trip requests: $e');
    }
  }
}
