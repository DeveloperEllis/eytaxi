import 'package:eytaxi/data/models/guest_contact_model.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripRequestRemoteDataSource {
  final SupabaseClient client;

  TripRequestRemoteDataSource(this.client);

  Future<TripRequest> createTripRequest(TripRequest request, GuestContact contact) async {
    // Insertar el contacto del invitado
    
    final contactResponse = await client
        .from('guest_contacts')
        .insert(contact.toJson())
        .select()
        .single();
    final contactId = contactResponse['id'];
 
  // Insertar la solicitud de viaje y devolver la fila creada
  final tripRow = await client
    .from('trip_requests')
    .insert(request.toJson(contactId: contactId))
    .select()
    .single();

  return TripRequest.fromJson(tripRow);
  }

  Future<List<TripRequest>> getRequestsByUser(String userId) async {
    final data = await client
        .from('trip_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((json) => TripRequest.fromJson(json))
        .toList();
  }

  Future<TripRequest?> getRequestById(String id) async {
    final data = await client
        .from('trip_requests')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return TripRequest.fromJson(data);
  }

  Future<void> updateStatus(String id, String newStatus) async {
    await client
        .from('trip_requests')
        .update({'status': newStatus})
        .eq('id', id);
  }

  Future<void> deleteRequest(String id) async {
    await client.from('trip_requests').delete().eq('id', id);
  }

  Future<Map<String, dynamic>?> calculateReservationDetails(int idOrigen, int idDestino) async {
    final response = await client.rpc(
      'calculate_reservation_details',
      params: {'p_id_origen': idOrigen, 'p_id_destino': idDestino},
    );
    if (response == null || (response is List && response.isEmpty)) {
      return null;
    }
    return response is List ? response.first as Map<String, dynamic> : response as Map<String, dynamic>;
  }
}
