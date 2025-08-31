import 'package:eytaxi/models/taxista_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Función temporal para probar la obtención de user_profiles desde consola

void testFetchUserProfiles() async {
  final source = SupabaseTaxistaSource();
  final profiles = await source.fetchAllUserProfiles();
  print('RESULTADO USER_PROFILES:');
  for (final p in profiles) {
    print(p);
  }
}
 
class SupabaseTaxistaSource {
  Future<List<Map<String, dynamic>>> fetchAllUserProfiles() async {
    final response = await _client.from('user_profiles').select();
    print('DEBUG USER_PROFILES: ' + response.toString());
    return (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Driver>> fetchAllDrivers() async {
    // Join con user_profile para obtener datos completos del usuario
    final response = await _client
        .from('drivers')
        .select(
          '*, user_profile:user_profiles!drivers_id_fkey(id, email, nombre, apellidos, phone_number, photo_url)',
        );

    return (response as List).map((json) {
      final userProfile = json['user_profile'] ?? {};
      final Map<String, dynamic> merged = {
        ...(Map<String, dynamic>.from(json)),
        ...(Map<String, dynamic>.from(userProfile)),
      };
      return Driver.fromJson(merged);
    }).toList();
  }
}
