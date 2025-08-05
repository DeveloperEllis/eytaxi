import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TextStyles {
  static const Color primaryColor = AppColors.primary;
  static const Color whiteColor = Colors.white;
  static const Color backgroundColor = AppColors.background;
  static const Color borderInputColor = AppColors.borderinput;
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.black);

  static TextStyle taxiTypeButtonStyleSelected(bool isSelected) {
    return TextStyle(
      color: isSelected ? whiteColor : Colors.grey[700],
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
    );
  }
}
