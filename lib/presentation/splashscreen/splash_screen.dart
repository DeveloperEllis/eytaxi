import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<String> getUserHomePath() async {
    const String home = AppRoutes.home;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return home;

      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('user_type')
          .eq('id', user.id)
          .single();

      final userType = response['user_type'] as String?;
      
      if (userType == 'driver') {
        // Check driver status
        final driverResponse = await Supabase.instance.client
            .from('drivers')
            .select('driver_status')
            .eq('id', user.id)
            .maybeSingle();

        final status = driverResponse?['driver_status'] as String?;
        
        switch (status?.toLowerCase()) {
          case 'approved':
            return AppRoutes.driverHome;
          case 'rejected':
            return AppRoutes.rejectedDriver;
          case 'pending':
          default:
            return AppRoutes.pendingdriver;
        }
      }

      return home; // For passengers
    } catch (e) {
      debugPrint('Error in _getUserHomePath: $e');
      return AppRoutes.login; // Default to login on error
    }
  }
  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    final path = await getUserHomePath();
    context.go(path); // Usar context.go en lugar de Navigator
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // App Name
                    Text(
                      'Pikera',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tagline
                    Text(
                      'Conectamos pasajeros con taxistas en Cuba',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
