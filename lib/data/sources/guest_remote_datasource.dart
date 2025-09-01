import '../../core/services/supabase_service.dart';
import '../models/guest_contact_model.dart';

class GuestContactRemoteDataSource {
  final SupabaseService _supabaseService = SupabaseService();

  Future<String> createGuestContact(GuestContact contact) async {
    final response = await _supabaseService.client
        .from('guest_contacts')
        .insert(contact.toJson())
        .select()
        .single();

    if (response['id'] == null) {
      throw Exception('Error al crear el contacto.');
    }

    return response['id'];
  }

  Future<GuestContact> getGuestContactById(String id) async {
    final response = await _supabaseService.client
        .from('guest_contacts')
        .select()
        .eq('id', id)
        .single();

    return GuestContact.fromJson(response);
  }
}
