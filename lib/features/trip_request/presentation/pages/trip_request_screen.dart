import 'package:eytaxi/features/trip_request/presentation/pages/widgets/taxi_form.dart';
import 'package:flutter/material.dart';

class TripRequestScreen extends StatelessWidget {
  const TripRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: TaxiForm(),
      ),
    );
  }
}