import 'package:eytaxi/data/models/guest_contact_model.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverRequestsRemoteDataSource {
  final SupabaseClient client;
  DriverRequestsRemoteDataSource(this.client);

  Future<List<TripRequest>> fetchPendingRequests(String driverId) async {
    final now = DateTime.now().toIso8601String();
    
    final requests = await client
        .from('trip_requests')
        .select('*')
        .eq('status', 'pending')
        .isFilter('driver_id', null)
        .gt('trip_date', now);

    // Excluir solicitudes ya respondidas por este conductor
    final responded = await client
      .from('driver_responses')
      .select('request_id')
      .eq('driver_id', driverId);
    final respondedIds = {
      for (final row in (responded as List)) row['request_id'] as String
    };

    final filtered = (requests as List)
      .where((json) => !respondedIds.contains(json['id']))
      .toList();

    return _hydrateRequests(filtered);
  }

  Future<List<TripRequest>> fetchAcceptedRequests(String driverId) async {
    final now = DateTime.now().toIso8601String();
    
    final requests = await client
        .from('trip_requests')
        .select('*')
        .eq('driver_id', driverId)
        .inFilter('status', ['accepted', 'started'])
        .gt('trip_date', now)
        .order('created_at', ascending: false);

    return _hydrateRequests(requests as List);
  }

  Stream<List<TripRequest>> watchPendingRequests(String driverId) {
    final stream = client
      .from('trip_requests')
      .stream(primaryKey: ['id'])
      .eq('status', 'pending');

    return stream.asyncMap((data) async {
      // Solicitudes pendientes sin driver asignado y con fecha futura
      final pending = data
          .where((json) => 
              json['driver_id'] == null && 
              json['trip_date'] != null &&
              DateTime.parse(json['trip_date']).isAfter(DateTime.now()))
          .toList();

      // Excluir las que este conductor ya respondió
      final responded = await client
          .from('driver_responses')
          .select('request_id')
          .eq('driver_id', driverId);
      final respondedIds = {
        for (final row in (responded as List)) row['request_id'] as String
      };

      final filtered = pending
          .where((json) => !respondedIds.contains(json['id']))
          .toList();

  return _hydrateRequests(filtered);
    });
  }

  Future<bool> hasDriverResponded(String requestId, String driverId) async {
    final res = await client
        .from('driver_responses')
        .select('request_id')
        .eq('request_id', requestId)
        .eq('driver_id', driverId);
    return (res as List).isNotEmpty;
  }

  Future<bool> acceptTripRequest(String requestId, String driverId) async {
    try {
      await client.from('driver_responses').insert({
        'request_id': requestId,
        'driver_id': driverId,
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectTripRequest(String requestId, String driverId) async {
    try {
      await client.from('driver_responses').insert({
        'request_id': requestId,
        'driver_id': driverId,
        'status': 'rejected',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> startTrip(String requestId) async {
    try {
      await client
          .from('trip_requests')
          .update({'status': 'started'})
          .eq('id', requestId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completeTrip(String requestId) async {
    try {
      await client
          .from('trip_requests')
          .update({'status': 'finished'})
          .eq('id', requestId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<TripRequest>> _hydrateRequests(List data) async {
    final uniqueLocationIds = data
        .expand((json) => [json['origen_id'] as int?, json['destino_id'] as int?])
        .where((id) => id != null)
        .cast<int>()
        .toSet()
        .toList();
    final ubicacionesResponse = uniqueLocationIds.isEmpty
        ? []
        : await client
            .from('ubicaciones_cuba')
            .select('id, nombre, codigo, tipo, provincia, region')
            .inFilter('id', uniqueLocationIds);
    final ubicacionesMap = {
      for (var ub in ubicacionesResponse) ub['id']: Ubicacion.fromJson(ub)
    };

    final uniqueContactIds = data
        .map((json) => json['contact_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .toList();
    final contactsResponse = uniqueContactIds.isEmpty
        ? []
        : await client
            .from('guest_contacts')
            .select('id, name, method, contact, address, extra_info, created_at')
            .inFilter('id', uniqueContactIds);
    final contactsMap = {
      for (var contact in contactsResponse) contact['id']: GuestContact.fromJson(contact)
    };

    return data
        .where((json) => json['origen_id'] != null && json['destino_id'] != null && json['contact_id'] != null)
        .map((json) => TripRequest.fromJson({
              ...json,
              'origen': ubicacionesMap[json['origen_id']]?.toJson() ?? {},
              'destino': ubicacionesMap[json['destino_id']]?.toJson() ?? {},
              'contact': contactsMap[json['contact_id']]?.toJson() ?? {},
            }))
        .toList();
  }

  // Métodos para historial
  Future<List<TripRequest>> fetchCompletedTrips(String driverId, {DateTime? startDate, DateTime? endDate}) async {
    var query = client
        .from('trip_requests')
        .select('*')
        .eq('driver_id', driverId)
        .eq('status', 'finished');

    if (startDate != null && endDate != null) {
      // Filtrar por rango de fechas
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query
          .gte('trip_date', startDate.toIso8601String())
          .lte('trip_date', endOfDay.toIso8601String());
    } else if (startDate != null) {
      query = query.gte('trip_date', startDate.toIso8601String());
    } else if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query.lte('trip_date', endOfDay.toIso8601String());
    }

    final requests = await query.order('trip_date', ascending: false);
    return _hydrateRequests(requests as List);
  }

  Future<int> getCompletedTripsCount(String driverId) async {
    final response = await client
        .from('trip_requests')
        .select('id')
        .eq('driver_id', driverId)
        .eq('status', 'finished');
    
    return (response as List).length;
  }

  Future<double> getTotalEarnings(String driverId) async {
    final response = await client
        .from('trip_requests')
        .select('price')
        .eq('driver_id', driverId)
        .eq('status', 'finished');
    
    double total = 0.0;
    for (final trip in response as List) {
      final price = trip['price'];
      if (price != null) {
        if (price is int) {
          total += price.toDouble();
        } else if (price is double) {
          total += price;
        }
      }
    }
    return total;
  }

  Future<double> getFilteredEarnings(String driverId, {DateTime? startDate, DateTime? endDate}) async {
    var query = client
        .from('trip_requests')
        .select('price')
        .eq('driver_id', driverId)
        .eq('status', 'finished');

    if (startDate != null && endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query
          .gte('trip_date', startDate.toIso8601String())
          .lte('trip_date', endOfDay.toIso8601String());
    } else if (startDate != null) {
      query = query.gte('trip_date', startDate.toIso8601String());
    } else if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query.lte('trip_date', endOfDay.toIso8601String());
    }

    final response = await query;
    
    double total = 0.0;
    for (final trip in response as List) {
      final price = trip['price'];
      if (price != null) {
        if (price is int) {
          total += price.toDouble();
        } else if (price is double) {
          total += price;
        }
      }
    }
    return total;
  }
}
