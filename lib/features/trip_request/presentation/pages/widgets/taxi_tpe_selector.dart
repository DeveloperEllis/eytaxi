import 'package:easy_localization/easy_localization.dart';
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
          height: 72, // altura ajustada para título + descripción
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
              // Fondo animado que ahora ocupa toda la altura
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: buttonWidth - 8,
                height: double.infinity, // 🔹 ocupa todo el alto
                margin: EdgeInsets.only(
                  left: taxiType == 'colectivo' ? 0 : buttonWidth,
                ),
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
                  // Botón Colectivo
                  Expanded(
                    child: InkWell(
                      onTap: () => onTypeChanged('colectivo'),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: AppColors.primary.withOpacity(0.2),
                      highlightColor: AppColors.primary.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'colectivo'.tr(),
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
                          const SizedBox(height: 2),
                          Text(
                            'vcolectivo'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: taxiType == 'colectivo'
                                      ? AppColors.white.withOpacity(0.9)
                                      : AppColors.grey.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botón Privado
                  Expanded(
                    child: InkWell(
                      onTap: () => onTypeChanged('privado'),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: AppColors.primary.withOpacity(0.2),
                      highlightColor: AppColors.primary.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'privado'.tr(),
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
                          const SizedBox(height: 2),
                          Text(
                            'vprivado'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: taxiType == 'privado'
                                      ? AppColors.white.withOpacity(0.9)
                                      : AppColors.grey.withOpacity(0.6),
                                ),
                          ),
                        ],
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
