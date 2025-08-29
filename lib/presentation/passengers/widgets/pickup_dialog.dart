import 'package:eytaxi/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/styles/button_style.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ContactMethod { email, phone, whatsapp }

class PickupDialog {
  Future<Map<String, String>?> show(BuildContext context) async {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeTransition(
        opacity: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        ),
        child: _PickupDialogContent(),
      ),
    );
  }
}

class _PickupDialogContent extends StatefulWidget {
  @override
  _PickupDialogContentState createState() => _PickupDialogContentState();
}

class _PickupDialogContentState extends State<_PickupDialogContent>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _extraInfoController = TextEditingController();

  ContactMethod? _selectedContactMethod;
  int _currentStep = 0;
  bool _isSubmitting = false;
  String _selectedCountryCode = '+53';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _extraInfoController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _validateAndSubmit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedContactMethod != null &&
            _contactController.text.trim().isNotEmpty &&
            _validateContact(_contactController.text) == null;
      case 2:
        return _addressController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulate a network request
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).pop({
          'name': _nameController.text.trim(),
          'method': _selectedContactMethod.toString().split('.').last,
          'contact': _selectedContactMethod == ContactMethod.whatsapp
              ? '$_selectedCountryCode${_contactController.text.trim()}'
              : _contactController.text.trim(),
          'address': _addressController.text.trim(),
          'extra_info': _extraInfoController.text.trim(),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final double dialogWidth = media.size.width * 0.90;
    final double dialogHeight = media.size.height * 0.90;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: media.size.width * 0.05,
          vertical: media.size.height * 0.05,
        ),
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.backgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(isDarkMode),
              _buildProgressIndicator(),
              Expanded(child: _buildContent()),
              _buildActions(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_taxi, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Solicitar Recogida",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Complete los siguientes pasos",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? AppColors.grey : Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDarkMode ? Colors.white : Colors.black54,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : isActive
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? AppColors.primary : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildPersonalInfoStep(),
          _buildContactStep(),
          _buildAddressStep(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepTitle("¿Cuál es su nombre?", Icons.person),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: AppInputDecoration.buildEmailInputDecoration(
              context: context,
              labelText: 'Nombre completo',
              prefixIcon: Icons.person_outline,
            ).copyWith(
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Por favor ingrese su nombre'
                    : null,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepTitle("¿Cómo prefiere que le contactemos?", Icons.contact_mail),
          const SizedBox(height: 20),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: ContactMethod.values.map((method) {
              final isSelected = _selectedContactMethod == method;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedContactMethod = method;
                      _contactController.clear();
                      if (method != ContactMethod.whatsapp) {
                        _selectedCountryCode = '+53';
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getContactIcon(method),
                          color: isSelected ? AppColors.primary : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _getContactLabel(method),
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : null,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_selectedContactMethod != null)
            AnimatedOpacity(
              opacity: _selectedContactMethod != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _selectedContactMethod == ContactMethod.whatsapp
                  ? Row(
                      children: [
                        // Country code dropdown
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCountryCode,
                            decoration:
                                AppInputDecoration.buildCountryCodeInputDecoration(context: context).copyWith(
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[50],
                                ),
                            items: AppConstants.countryCodes
                                .map(
                                  (country) => DropdownMenuItem(
                                    value: country['code'],
                                    child: Text(
                                      '${country['flag']} ${country['code']}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCountryCode = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // WhatsApp number input
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _contactController,
                            decoration:
                                AppInputDecoration.buildEmailInputDecoration(
                              context: context,
                              labelText: 'Número de WhatsApp',
                              prefixIcon: _getContactIcon(_selectedContactMethod!),
                            ).copyWith(
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[50],
                              helperMaxLines: 2,
                            ),
                            keyboardType:
                                _getKeyboardType(_selectedContactMethod!),
                            validator: _validateContact,
                            onChanged: (value) => setState(() {
                              _contactController.text = value.trim();
                              _contactController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _contactController.text.length),
                              );
                            }),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            inputFormatters:
                                _getInputFormatters(_selectedContactMethod!),
                          ),
                        ),
                      ],
                    )
                  : TextFormField(
                      controller: _contactController,
                      decoration: AppInputDecoration.buildEmailInputDecoration(
                        context: context,
                        labelText: _getContactInputLabel(_selectedContactMethod!),
                        prefixIcon: _getContactIcon(_selectedContactMethod!),
                      ).copyWith(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[50],
                        helperMaxLines: 2,
                      ),
                      keyboardType: _getKeyboardType(_selectedContactMethod!),
                      validator: _validateContact,
                      onChanged: (value) => setState(() {
                        _contactController.text = value.trim();
                        _contactController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _contactController.text.length),
                        );
                      }),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters:
                          _getInputFormatters(_selectedContactMethod!),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepTitle("¿Dónde debemos recogerle?", Icons.location_on),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            decoration: AppInputDecoration.buildEmailInputDecoration(
              context: context,
              labelText: 'Dirección de recogida',
              prefixIcon: Icons.location_on_outlined,
            ).copyWith(
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Por favor ingrese la dirección'
                    : null,
            onChanged: (value) => setState(() {}),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _extraInfoController,
            decoration: AppInputDecoration.buildEmailInputDecoration(
              context: context,
              labelText: 'Información adicional (opcional)',
              prefixIcon: Icons.note_outlined,
            ).copyWith(
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                style: AppButtonStyles.textButtonStyle(context),
                onPressed: _previousStep,
                child: const Text("Anterior"),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              style: AppButtonStyles.primaryButtonStyle(context).copyWith(
                minimumSize: WidgetStateProperty.all(const Size(0, 44)),
              ),
              onPressed: _isCurrentStepValid() && !_isSubmitting ? _nextStep : null,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentStep == 2 ? "Confirmar" : "Siguiente"),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContactIcon(ContactMethod method) {
    switch (method) {
      case ContactMethod.email:
        return FontAwesomeIcons.envelope;
      case ContactMethod.phone:
        return FontAwesomeIcons.phoneFlip;
      case ContactMethod.whatsapp:
        return FontAwesomeIcons.whatsapp;
    }
  }

  String _getContactLabel(ContactMethod method) {
    switch (method) {
      case ContactMethod.email:
        return 'Correo Electrónico';
      case ContactMethod.phone:
        return 'Llamada Dentro de Cuba';
      case ContactMethod.whatsapp:
        return 'WhatsApp';
    }
  }

  String _getContactInputLabel(ContactMethod method) {
    switch (method) {
      case ContactMethod.email:
        return 'correo@ejemplo.com';
      case ContactMethod.phone:
        return 'Número cubano';
      case ContactMethod.whatsapp:
        return 'Número de WhatsApp';
    }
  }

  TextInputType _getKeyboardType(ContactMethod method) {
    switch (method) {
      case ContactMethod.email:
        return TextInputType.emailAddress;
      case ContactMethod.phone:
      case ContactMethod.whatsapp:
        return TextInputType.phone;
    }
  }

  List<TextInputFormatter> _getInputFormatters(ContactMethod method) {
    switch (method) {
      case ContactMethod.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ];
      case ContactMethod.phone:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
          LengthLimitingTextInputFormatter(20),
        ];
      case ContactMethod.whatsapp:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
          LengthLimitingTextInputFormatter(15),
        ];
    }
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    if (_selectedContactMethod == ContactMethod.email) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Ingrese un correo electrónico válido';
      }
    } else if (_selectedContactMethod == ContactMethod.phone) {
      final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (!RegExp(r'^\d{8}$').hasMatch(cleanedValue)) {
        return 'Ingrese un número de teléfono válido (8 dígitos, sin +53)';
      }
    } else if (_selectedContactMethod == ContactMethod.whatsapp) {
      final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (!RegExp(r'^\d{8,15}$').hasMatch(cleanedValue)) {
        return 'Ingrese un número de WhatsApp válido (8-15 dígitos)';
      }
    }
    return null;
  }
}