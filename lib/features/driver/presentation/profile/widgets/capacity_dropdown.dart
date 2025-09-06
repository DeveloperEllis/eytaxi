import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class CapacityDropdown extends StatelessWidget {
  final int? selectedCapacity;
  final List<int> capacityOptions;
  final Function(int?) onChanged;
  final TextEditingController capacityController;

  const CapacityDropdown({
    super.key,
    required this.selectedCapacity,
    required this.capacityOptions,
    required this.onChanged,
    required this.capacityController,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedCapacity,
      decoration: InputDecoration(
        labelText: 'Capacidad de vehículo',
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
      hint: const Text('Selecciona la capacidad'),
      items: capacityOptions.map((int capacity) {
        return DropdownMenuItem<int>(
          value: capacity,
          child: Text(
            '$capacity ${capacity == 1 ? 'pasajero' : 'pasajeros'}',
          ),
        );
      }).toList(),
      onChanged: (int? newValue) {
        onChanged(newValue);
        if (newValue != null) {
          capacityController.text = newValue.toString();
        }
      },
    );
  }
}
