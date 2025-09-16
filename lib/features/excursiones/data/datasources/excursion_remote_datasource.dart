import 'package:eytaxi/data/models/guest_contact_model.dart';
import 'package:eytaxi/features/excursiones/data/models/reserva_excusion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExcursionRemoteDataSource {
  final SupabaseClient client;
  ExcursionRemoteDataSource(this.client);

  Future<void> createExcursionReservation(ReservaExc reserva, GuestContact contact) async {
    try {
      print('🔄 Iniciando creación de reserva en el servicio...');

      // Insertar el contacto del invitado
      final contactResponse = await client
          .from('guest_contacts')
          .insert(contact.toJson())
          .select()
          .single();

      final contactId = contactResponse['id'];
      print(contactId);
      // Insertar la reserva de excursión con el ID del contacto
      await client.from('reservas_excursiones').insert({
        ...reserva.toJson(),
        'contact_id': contactId,
      });
    } catch (e) {
      print('❌ Error en el servicio: $e');
      rethrow; // Re-lanzar el error para que sea capturado arriba
    }
  }

  Future<List<ReservaExc>> getExcursionReservations() async {
    final data = await client.from('reservas_excursiones').select();
    return (data as List).map((json) => ReservaExc.fromJson(json)).toList();
  }
}
