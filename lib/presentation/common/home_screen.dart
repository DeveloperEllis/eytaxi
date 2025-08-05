import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/presentation/common/information_screen.dart';
import 'package:eytaxi/presentation/passengers/excursion/excursion_tab.dart';
import 'package:eytaxi/presentation/passengers/trip_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final List<Widget> _screens = [
      const Center(
        child: Text(
          '🚖 TaxiTab (en desarrollo)',
          style: TextStyle(fontSize: 18),
        ),
      ),
      const Center(
        child: Text(
          '🏝️ ExcursionTab (en desarrollo)',
          style: TextStyle(fontSize: 18),
        ),
      ),

      const Center(
        child: Text(
          '📅 ReservasTab (en desarrollo)',
          style: TextStyle(fontSize: 18),
        ),
      ),
      const InfoScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Pikera'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => themeNotifier.toggleTheme(),
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: [
      TripRequestScreen(),
      ExcursionTab(),
      _screens[3] 
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: 'Taxi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Excursiones',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Información',
          ),
        ],
      ),
    );
  }
}
