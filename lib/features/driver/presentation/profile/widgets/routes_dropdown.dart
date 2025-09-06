import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class RoutesDropdown extends StatelessWidget {
  final List<String> availableRoutes;
  final Set<String> selectedRoutes;
  final bool viajesLocales;
  final Function(String, bool) onRouteChanged;
  final Function(bool) onViajesLocalesChanged;
  final TextEditingController routesController;

  const RoutesDropdown({
    super.key,
    required this.availableRoutes,
    required this.selectedRoutes,
    required this.viajesLocales,
    required this.onRouteChanged,
    required this.onViajesLocalesChanged,
    required this.routesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.route, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rutas de operación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rutas principales (Oriente, Occidente, Centro)
              ...availableRoutes.map((route) {
                return CheckboxListTile(
                  title: Text(
                    route.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: selectedRoutes.contains(route),
                  onChanged: (bool? value) {
                    onRouteChanged(route, value ?? false);
                    // Actualizar el controller para mantener compatibilidad
                    routesController.text = selectedRoutes.join(', ');
                  },
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),

              // Separador visual
              if (availableRoutes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 8),
              ],

              // Checkbox para Viajes Locales
              CheckboxListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VIAJES LOCALES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Rutas locales dentro de la provincia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                value: viajesLocales,
                onChanged: (bool? value) {
                  onViajesLocalesChanged(value ?? false);
                },
                activeColor: Colors.green,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
        if (selectedRoutes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seleccionadas: ${selectedRoutes.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
