import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/constants/supabaseApi.dart';
import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
    url: SupabaseApi.url,
    anonKey: SupabaseApi.anonkey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier()..loadDriverStatus()..loadDriverName(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp.router(
      title: 'Taxi Booking',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.value,
      routerConfig: AppRoutes.router,
    );
  }
}
