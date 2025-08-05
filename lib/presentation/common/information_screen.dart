import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con logo y título
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        size: 50,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TaxiCuba',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                    ),
                    Text(
                      'Conectando Cuba, un viaje a la vez',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sección principal de información
              Text(
                '¿Qué es TaxiCuba?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TaxiCuba es la aplicación líder en Cuba que conecta de manera segura y eficiente a viajeros con taxistas profesionales. Facilitamos todo tipo de transporte en la isla: viajes locales, excursiones turísticas, viajes personalizados y traslados especiales. Tu medio de transporte ideal, cuando lo necesites.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Características principales
              Text(
                'Características principales:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildFeatureItem(
                context,
                Icons.location_on,
                'Ubicación en tiempo real',
                'Seguimiento GPS preciso para mayor seguridad',
              ),
              _buildFeatureItem(
                context,
                Icons.local_taxi,
                'Viajes locales',
                'Transporte rápido y confiable dentro de la ciudad',
              ),
              _buildFeatureItem(
                context,
                Icons.landscape,
                'Excursiones turísticas',
                'Descubre los mejores lugares de Cuba con guías expertos',
              ),
              _buildFeatureItem(
                context,
                Icons.route,
                'Viajes personalizados',
                'Rutas adaptadas a tus necesidades específicas',
              ),
              _buildFeatureItem(
                context,
                Icons.payment,
                'Tarifas transparentes',
                'Precios justos conocidos antes del viaje',
              ),
              _buildFeatureItem(
                context,
                Icons.star_rate,
                'Sistema de calificaciones',
                'Encuentra los mejores conductores verificados',
              ),
              _buildFeatureItem(
                context,
                Icons.schedule,
                'Disponibilidad 24/7',
                'Tu transporte cuando lo necesites, día y noche',
              ),
              
              const SizedBox(height: 40),
              
              // Sección para taxistas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode 
                        ? [AppColors.primary, AppColors.secondary]
                        : [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.drive_eta,
                      size: 48,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Eres taxista?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Únete a nuestra plataforma y aumenta tus ingresos ofreciendo todo tipo de servicios: viajes locales, excursiones turísticas, traslados al aeropuerto y viajes personalizados por toda Cuba',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar a la pantalla de login/registro de taxistas
                        _navigateToTaxistLogin(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Registrarse como Taxista',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Beneficios para taxistas
              Text(
                'Beneficios para taxistas:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildBenefitItem(context, '💰', 'Aumenta tus ingresos'),
              _buildBenefitItem(context, '🚗', 'Viajes locales y excursiones'),
              _buildBenefitItem(context, '✈️', 'Traslados aeropuerto'),
              _buildBenefitItem(context, '🗺️', 'Rutas personalizadas'),
              _buildBenefitItem(context, '📱', 'Gestión fácil desde tu móvil'),
              _buildBenefitItem(context, '⭐', 'Construye tu reputación'),
              _buildBenefitItem(context, '🛡️', 'Pagos seguros garantizados'),
              
              const SizedBox(height: 40),
              
              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'TaxiCuba - Tu transporte ideal',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Facilitando todos tus viajes por Cuba',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? AppColors.accent : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String emoji, String benefit) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Text(
            benefit,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTaxistLogin(BuildContext context) {
    // Aquí puedes navegar a tu pantalla de login/registro de taxistas
    // Ejemplo:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => TaxistLoginScreen()),
    // );
    
    // Mientras tanto, mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirigiendo al registro de taxistas...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}