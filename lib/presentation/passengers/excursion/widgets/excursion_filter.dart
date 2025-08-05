import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ExcursionFilter extends StatelessWidget {
  final void Function(String) onFilterChanged;
  final void Function(RangeValues) onPriceRangeChanged;
  final RangeValues currentPriceRange;
  final String currentFilter;

  const ExcursionFilter({
    super.key,
    required this.onFilterChanged,
    required this.onPriceRangeChanged,
    required this.currentPriceRange,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Filtros',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Icon(Icons.filter_list, color: AppColors.primary),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rango de precio:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              RangeSlider(
                values: currentPriceRange,
                min: 0,
                max: 500,
                divisions: 50,
                labels: RangeLabels(
                  '\$${currentPriceRange.start.round()}',
                  '\$${currentPriceRange.end.round()}',
                ),
                onChanged: onPriceRangeChanged,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.2),
              ),
              const Divider(),
              _buildFilterChips(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        _buildFilterChip('Todos', ''),
        _buildFilterChip('Playas', 'playa'),
        _buildFilterChip('Ciudades', 'ciudad'),
        _buildFilterChip('Naturaleza', 'naturaleza'),
        _buildFilterChip('Cultura', 'cultura'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: currentFilter == value,
      onSelected: (_) => onFilterChanged(value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: currentFilter == value ? AppColors.primary : Colors.black87,
        fontWeight: currentFilter == value ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: currentFilter == value ? AppColors.primary : Colors.grey,
      ),
    );
  }
}