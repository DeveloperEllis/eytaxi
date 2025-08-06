import 'package:eytaxi/models/user_model.dart';
import 'package:flutter/material.dart';

class UserTypeSelector extends StatelessWidget {
  final UserType selectedType;
  final Function(UserType) onTypeSelected;

  const UserTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _UserTypeCard(
                title: 'Pasajero',
                icon: Icons.person,
                isSelected: selectedType == UserType.passenger,
                onTap: () => onTypeSelected(UserType.passenger),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _UserTypeCard(
                title: 'Taxista',
                icon: Icons.drive_eta,
                isSelected: selectedType == UserType.driver,
                onTap: () => onTypeSelected(UserType.driver),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}