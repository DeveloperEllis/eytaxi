import 'package:flutter/material.dart';

class ConfirmTripsPage extends StatefulWidget {
  const ConfirmTripsPage({super.key});

  @override
  _ConfirmTripsPageState createState() => _ConfirmTripsPageState();
}

class _ConfirmTripsPageState extends State<ConfirmTripsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Trips'),
      ),
      body: Center(
        child: Text(
          'This is the Confirm Trips page for drivers.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
