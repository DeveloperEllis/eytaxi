import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/constants/fcmtoken.dart';
import 'package:eytaxi/core/constants/supabaseApi.dart';
import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase solo si no existe ninguna app
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB7S5IpWuSN9GUGWEmpLJI6oZv8NbmEElM",
        authDomain: "taxibookingcuba.firebaseapp.com",
        projectId: "taxibookingcuba",
        storageBucket: "taxibookingcuba.appspot.com",
        messagingSenderId: "230009861369",
        appId: "1:230009861369:web:2f6d7bfe7a6caacb249e28",
        measurementId: "G-EE8XPE8X3Y",
      ),
    );
  }else{
    await Firebase.initializeApp();
    await Fcmtoken().setupFCM();
  }
  

  // Inicializar easy_localization
  await EasyLocalization.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(url: SupabaseApi.url, anonKey: SupabaseApi.anonkey);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // Español
      ],
      path: 'assets/translations', // Carpeta de traducciones
      fallbackLocale: const Locale('es'),
      child: ChangeNotifierProvider(
        create:
            (_) =>
                ThemeNotifier()
                  ..loadDriverStatus()
                  ..loadDriverName(),
        child: const MyApp(),
      ),
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

      // Configuración para easy_localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
