import 'package:eytaxi/models/user_model.dart';

class Driver extends User {
  final String licenseNumber;
  final String vehiclePhotoUrl;
  final int vehicleCapacity;
  final List<String> routes;
  final bool isAvailable;

  Driver({
    required super.id,
    required super.email,
    required super.nombre,
    required super.apellidos,
    required super.phoneNumber,
    required super.photoUrl,
    required this.licenseNumber,
    required this.vehiclePhotoUrl,
    required this.vehicleCapacity,
    required this.routes,
    this.isAvailable = true,
  }) : super(userType: UserType.driver);

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      phoneNumber: json['phone_number'],
      photoUrl: json['photo_url'],
      licenseNumber: json['license_number'],
      vehiclePhotoUrl: json['vehicle_photo_url'],
      vehicleCapacity: json['vehicle_capacity'],
      routes: List<String>.from(json['routes']),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'phone_number': phoneNumber,
      'user_type': userType.toString(),
      'photo_url': photoUrl,
      'license_number': licenseNumber,
      'vehicle_photo_url': vehiclePhotoUrl,
      'vehicle_capacity': vehicleCapacity,
      'routes': routes,
      'is_available': isAvailable,
    };
  }
}