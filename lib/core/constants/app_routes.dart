import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/presentation/common/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Importa más pantallas aquí según las vayas creando
final ThemeNotifier themeNotifier = ThemeNotifier();
class AppRoutes {
  static const String home = '/';
  static const String tripAceptedPage = '/trip-acepted';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => HomeScreen(),
      ),

      // Agrega más rutas aquí según lo necesites
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Página no encontrada')),
    ),
  );
}
