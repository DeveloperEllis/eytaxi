import 'package:eytaxi/data/models/user_model.dart';
import 'package:eytaxi/features/trip_request/presentation/pages/widgets/location_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/utils/regex_utils.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverInfoStep extends StatelessWidget {
  final TextEditingController licenseController;
  final TextEditingController vehicleCapacityController;
  final TextEditingController munOrigenController;
  final Ubicacion? municipio;
  final Function(Ubicacion?) onMunicipioSelected;
  final bool viajesLocales;
  final VoidCallback onToggleViajesLocales;
  final List<String> selectedRoutes;
  final Function(String, bool) onUpdateRoutes;
  final Widget Function() buildImprovedRoutesSelector;

  const DriverInfoStep({
    super.key,
    required this.licenseController,
    required this.vehicleCapacityController,
    required this.munOrigenController,
    required this.municipio,
    required this.onMunicipioSelected,
    required this.viajesLocales,
    required this.onToggleViajesLocales,
    required this.selectedRoutes,
    required this.onUpdateRoutes,
    required this.buildImprovedRoutesSelector,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Información del Conductor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          LocationAutocomplete(
            controller: munOrigenController,
            labelText: 'Municipio de Origen',
            selectedLocation: municipio,
            onSelected: onMunicipioSelected,
            user:  UserType.driver,
            // Pasa aquí tu servicio y tipo de usuario si es necesario
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: licenseController,
            decoration: AppInputDecoration.buildInputDecoration(
              context: context,
              labelText: 'Número de Licencia',
              prefixIcon: Icons.badge,
              hintText: 'Ej: ABC123456',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su número de licencia';
              }
              if (!RegexUtils.isValidLicencia(value)) {
                return 'Ingrese un número de licencia válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: DropdownButtonFormField<String>(
              value: vehicleCapacityController.text.isEmpty
                  ? null
                  : vehicleCapacityController.text,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Capacidad del Vehículo',
                prefixIcon: Icons.airline_seat_recline_normal,
              ),
              isExpanded: true,
              hint: const Text(
                'Seleccione asientos',
                overflow: TextOverflow.ellipsis,
              ),
              items: List.generate(16, (index) => (index + 1).toString())
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        '$value pasajeros',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  vehicleCapacityController.text = newValue;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione la capacidad del vehículo';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Icon(Icons.route, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Rutas de Operación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Seleccione las regiones donde desea operar:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          // Viajes locales
          GestureDetector(
            onTap: onToggleViajesLocales,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: viajesLocales ? AppColors.primary : Colors.grey[300]!,
                  width: viajesLocales ? 2 : 1,
                ),
                color:
                    viajesLocales ? AppColors.primary.withOpacity(0.1) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: viajesLocales ? AppColors.primary : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Viajes locales',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: viajesLocales ? AppColors.primary : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selecciona si opera en rutas locales o dentro de la Provincia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    viajesLocales
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: viajesLocales ? AppColors.primary : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // Selector de rutas
          buildImprovedRoutesSelector(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
