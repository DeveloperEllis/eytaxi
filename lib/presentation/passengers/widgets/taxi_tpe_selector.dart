import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class TaxiTypeSelector extends StatelessWidget {
  final String taxiType;
  final ValueChanged<String> onTypeChanged;

  const TaxiTypeSelector({
    super.key,
    required this.taxiType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonWidth = constraints.maxWidth / 2;
        return Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? AppColors.grey.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: buttonWidth - 8,
                height: 40,
                margin: EdgeInsets.only(left: taxiType == 'colectivo' ? 0 : buttonWidth),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        onTypeChanged('colectivo');
                        print('Tapped colectivo');
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: AppColors.primary.withOpacity(0.2),
                      highlightColor: AppColors.primary.withOpacity(0.1),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          'Colectivo',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: taxiType == 'colectivo'
                                    ? AppColors.white
                                    : isDarkMode
                                        ? AppColors.grey
                                        : AppColors.grey.withOpacity(0.7),
                                fontWeight: taxiType == 'colectivo'
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        onTypeChanged('privado');
                        print('Tapped privado');
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: AppColors.primary.withOpacity(0.2),
                      highlightColor: AppColors.primary.withOpacity(0.1),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          'Privado',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: taxiType == 'privado'
                                    ? AppColors.white
                                    : isDarkMode
                                        ? AppColors.grey
                                        : AppColors.grey.withOpacity(0.7),
                                fontWeight: taxiType == 'privado'
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}