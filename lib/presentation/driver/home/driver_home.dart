import 'dart:async';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/core/widgets/messages/logs.dart';
import 'package:eytaxi/presentation/driver/confirm_trips/confirm_trips_page.dart';
import 'package:eytaxi/presentation/driver/home/driver_dashboard.dart';
import 'package:eytaxi/presentation/driver/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _statusAnimationController;
  late Animation<double> _statusAnimation;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _statusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _statusAnimation = CurvedAnimation(
      parent: _statusAnimationController,
      curve: Curves.easeInOut,
    );

    // Sincronizar animación con el estado inicial de isOnline
    final driverState = Provider.of<ThemeNotifier>(context, listen: false);
    if (driverState.isOnline) {
      _statusAnimationController.forward();
    } else {
      _statusAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _statusAnimationController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Buenos días';
    } else if (hour >= 12 && hour < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny;
    } else if (hour >= 12 && hour < 19) {
      return Icons.wb_sunny_outlined;
    } else {
      return Icons.nights_stay;
    }
  }

  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error al cerrar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleDriverStatus(bool value) async {
    try {
      await Provider.of<ThemeNotifier>(context, listen: false).toggleDriverStatus(value);
      if (value) {
        _statusAnimationController.forward();
        LogsMessages.showOnlineDriver(context, "Estás online para recibir viajes");
      } else {
        _statusAnimationController.reverse();
        LogsMessages.showOfflineDriver(context, "Estás offline y no recibirás viajes");
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el estado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = Provider.of<ThemeNotifier>(context);
    final List<Widget> screens = [
      const DriverDashboard(),
      const ConfirmTripsPage(),
      const Center(child: Text('Historial')), // Placeholder
      const ProfilePage(), // Placeholder
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      appBar: _buildAppBar(driverState),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeNotifier driverState) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverState.driverName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      _getGreetingIcon(),
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildOnlineStatusWidget(driverState),
        const SizedBox(width: 8),
        _buildLogoutButton(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildOnlineStatusWidget(ThemeNotifier driverState) {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _toggleDriverStatus(!driverState.isOnline),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: driverState.isOnline ? Colors.green : Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (driverState.isOnline ? Colors.green : Colors.grey[400]!)
                      .withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  driverState.isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.logout_rounded,
          color: Colors.grey[700],
          size: 20,
        ),
        onPressed: _handleLogout,
        tooltip: 'Cerrar sesión',
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Inicio'),
              _buildNavItem(1, Icons.directions_car_rounded, 'Viajes'),
              _buildNavItem(2, Icons.history_rounded, 'Historial'),
              _buildNavItem(3, Icons.person_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavBarTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}