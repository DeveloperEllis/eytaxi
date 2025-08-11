import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_constants.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/services/trip_request__service.dart';
import 'package:eytaxi/core/utils/regex_utils.dart';
import 'package:eytaxi/core/widgets/messages/mesages.dart';
import 'package:eytaxi/models/guest_contact_model.dart';
import 'package:eytaxi/models/reserva_excusion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ContactMethod { email, whatsapp, phone }

class ReservationFormDialog extends StatefulWidget {
  final Map<String, dynamic> excursion;
  final VoidCallback? onReservationConfirmed;

  const ReservationFormDialog({
    super.key,
    required this.excursion,
    this.onReservationConfirmed,
  });

  @override
  State<ReservationFormDialog> createState() => _ReservationFormDialogState();
}

class _ReservationFormDialogState extends State<ReservationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _contactoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _datosExtrasController = TextEditingController();

  DateTime? _selectedDate;
  ContactMethod _selectedContactMethod = ContactMethod.whatsapp;
  bool _isLoading = false;
  String _selectedCountryCode = '+53';
  bool _includeGuide = false; // New state for guide checkbox

  TripRequestService _service = TripRequestService();

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _contactoController.dispose();
    _direccionController.dispose();
    _datosExtrasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDarkMode),
            const SizedBox(height: 20),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(isDarkMode),
                      const SizedBox(height: 16),
                      _buildQuantityField(isDarkMode),
                      const SizedBox(height: 16),
                      _buildDateField(isDarkMode),
                      const SizedBox(height: 16),
                      _buildContactMethodSection(isDarkMode),
                      const SizedBox(height: 16),
                      _buildContactField(isDarkMode),
                      const SizedBox(height: 16),
                      _buildGuideCheckbox(isDarkMode),
                      const SizedBox(height: 16),
                      _buildAddressField(isDarkMode),
                      const SizedBox(height: 16),
                      _buildExtraDataField(isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reservar Excursión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.excursion['titulo'] ?? 'Excursión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                '\$${widget.excursion['precio']}${_includeGuide ? ' + \$12' : ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Nombre completo *', isDarkMode),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nombreController,
          decoration: _getInputDecoration(
            'Ingresa tu nombre completo',
            isDarkMode,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length < 2) {
              return 'El nombre debe tener al menos 2 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Cantidad de personas *', isDarkMode),
        const SizedBox(height: 6),
        TextFormField(
          controller: _cantidadController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _getInputDecoration('Número de personas', isDarkMode),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La cantidad es requerida';
            }
            final cantidad = int.tryParse(value);
            if (cantidad == null || cantidad < 1 || cantidad > 50) {
              return 'Ingresa un número válido (1-50)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Fecha de la excursión *', isDarkMode),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDarkMode ? Colors.grey[800] : Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Selecciona una fecha',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _selectedDate != null
                            ? (isDarkMode ? Colors.white : Colors.black87)
                            : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              'La fecha es requerida',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildContactMethodSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Vía de contacto *', isDarkMode),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildContactMethodChip(
                ContactMethod.whatsapp,
                'WhatsApp',
                Icons.message,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildContactMethodChip(
                ContactMethod.email,
                'Email',
                Icons.email,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildContactMethodChip(
                ContactMethod.phone,
                'Teléfono Cuba',
                Icons.phone,
                isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactMethodChip(
    ContactMethod method,
    String label,
    IconData icon,
    bool isDarkDkMode,
  ) {
    final isSelected = _selectedContactMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedContactMethod = method;
          _contactoController.clear();
          if (method != ContactMethod.whatsapp) {
            _selectedCountryCode = '+53';
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary
                  : (isDarkDkMode ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : (isDarkDkMode ? Colors.grey[600]! : Colors.grey[300]!),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    isSelected
                        ? Colors.white
                        : (isDarkDkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactField(bool isDarkMode) {
    String hintText;
    String label;
    TextInputType keyboardType;
    List<TextInputFormatter> inputFormatters = [];

    switch (_selectedContactMethod) {
      case ContactMethod.email:
        hintText = 'ejemplo@correo.com';
        label = 'Email *';
        keyboardType = TextInputType.emailAddress;
        inputFormatters = [FilteringTextInputFormatter.deny(RegExp(r'\s'))];
        break;
      case ContactMethod.whatsapp:
        hintText = '5XXXXXXX';
        label = 'Número de WhatsApp *';
        keyboardType = TextInputType.phone;
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
        ];
        break;
      case ContactMethod.phone:
        hintText = '+53 5XXXXXXX';
        label = 'Número de teléfono *';
        keyboardType = TextInputType.phone;
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
        ];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isDarkMode),
        const SizedBox(height: 6),
        _selectedContactMethod == ContactMethod.whatsapp
            ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountryCode,
                    decoration: _getInputDecoration(
                      'Código',
                      isDarkMode,
                    ).copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items:
                        AppConstants.countryCodes
                            .map(
                              (country) => DropdownMenuItem(
                                value: country['code'],
                                child: Text(
                                  '${country['flag']} ${country['code']}',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountryCode = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un código';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _contactoController,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: _getInputDecoration(hintText, isDarkMode),
                    validator: (value) => _validateContact(value),
                    onChanged:
                        (value) => setState(() {
                          _contactoController.text = value.trim();
                          _contactoController
                              .selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: _contactoController.text.length,
                            ),
                          );
                        }),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ],
            )
            : TextFormField(
              controller: _contactoController,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: _getInputDecoration(hintText, isDarkMode),
              validator: (value) => _validateContact(value),
              onChanged:
                  (value) => setState(() {
                    _contactoController.text = value.trim();
                    _contactoController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _contactoController.text.length),
                    );
                  }),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
      ],
    );
  }

  Widget _buildAddressField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Dirección de recogida *', isDarkMode),
        const SizedBox(height: 6),
        TextFormField(
          controller: _direccionController,
          maxLines: 2,
          decoration: _getInputDecoration(
            'Dirección donde te recogeremos',
            isDarkMode,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección es requerida';
            }
            if (value.trim().length < 10) {
              return 'Proporciona una dirección más detallada';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildExtraDataField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Datos extras (opcional)', isDarkMode),
        const SizedBox(height: 6),
        TextFormField(
          controller: _datosExtrasController,
          maxLines: 3,
          decoration: _getInputDecoration(
            'Comentarios adicionales, necesidades especiales, etc.',
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCheckbox(bool isDarkMode) {
    return Row(
      children: [
        Checkbox(
          value: _includeGuide,
          onChanged: (value) {
            setState(() {
              _includeGuide = value ?? false;
            });
          },
          activeColor: AppColors.primary,
          checkColor: Colors.white,
          side: BorderSide(
            color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
        Expanded(
          child: Text(
            'Incluir guía (+12 USD)',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text, bool isDarkMode) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  InputDecoration _getInputDecoration(String hintText, bool isDarkMode) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Confirmar Reserva',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    switch (_selectedContactMethod) {
      case ContactMethod.email:
        if (!RegexUtils.emailRegex.hasMatch(value)) {
          return 'Ingresa un email válido';
        }
        break;
      case ContactMethod.whatsapp:
        final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
        if (!RegexUtils.phoneRegex.hasMatch(
          _selectedCountryCode + cleanedValue,
        )) {
          return 'Ingresa un número de WhatsApp válido';
        }
        break;
      case ContactMethod.phone:
        if (!RegexUtils.phoneRegex.hasMatch(
          value.replaceAll(RegExp(r'[\s-]'), ''),
        )) {
          return 'Ingresa un número cubano válido';
        }
        break;
    }
    return null;
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular llamada a API
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      //excursion
      String cantidad_personas = _cantidadController.text.trim();
      bool guia = _includeGuide;
      DateTime fecha = _selectedDate!;
      double precio =
          (!_includeGuide)
              ? widget.excursion['precio']
              : widget.excursion['precio'] + 12;

      //contact
      String name = _nombreController.text.trim();
      String method = _selectedContactMethod.toString();
      String contacto =
          _selectedContactMethod == ContactMethod.whatsapp
              ? '$_selectedCountryCode${_contactoController.text.trim()}'
              : _contactoController.text.trim();
      String address = _direccionController.text.trim();
      String extra_info = _datosExtrasController.text.trim();

      GuestContact guestContact = new GuestContact(
        name: name,
        method: method,
        contact: contacto,
        address: address,
        extraInfo: extra_info,
      );

      ReservaExc reservexc = new ReservaExc(
        precio: precio,
        exc_id: widget.excursion['id'],
        cantidad_personas: cantidad_personas,
        fecha: fecha,
        incluir_guia: guia,
      );

      await _service.createExcursionRequest(reservexc, guestContact);
      Navigator.pop(context);

      widget.onReservationConfirmed?.call();
      CustomDialog.showSuccessDialog(
        context,
        'Reserva enviada exitosamente',
        'Le contactaremos lo antes posible',
      );

    }
  }

  // Método estático para mostrar el dialog
  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> excursion, {
    VoidCallback? onReservationConfirmed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ReservationFormDialog(
            excursion: excursion,
            onReservationConfirmed: onReservationConfirmed,
          ),
    );
  }
}
