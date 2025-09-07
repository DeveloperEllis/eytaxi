import 'package:easy_localization/easy_localization.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class LocationDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LocationDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;     
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'provincia turistica'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderinput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
      ),
      items: items.map((provincia) => 
        DropdownMenuItem(
          value: provincia,
          child: Text(provincia),
        ),
      ).toList(),
      onChanged: onChanged,
      validator: (value) => 
        value == null || value.isEmpty ? 'Seleccione una provincia' : null,
      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87  ,
        fontSize: 16,
      ),
    );
  }
}