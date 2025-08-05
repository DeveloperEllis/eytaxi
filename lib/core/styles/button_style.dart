import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class AppButtonStyles {
  // Estilo para botones primarios (ElevatedButton)
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
      elevation: isDarkMode ? 2 : 4,
      shadowColor: isDarkMode ? AppColors.grey.withOpacity(0.3) : Colors.black,
    );
  }

  // Estilo para botones de confirmación (ElevatedButton)
  static ButtonStyle confirmButtonStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.confirmed,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.white,
          ),
      elevation: isDarkMode ? 2 : 4,
      shadowColor: isDarkMode ? AppColors.grey.withOpacity(0.3) : Colors.black,
    );
  }

  // Estilo para botones elevados con énfasis (ElevatedButton)
  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.background,
          ),
      elevation: isDarkMode ? 2 : 4,
      shadowColor: isDarkMode ? AppColors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.2),
    );
  }

  // Estilo para botones de texto (TextButton)
  static ButtonStyle textButtonStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDarkMode ? AppColors.grey.withOpacity(0.5) : AppColors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  // Estilo para botones con borde (OutlinedButton)
  static ButtonStyle outlinedButtonStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(
        color: isDarkMode ? AppColors.grey : AppColors.primary,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
    );
  }
}