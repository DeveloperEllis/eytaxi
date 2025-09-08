import 'package:flutter/material.dart';

class ExcursionReservationsPage extends StatelessWidget {
  const ExcursionReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservas de Excursiones')),
      body: const Center(
        child: Text('Aquí se mostrarán las reservas de excursiones.'),
      ),
    );
  }
}
