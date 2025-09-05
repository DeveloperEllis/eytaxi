import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/styles/button_style.dart';

class RegisterNavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool loading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLastStep;

  const RegisterNavigationButtons({
    super.key,
    required this.currentStep,
    required this.loading,
    required this.onPrevious,
    required this.onNext,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Anterior'),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: loading ? null : onNext,
                style: AppButtonStyles.elevatedButtonStyle(context).copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(isLastStep ? 'Registrarse' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}