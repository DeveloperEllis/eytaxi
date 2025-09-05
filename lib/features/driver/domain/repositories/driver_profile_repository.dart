import 'package:eytaxi/data/models/driver_model.dart';

abstract class DriverProfileRepository {
  Future<(Map<String, dynamic> userProfile, Driver? driver)> fetchProfile(String userId);
  Future<bool> updateUserProfile(String userId, {String? nombre, String? apellidos, String? phoneNumber});
  Future<bool> updateProfilePhoto(String userId, String photoUrl);
  Future<bool> updateDriverInfo(
    String userId, {
    String? licenseNumber,
    int? vehicleCapacity,
    List<String>? routes,
    bool? isAvailable,
    int? idMunicipioDeOrigen,
    bool? viajesLocales,
    String? vehiclePhotoUrl,
  });
  Future<bool> updateVehiclePhoto(String userId, String photoUrl);
}
