import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/presentation/common/information_screen.dart';
import 'package:eytaxi/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eytaxi/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:eytaxi/features/trip_request/presentation/pages/trip_request_screen.dart';
import 'package:eytaxi/features/excursiones/presentation/excursion_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> _showLanguageMenu(BuildContext context, Offset position) async {
    final selected = await showMenu<Locale>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, position.dy, position.dx + 1, position.dy + 1,
      ),
      items: const [
        PopupMenuItem(value: Locale('es'), child: Text('Español')),
        PopupMenuItem(value: Locale('en'), child: Text('English')),
      ],
    );

    if (selected != null) {
      await context.setLocale(selected);
      if (mounted) setState(() {}); // asegura rebuild inmediato del subtree
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: HomeAppBar(
        title: 'Pikera',
        onLanguageMenuRequested: (pos) => _showLanguageMenu(context, pos),
        onToggleTheme: () => themeNotifier.toggleTheme(),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TripRequestScreen(),
          ExcursionTab(),
          InfoScreen(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
