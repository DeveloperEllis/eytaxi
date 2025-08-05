import 'dart:developer';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/enum/Trip_enum.dart';
import 'package:eytaxi/core/services/supabase_service.dart';
import 'package:eytaxi/core/services/trip_request__service.dart';
import 'package:eytaxi/core/styles/button_style.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/widgets/messages/mesages.dart';
import 'package:eytaxi/models/guest_contact_model.dart';
import 'package:eytaxi/presentation/passengers/widgets/pickup_dialog.dart';
import 'package:eytaxi/models/trip_request_model.dart';
import 'package:eytaxi/models/ubicacion_model.dart';
import 'package:eytaxi/presentation/passengers/widgets/calcular_precio.dart';
import 'package:eytaxi/presentation/passengers/widgets/locatio_autocomplete.dart';
import 'package:eytaxi/presentation/passengers/widgets/taxi_tpe_selector.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaxiForm extends StatefulWidget {
  const TaxiForm({super.key});

  @override
  State<TaxiForm> createState() => _TaxiFormState();
}

class _TaxiFormState extends State<TaxiForm> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();
  TripRequestService service = TripRequestService();

  String _taxiType = 'colectivo';
  Ubicacion? _origen;
  Ubicacion? _destino;
  int _personas = 1;
  DateTime? _fechaHora;

  double? _precio;
  double? _distanciaKm;
  double? _tiempoMin;

  bool _precioCalculado = false;
  bool _camposEditados = false;
  bool _loading = false;

  final TextEditingController _origenCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();

  void _resetPrecio() {
    setState(() {
      _precio = null;
      _distanciaKm = null;
      _tiempoMin = null;
      _precioCalculado = false;
      _camposEditados = true;
    });
  }

  Future<void> _calcularPrecio() async {
    if (_origen == null || _destino == null) {
      _snack('Por favor seleccione origen y destino válidos');
      return;
    }

    setState(() => _loading = true);
    final data = await service.calculateReservationDetails(
      _origen!.id,
      _destino!.id,
    );

    if (data != null) {
      final precioBase = double.tryParse(data['precio'].toString()) ?? 0.0;
      final distanciaKm = double.tryParse(data['distancia_km'].toString()) ?? 0.0;
      final tiempoMin = double.tryParse(data['tiempo_min'].toString()) ?? 0.0;

      final precioFinal = _taxiType == 'colectivo'
          ? (precioBase / 4) * _personas
          : (_personas <= 4 ? precioBase : (precioBase / 4) * _personas);

      setState(() {
        _precio = precioFinal;
        _distanciaKm = distanciaKm;
        _tiempoMin = tiempoMin;
        _precioCalculado = true;
        _camposEditados = false;
        _loading = false;
      });
    } else {
      _snack('Error al calcular el precio');
      setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _selectFechaHora() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaHora ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      if (_taxiType == 'privado') {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_fechaHora ?? DateTime.now()),
        );

        if (time != null) {
          setState(() {
            _fechaHora = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            _resetPrecio();
          });
        }
      } else {
        setState(() {
          _fechaHora = DateTime(date.year, date.month, date.day);
          _resetPrecio();
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _origenCtrl.clear();
      _destinoCtrl.clear();
      _taxiType = 'colectivo';
      _origen = null;
      _destino = null;
      _personas = 1;
      _fechaHora = null;
      _precio = null;
      _distanciaKm = null;
      _tiempoMin = null;
      _precioCalculado = false;
      _camposEditados = false;
      _loading = false;
    });
  }

  Future<void> _enviarSolicitud() async {
    if (_formKey.currentState!.validate() && _fechaHora != null) {
      if (_taxiType == 'privado' && (_fechaHora!.hour == 0 && _fechaHora!.minute == 0)) {
        _snack('Seleccione una hora válida para taxi privado');
        return;
      }

      if (!_precioCalculado) {
        _calcularPrecio();
        return;
      }

      final result = await PickupDialog().show(context);
      if (result == null) return;

      final trip = TripRequest(
        driverId: null,
        origenId: _origen!.id,
        destinoId: _destino!.id,
        taxiType: _taxiType,
        cantidadPersonas: _personas,
        tripDate: _fechaHora!,
        status: TripStatus.pending,
        price: _precio,
        distanceKm: _distanciaKm,
        estimatedTimeMinutes: _tiempoMin?.toInt(),
        createdAt: DateTime.now(),
      );

      final guestcontact = GuestContact(
        name: result['name'],
        method: result['method'],
        contact: result['contact'],
        address: result['address'],
        extraInfo: result['extra_info'],
      );

      await service.createTripRequest(trip, guestcontact );

      if (mounted) {
        CustomDialog.showSuccessDialog(context, 'Éxito', 'La operación se completó correctamente.');
        _resetForm();
      }
    } else {
      _snack('Complete todos los campos requeridos');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TaxiTypeSelector(
            taxiType: _taxiType,
            onTypeChanged: (type) {
              setState(() {
                _taxiType = type;
                _fechaHora = null;
                _resetPrecio();
              });
            },
          ),
          const SizedBox(height: 24),
          LocationAutocomplete(
            controller: _origenCtrl,
            labelText: 'Origen',
            selectedLocation: _origen,
            onSelected: (Ubicacion? selection) {
              setState(() {
                _origen = selection;
                _resetPrecio();
              });
            },
            supabaseService: _supabaseService,
          ),
          const SizedBox(height: 16),
          LocationAutocomplete(
            controller: _destinoCtrl,
            labelText: 'Destino',
            selectedLocation: _destino,
            onSelected: (Ubicacion? selection) {
              setState(() {
                _destino = selection;
                _resetPrecio();
              });
            },
            supabaseService: _supabaseService,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _personas,
                  decoration: AppInputDecoration.buildStandardInputDecoration(
                    context: context,
                    labelText: 'Personas',
                  ),
                  items: List.generate(
                    16,
                    (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}')),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _personas = value!;
                      _resetPrecio();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectFechaHora,
                  child: InputDecorator(
                    decoration: AppInputDecoration.buildStandardInputDecoration(
                      context: context,
                      labelText: _taxiType == 'colectivo' ? 'Fecha' : 'Fecha y hora',
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fechaHora == null
                                ? 'Seleccionar'
                                : (_taxiType == 'colectivo'
                                    ? '${_fechaHora!.day}/${_fechaHora!.month}/${_fechaHora!.year}'
                                    : '${_fechaHora!.day}/${_fechaHora!.month}/${_fechaHora!.year} ${_fechaHora!.hour}:${_fechaHora!.minute.toString().padLeft(2, '0')}'),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: _fechaHora == null
                                      ? (isDarkMode ? AppColors.grey : AppColors.grey.withOpacity(0.7))
                                      : (isDarkMode ? AppColors.white : Colors.black),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const CircularProgressIndicator(color: AppColors.primary),
          if (_precioCalculado && _precio != null && !_loading)
            CalcularPrecioWidget(
              distanciaKm: _distanciaKm,
              tiempoMin: _tiempoMin,
              precio: _precio,
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: _precioCalculado
                  ? AppButtonStyles.confirmButtonStyle(context)
                  : AppButtonStyles.primaryButtonStyle(context),
              onPressed: _enviarSolicitud,
              child: Text(!_precioCalculado
                  ? 'Calcular Precio'
                  : (_camposEditados ? 'Recalcular' : 'Confirmar')),
            ),
          ),
        ],
      ),
    );
  }
}