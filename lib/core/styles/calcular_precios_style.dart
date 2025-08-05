import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CalcularPrecioStyles {
  // Decoración del contenedor
  static BoxDecoration containerDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDarkMode ? AppColors.backgroundDark : AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(isDarkMode ? 0.2 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilo para los textos de los valores (distancia, tiempo, precio)
  static TextStyle valueTextStyle(BuildContext context, {required String type}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color color;
    switch (type) {
      case 'distance':
        color = isDarkMode ? AppColors.primary.withOpacity(0.9) : AppColors.primary;
        break;
      case 'time':
        color = isDarkMode ? AppColors.secondary : Colors.orange[700]!;
        break;
      case 'price':
        color = isDarkMode ? AppColors.confirmed.withOpacity(0.9) : Colors.green[700]!;
        break;
      default:
        color = isDarkMode ? AppColors.white : Colors.black;
    }
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 16,
        );
  }

  // Estilo para las etiquetas (Distancia, Tiempo, Precio)
  static TextStyle labelTextStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: isDarkMode ? AppColors.grey : AppColors.grey.withOpacity(0.7),
          fontSize: 13,
        );
  }

  // Colores para los íconos
  static Color iconColor(BuildContext context, {required String type}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case 'distance':
        return isDarkMode ? AppColors.primary.withOpacity(0.9) : AppColors.primary;
      case 'time':
        return isDarkMode ? AppColors.secondary : Colors.orange[700]!;
      case 'price':
        return isDarkMode ? AppColors.confirmed.withOpacity(0.9) : Colors.green[700]!;
      default:
        return isDarkMode ? AppColors.grey : AppColors.primary;
    }
  }

  // Padding del contenedor
  static const EdgeInsets containerPadding = EdgeInsets.symmetric(vertical: 18, horizontal: 8);

  // Tamaño de los íconos
  static const double iconSize = 32;

  // Espaciado entre elementos
  static const double spacing = 6;
}