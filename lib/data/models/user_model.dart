enum UserType { admin, driver, passenger }

abstract class User {
  final String? id;
  final String email;
  final String nombre;
  final String apellidos;
  final String phoneNumber;
  final UserType userType;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellidos,
    required this.phoneNumber,
    required this.userType,
    this.photoUrl,
  });
}