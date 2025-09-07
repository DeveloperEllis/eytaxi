import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/services/locations_service.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/styles/locations_autocomplete_style.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/data/models/user_model.dart';
import 'package:flutter/material.dart';

class LocationAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Ubicacion? selectedLocation;
  final ValueChanged<Ubicacion?> onSelected;
  final UserType? user;

  const LocationAutocomplete({
    super.key,
    required this.controller,
    required this.labelText,
    required this.selectedLocation,
    required this.onSelected,
    required this.user,
  });

  @override
  _LocationAutocompleteState createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  LocationsService service = LocationsService();
  // Mantener referencias para sincronizar el controlador interno con el externo
  TextEditingController? _fieldController;
  VoidCallback? _widgetCtrlListener;
  VoidCallback? _fieldCtrlListener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_widgetCtrlListener != null) {
      widget.controller.removeListener(_widgetCtrlListener!);
      _widgetCtrlListener = null;
    }
    if (_fieldController != null && _fieldCtrlListener != null) {
      _fieldController!.removeListener(_fieldCtrlListener!);
      _fieldCtrlListener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Ubicacion>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.length < 2) {
          _isLoadingNotifier.value =
              false; // Desactiva el estado si el texto es muy corto
          return [];
        }
        _isLoadingNotifier.value = true; // Activa el estado de carga al inicio
        try {
          final results = await service.fetchUbicaciones(textEditingValue.text);
          final municipios =
              results.where((item) => item.tipo == 'municipio').toList();
          return (widget.user == UserType.passenger) ? results : municipios;
        } finally {
          _isLoadingNotifier.value = false; // Desactiva el estado al finalizar
        }
      },
      displayStringForOption:
          (Ubicacion option) => '${option.nombre} (${option.codigo})',
      onSelected: (Ubicacion selection) {
        widget.controller.text = '${selection.nombre} (${selection.codigo})';
        widget.onSelected(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Gestionar cambios de controlador interno entre rebuilds
        if (_fieldController != textEditingController) {
          // Quitar listeners previos si existían
          if (_widgetCtrlListener != null) {
            widget.controller.removeListener(_widgetCtrlListener!);
            _widgetCtrlListener = null;
          }
          if (_fieldController != null && _fieldCtrlListener != null) {
            _fieldController!.removeListener(_fieldCtrlListener!);
            _fieldCtrlListener = null;
          }

          _fieldController = textEditingController;

          // Sincronizar inicial: copiar valor externo al campo visible
          if (widget.controller.text != _fieldController!.text) {
            _fieldController!.text = widget.controller.text;
          }

          // Listener: externo -> interno
          _widgetCtrlListener = () {
            if (!mounted || _fieldController == null) return;
            if (widget.controller.text != _fieldController!.text) {
              _fieldController!.text = widget.controller.text;
            }
          };
          widget.controller.addListener(_widgetCtrlListener!);

          // Listener: interno -> externo
          _fieldCtrlListener = () {
            if (widget.controller.text != _fieldController!.text) {
              widget.controller.text = _fieldController!.text;
            }
          };
          _fieldController!.addListener(_fieldCtrlListener!);
        }
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: AppInputDecoration.buildInputDecoration(
            context: context,
            labelText: widget.labelText,
            prefixIcon: Icons.location_on,
            suffixIcon: ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (textEditingController.text.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      textEditingController.clear();
                      widget.controller.clear();
                      widget.onSelected(null);
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          onChanged: (value) {
            if (widget.selectedLocation != null &&
                value !=
                    '${widget.selectedLocation!.nombre} (${widget.selectedLocation!.codigo})') {
              widget.onSelected(null);
            }
          },
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Ingrese ${widget.labelText}'
                      : null,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          textInputAction: TextInputAction.search,
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Ubicacion> onSelected,
        Iterable<Ubicacion> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: LocationAutocompleteStyles.elevation,
            shape: const RoundedRectangleBorder(
              borderRadius: LocationAutocompleteStyles.optionsBorderRadius,
            ),
            child: Container(
              width:
                  MediaQuery.of(context).size.width *
                  LocationAutocompleteStyles.optionsContainerWidthFactor,
              decoration: LocationAutocompleteStyles.optionsContainerDecoration(
                context,
              ),
              child: ListView.builder(
                padding: LocationAutocompleteStyles.optionsPadding,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Ubicacion option = options.elementAt(index);
                  return ListTile(
                    leading: Icon(
                      LocationAutocompleteStyles.getIconForUbicacion(option),
                      color: LocationAutocompleteStyles.optionIconColor(
                        context,
                      ),
                    ),
                    title: Text(
                      option.nombre,
                      style: LocationAutocompleteStyles.optionTitleStyle(
                        context,
                      ),
                    ),
                    subtitle: Text(
                      '${option.tipo} · ${option.provincia}',
                      style: LocationAutocompleteStyles.optionSubtitleStyle(
                        context,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
