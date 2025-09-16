// regex_utils.dart
class RegexUtils {
  // Expresión regular para correo electrónico
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  // Expresión regular para número de teléfono (formato internacional o local)

  static final RegExp phoneRegex = RegExp(
    r'^\+?\d{8,15}$',
    caseSensitive: false,
  );

  // Expresión regular para contraseña (mínimo 6 caracteres, al menos una letra y un número)
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-+=~`])[A-Za-z\d!@#$%^&*(),.?":{}|<>_\-+=~`]{6,}$',
    caseSensitive: true,
  );

  static final RegExp isValidLicenciaNumber = RegExp(
    r'^[A-Za-z0-9]+$',
    caseSensitive: true,
  );

  // Métodos de validación
}
