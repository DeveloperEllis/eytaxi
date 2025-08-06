import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class EarningsCard extends StatelessWidget {
  final double todayEarnings;
  final double weekEarnings;
  final int completedTrips;

  const EarningsCard({
    super.key,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.completedTrips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEarningItem('Hoy', '\$${todayEarnings.toStringAsFixed(2)}', Icons.today),
            _buildEarningItem('Semana', '\$${weekEarnings.toStringAsFixed(2)}', Icons.date_range),
            _buildEarningItem('Viajes', '$completedTrips', Icons.directions_car),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}