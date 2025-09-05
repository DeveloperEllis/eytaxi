import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/features/auth/utils/register_validators.dart';
import 'package:flutter/material.dart';

class DriverInfo extends StatelessWidget {
  final bool isEditing;
  final Driver? driver;
  final TextEditingController licenseController;
  final Widget capacityDropdown;
  final Widget ciudadOrigenField;
  final Widget routesDropdown;

  const DriverInfo({
    super.key,
    required this.isEditing,
    this.driver,
    required this.licenseController,
    required this.capacityDropdown,
    required this.ciudadOrigenField,
    required this.routesDropdown,
  });

  @override
  Widget build(BuildContext context) {
    if (driver == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drive_eta, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Información del Conductor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isEditing) ...[
              _buildEditableField(
                label: 'Número de licencia',
                controller: licenseController,
                icon: Icons.credit_card,
                validator: (value) => RegisterValidators.validateNonEmpty(value, 'número de licencia'),
              ),
              const SizedBox(height: 16),
              ciudadOrigenField,
              const SizedBox(height: 16),
              capacityDropdown,
              const SizedBox(height: 16),
              routesDropdown,
              const SizedBox(height: 16),
            ] else ...[
              _buildInfoRow(
                icon: Icons.credit_card,
                label: 'Licencia',
                value: driver!.licenseNumber,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.people,
                label: 'Capacidad',
                value: '${driver!.vehicleCapacity} pasajeros',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.route,
                label: 'Rutas',
                value: driver!.routes.isNotEmpty 
                    ? driver!.routes.join(', ')
                    : 'Sin rutas asignadas',
              ),
              if (driver!.viajes_locales) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.local_taxi,
                  label: 'Viajes locales',
                  value: 'Disponible',
                ),
              ],
              if (driver!.origen != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Ciudad de origen',
                  value: '${driver!.origen!.nombre} (${driver!.origen!.codigo})',
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
