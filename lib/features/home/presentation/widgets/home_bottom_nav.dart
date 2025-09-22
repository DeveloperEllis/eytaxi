import 'package:easy_localization/easy_localization.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Aumentado de 70 a 80
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Aumentado padding vertical
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.local_taxi,
                label: 'taxi'.tr(),
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.landscape,
                label: 'excursiones'.tr(),
                index: 1,
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.info_outline,
                label: 'informacion'.tr(),
                index: 2,
                isSelected: currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reducido padding
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSelected ? 23 : 22, // Reducido de 24 a 22
              color: isSelected 
                  ?AppColors.primary.withOpacity(0.8)
                  : isDarkMode 
                      ? AppColors.white.withOpacity(0.8)
                      : Colors.grey[600],
            ),
            const SizedBox(height: 2), // Reducido de 4 a 2
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: isSelected ? 13 : 9, // Reducido tamaños de fuente
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.8)
                    : isDarkMode 
                        ?  AppColors.white.withOpacity(0.8)
                        : Colors.grey[600],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
