import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class ImprovedRoutesSelector extends StatelessWidget {
  final List<String> selectedRoutes;
  final void Function(String, bool) onUpdateRoutes;

  const ImprovedRoutesSelector({
    super.key,
    required this.selectedRoutes,
    required this.onUpdateRoutes,
  });

  @override
  Widget build(BuildContext context) {
    final routes = [
      {
        'name': 'oriente',
        'description': 'Santiago, Granma, Guantánamo, Las Tunas, Holguín',
        'icon': Icons.east,
      },
      {
        'name': 'centro',
        'description':
            'Villa Clara, Cienfuegos, Sancti Spíritus, Ciego de Ávila, Camagüey',
        'icon': Icons.center_focus_strong,
      },
      {
        'name': 'occidente',
        'description':
            'La Habana, Matanzas, Pinar del Río, Artemisa, Mayabeque',
        'icon': Icons.west,
      },
    ];

    return Column(
      children: routes.map((route) {
        final isSelected = selectedRoutes.contains(route['name']);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onUpdateRoutes(route['name'] as String, !isSelected),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      route['icon'] as IconData,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            route['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}