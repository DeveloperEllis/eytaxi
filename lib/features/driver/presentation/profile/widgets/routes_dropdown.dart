import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RoutesDropdown extends StatelessWidget {
  final Set<String> selectedRoutes;
  final bool viajesLocales;
  final List<String> availableRoutes;
  final Function(String, bool) onRouteChanged;
  final VoidCallback onViajesLocalesToggle;

  const RoutesDropdown({
    super.key,
    required this.selectedRoutes,
    required this.viajesLocales,
    required this.availableRoutes,
    required this.onRouteChanged,
    required this.onViajesLocalesToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.route, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Rutas de operación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Routes checkboxes
          ...availableRoutes.map((route) {
            final isSelected = selectedRoutes.contains(route);
            return CheckboxListTile(
              title: Text(
                route.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                onRouteChanged(route, value ?? false);
              },
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          
          // Divider
          Divider(color: Colors.grey.shade300, height: 1),
          
          // Viajes locales checkbox
          CheckboxListTile(
            title: const Text(
              'Viajes locales',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            subtitle: const Text(
              'Independiente de las rutas principales',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            value: viajesLocales,
            onChanged: (bool? value) {
              onViajesLocalesToggle();
            },
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
