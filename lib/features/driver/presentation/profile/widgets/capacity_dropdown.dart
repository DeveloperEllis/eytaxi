import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CapacityDropdown extends StatelessWidget {
  final int? selectedCapacity;
  final ValueChanged<int?> onChanged;
  final List<int> capacityOptions;

  const CapacityDropdown({
    super.key,
    required this.selectedCapacity,
    required this.onChanged,
    required this.capacityOptions,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedCapacity,
      decoration: InputDecoration(
        labelText: 'Capacidad del vehículo',
        prefixIcon: Icon(Icons.people, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: capacityOptions.map((int capacity) {
        return DropdownMenuItem<int>(
          value: capacity,
          child: Text('$capacity pasajeros'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value <= 0) {
          return 'Seleccione la capacidad del vehículo';
        }
        return null;
      },
    );
  }
}
