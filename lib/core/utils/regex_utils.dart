// regex_utils.dart
class RegexUtils {
  // Expresión regular para correo electrónico
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  // Expresión regular para número de teléfono (formato internacional o local)
  static final RegExp phoneRegex = RegExp(
    r'^\+?\d{1,4}?[-.\s]?\(?\d{1,3}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}$',
    caseSensitive: false,
  );

  // Expresión regular para contraseña (mínimo 6 caracteres, al menos una letra y un número)
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
    caseSensitive: true,
  );
  static final RegExp isValidLicenciaNumber = RegExp(
    r'^[A-Za-z0-9]+$',
    caseSensitive: true,
  );

  // Métodos de validación
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return passwordRegex.hasMatch(password);
  }
  static bool isValidLicencia(String licencia) {
    return isValidLicenciaNumber.hasMatch(licencia);
  }

}