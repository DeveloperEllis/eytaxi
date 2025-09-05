import 'package:eytaxi/data/models/driver_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverProfileRemoteDataSource {
  final SupabaseClient client;
  DriverProfileRemoteDataSource(this.client);

  Future<(Map<String, dynamic> userProfile, Driver? driver)> fetchProfile(String userId) async {
    try {
      // Obtener el perfil del usuario
      final up = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      // Obtener información del conductor si existe
      final drvRes = await client
          .from('drivers')
          .select()
          .eq('id', userId)
          .maybeSingle();
          
      Driver? driver;
      if (drvRes != null && up != null) {
        // Combinar datos del usuario y conductor
        var merged = {
          ...Map<String, dynamic>.from(drvRes),
          ...Map<String, dynamic>.from(up),
        };
        
        // TODO: Obtener información del municipio de origen cuando la tabla ubicaciones esté disponible
        // final municipioId = drvRes['id_municipio_de_origen'] as int?;
        // if (municipioId != null && municipioId > 0) {
        //   final municipioRes = await client
        //       .from('ubicaciones')
        //       .select('id, nombre, codigo, tipo')
        //       .eq('id', municipioId)
        //       .maybeSingle();
        //       
        //   if (municipioRes != null) {
        //     merged['origen'] = municipioRes;
        //   }
        // }
        
        driver = Driver.fromJson(merged);
      }
      
      return (Map<String, dynamic>.from(up ?? {}), driver);
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<bool> updateUserProfile(String userId, {String? nombre, String? apellidos, String? phoneNumber}) async {
    final data = <String, dynamic>{};
    if (nombre != null) data['nombre'] = nombre;
    if (apellidos != null) data['apellidos'] = apellidos;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (data.isEmpty) return true;
    await client.from('user_profiles').update(data).eq('id', userId);
    return true;
  }

  Future<bool> updateProfilePhoto(String userId, String photoUrl) async {
    await client.from('user_profiles').update({'photo_url': photoUrl}).eq('id', userId);
    return true;
  }

  Future<bool> updateDriverInfo(
    String userId, {
    String? licenseNumber,
    int? vehicleCapacity,
    List<String>? routes,
    bool? isAvailable,
    int? idMunicipioDeOrigen,
    bool? viajesLocales,
    String? vehiclePhotoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (licenseNumber != null) data['license_number'] = licenseNumber;
    if (vehicleCapacity != null) data['vehicle_capacity'] = vehicleCapacity;
    if (routes != null) data['routes'] = routes;
    if (isAvailable != null) data['is_available'] = isAvailable;
    if (idMunicipioDeOrigen != null) data['id_municipio_de_origen'] = idMunicipioDeOrigen;
    if (viajesLocales != null) data['viajes_locales'] = viajesLocales;
    if (vehiclePhotoUrl != null) data['vehicle_photo_url'] = vehiclePhotoUrl;
    if (data.isEmpty) return true;
    await client.from('drivers').update(data).eq('id', userId);
    return true;
  }

  Future<bool> updateVehiclePhoto(String userId, String photoUrl) async {
    await client.from('drivers').update({'vehicle_photo_url': photoUrl}).eq('id', userId);
    return true;
  }
}
