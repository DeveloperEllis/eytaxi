import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/presentation/common/information_screen.dart';
import 'package:eytaxi/presentation/passengers/excursion/excursion_tab.dart';
import 'package:eytaxi/presentation/passengers/trip_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void  _showLanguageMenu(BuildContext context, Offset position) async {
    final translator = GoogleTranslator();
    final selected = await showMenu<Locale>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(value: const Locale('es'), child: const Text('Español')),
        PopupMenuItem(value: const Locale('en'), child: const Text('English')),
      ],
    );

    if (selected != null) {
      context.setLocale(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Pikera'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTapDown:
                (details) => _showLanguageMenu(context, details.globalPosition),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.language),
            ),
          ),
          IconButton(
            onPressed: () => themeNotifier.toggleTheme(),
            icon: const Icon(Icons.brightness_6),
            tooltip: tr('Cambiar tema'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [TripRequestScreen(), ExcursionTab(), InfoScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_taxi),
            label: tr('taxi'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.landscape),
            label: tr('excursiones'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info_outline),
            label: tr('información'),
          ),
        ],
      ),
    );
  }
}
