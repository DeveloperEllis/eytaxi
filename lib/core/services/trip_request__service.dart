import 'package:eytaxi/core/enum/trip_status.dart';
import 'package:eytaxi/models/guest_contact_model.dart';
import 'package:eytaxi/models/trip_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripRequestService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Crear una nueva solicitud de viaje
  Future<void> createTripRequest(
    TripRequest request,
    GuestContact contact,
  ) async {
    // Primero, insertamos el contacto del invitado
    try {
      final response =
          await _client
              .from('guest_contacts')
              .insert({
                'name': contact.name,
                'method': contact.method,
                'contact': contact.contact,
                'address': contact.address,
                'extra_info': contact.extraInfo,
              })
              .select()
              .single();

      final contactId = response['id'];

      // Luego, insertamos la solicitud de viaje con el ID del contacto
      await _client.from('trip_requests').insert({
        "contact_id": contactId as String,
        "driver_id": null,
        "origen_id": request.origenId,
        "destino_id": request.destinoId,
        "taxi_type": request.taxiType,
        "cantidad_personas": request.cantidadPersonas,
        "trip_date": request.tripDate.toIso8601String(),
        "status": 'pending',
        "price": request.price ?? 0.0,
        "distance_km": request.distanceKm ?? 0.0,
        "estimated_time_minutes": request.estimatedTimeMinutes ?? 0,
      }).select(); // opcional si quieres retornar el objeto insertado
    } catch (e) {
      throw Exception('Error al crear solicitud: $e');
    }
  }

   

  Future<Map<String, dynamic>?> calculateReservationDetails(
    int idOrigen,
    int idDestino,
  ) async {
    try {
      final response = await _client.rpc(
        'calculate_reservation_details',
        params: {'p_id_origen': idOrigen, 'p_id_destino': idDestino},
      );
      if (response == null || (response is List && response.isEmpty)) {
        print(
          'No se encontraron datos para origen_id: $idOrigen, destino_id: $idDestino',
        );
        return null;
      }
      return response is List
          ? response.first as Map<String, dynamic>
          : response as Map<String, dynamic>;
    } catch (e) {
      print('Error al calcular detalles de la reserva: $e');
      return null;
    }
  }

  String _statusToString(TripStatus status) {
  switch (status) {
    case TripStatus.accepted:
      return 'accepted';
    case TripStatus.rejected:
      return 'rejected';
    case TripStatus.completed:
      return 'completed';
    case TripStatus.cancelled:
      return 'cancelled';
    case TripStatus.pending:
      return 'pending';
  }
}

  /// Obtener todas las solicitudes de un usuario
  Future<List<TripRequest>> getRequestsByUser(String userId) async {
    try {
      final data = await _client
          .from('trip_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => TripRequest.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  /// Obtener una solicitud por ID
  Future<TripRequest?> getRequestById(String id) async {
    try {
      final data =
          await _client
              .from('trip_requests')
              .select()
              .eq('id', id)
              .maybeSingle();

      if (data == null) return null;

      return TripRequest.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener solicitud: $e');
    }
  }

  /// Actualizar estado de la solicitud
  Future<void> updateStatus(String id, String newStatus) async {
    try {
      await _client
          .from('trip_requests')
          .update({'status': newStatus})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  /// Eliminar solicitud
  Future<void> deleteRequest(String id) async {
    try {
      await _client.from('trip_requests').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar solicitud: $e');
    }
  }
}
