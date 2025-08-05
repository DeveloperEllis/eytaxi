import 'package:eytaxi/core/styles/calcular_precios_style.dart';
import 'package:flutter/material.dart';

class CalcularPrecioWidget extends StatelessWidget {
  final double? distanciaKm;
  final double? tiempoMin;
  final double? precio;

  const CalcularPrecioWidget({
    Key? key,
    required this.distanciaKm,
    required this.tiempoMin,
    required this.precio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: CalcularPrecioStyles.containerDecoration(context),
        padding: CalcularPrecioStyles.containerPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.alt_route,
                  color: CalcularPrecioStyles.iconColor(
                    context,
                    type: 'distance',
                  ),
                  size: CalcularPrecioStyles.iconSize,
                ),
                const SizedBox(height: CalcularPrecioStyles.spacing),
                Text(
                  '${distanciaKm?.toStringAsFixed(1) ?? '--'} km',
                  style: CalcularPrecioStyles.valueTextStyle(
                    context,
                    type: 'distance',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Distancia',
                  style: CalcularPrecioStyles.labelTextStyle(context),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  color: CalcularPrecioStyles.iconColor(context, type: 'time'),
                  size: CalcularPrecioStyles.iconSize,
                ),
                const SizedBox(height: CalcularPrecioStyles.spacing),
                Text(
                  '${tiempoMin?.toStringAsFixed(0) ?? '--'} min',
                  style: CalcularPrecioStyles.valueTextStyle(
                    context,
                    type: 'time',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tiempo',
                  style: CalcularPrecioStyles.labelTextStyle(context),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attach_money,
                  color: CalcularPrecioStyles.iconColor(context, type: 'price'),
                  size: CalcularPrecioStyles.iconSize,
                ),
                const SizedBox(height: CalcularPrecioStyles.spacing),
                Text(
                  '\$${precio?.toStringAsFixed(2) ?? '--'}',
                  style: CalcularPrecioStyles.valueTextStyle(
                    context,
                    type: 'price',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Precio',
                  style: CalcularPrecioStyles.labelTextStyle(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
