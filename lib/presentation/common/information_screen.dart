import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // URLs para redes sociales y WhatsApp
  static const String whatsappUrl = 'https://wa.me/+5358408409?text=¡Hola!%20Quiero%20más%20información%20sobre%20TaxiCuba';
  static const String instagramUrl = 'https://www.instagram.com/taxicuba';
  static const String twitterUrl = 'https://x.com/taxicuba';
  static const String facebookUrl = 'https://www.facebook.com/taxicuba';

  // Función para abrir URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header con logo y título
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [AppColors.primary.withOpacity(0.8), AppColors.secondary.withOpacity(0.8)]
                        : [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Logo mejorado
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Título y subtítulo
                    Text(
                      'TaxiCuba',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conectando Cuba, un viaje a la vez',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(onPressed: () {
                      AppRoutes.router.go('/admin');
                    }, child: const Text('Admin')),
                    // Sección de redes sociales mejorada
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(
                          icon:  FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          onTap: () => _launchUrl(whatsappUrl),
                          tooltip: 'Contactar por WhatsApp',
                        ),
                        const SizedBox(width: 20),
                        _buildSocialIcon(
                          icon: FontAwesomeIcons.instagram,
                          color: Colors.purple,
                          onTap: () => _launchUrl(instagramUrl),
                          tooltip: 'Instagram',
                        ),
                        const SizedBox(width: 20),
                        _buildSocialIcon(
                          icon: FontAwesomeIcons.twitter,
                          color: Colors.blue,
                          onTap: () => _launchUrl(twitterUrl),
                          tooltip: 'Twitter/X',
                        ),
                        const SizedBox(width: 20),
                        _buildSocialIcon(
                          icon: FontAwesomeIcons.facebook,
                          color: Colors.blueAccent,
                          onTap: () => _launchUrl(facebookUrl),
                          tooltip: 'Facebook',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Contacto mejorado
                    GestureDetector(
                      onTap: () => _launchUrl(whatsappUrl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '+53 5123 4567',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenido principal
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  
                  // Sección ¿Qué es TaxiCuba?
                  _buildSectionTitle(
                    context: context,
                    title: '¿Qué es TaxiCuba?',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'TaxiCuba es la aplicación líder en Cuba que conecta de manera segura y eficiente a viajeros con taxistas profesionales. Facilitamos todo tipo de transporte en la isla: viajes locales, excursiones turísticas, viajes personalizados y traslados especiales. Tu medio de transporte ideal, cuando lo necesites.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Características principales
                  _buildSectionTitle(
                    context: context,
                    title: 'Características principales',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  
                  // Grid de características
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final features = [
                       
                        {'icon': Icons.local_taxi, 'title': 'Viajes locales', 'desc': 'Transporte rápido y confiable'},
                        {'icon': Icons.landscape, 'title': 'Excursiones turísticas', 'desc': 'Descubre Cuba con expertos'},
                        {'icon': Icons.route, 'title': 'Viajes personalizados', 'desc': 'Rutas adaptadas a tus necesidades'},
                        {'icon': Icons.payment, 'title': 'Tarifas transparentes', 'desc': 'Precios justos conocidos antes'},
                        {'icon': Icons.star_rate, 'title': 'Sistema de calificaciones', 'desc': 'Conductores verificados'},
                        {'icon': Icons.schedule, 'title': 'Disponibilidad 24/7', 'desc': 'Siempre disponible'},
                      ];
                      
                      return _buildFeatureCard(
                        context: context,
                        icon: features[index]['icon'] as IconData,
                        title: features[index]['title'] as String,
                        description: features[index]['desc'] as String,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sección para taxistas
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [AppColors.primary.withOpacity(0.9), AppColors.secondary.withOpacity(0.9)]
                            : [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¿Eres taxista?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Únete a nuestra plataforma y aumenta tus ingresos ofreciendo todo tipo de servicios: viajes locales, excursiones turísticas, traslados al aeropuerto y viajes personalizados por toda Cuba',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            AppRoutes.router.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Registrarse como Taxista',
                                style: TextStyle(
                                  fontSize: 14,
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
                  _buildSectionTitle(
                    context: context,
                    title: 'Beneficios para taxistas',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  
                  // Grid de beneficios
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final benefits = [
                        {'emoji': '💰', 'title': 'Aumenta tus ingresos'},
                        {'emoji': '🚗', 'title': 'Viajes locales y excursiones'},
                        {'emoji': '✈️', 'title': 'Traslados aeropuerto'},
                        {'emoji': '🗺️', 'title': 'Rutas personalizadas'},
                        {'emoji': '📱', 'title': 'Gestión fácil desde móvil'},
                        {'emoji': '⭐', 'title': 'Construye tu reputación'},
                        {'emoji': '🛡️', 'title': 'Pagos seguros garantizados'},
                      ];
                      
                      return _buildBenefitCard(
                        context: context,
                        emoji: benefits[index]['emoji'] as String,
                        title: benefits[index]['title'] as String,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer mejorado
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TaxiCuba - Tu transporte ideal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.white : AppColors.black,
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
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          '© ${DateTime.now().year} TaxiCuba. Todos los derechos reservados.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required BuildContext context,
    required String title,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: FaIcon(icon, color: Colors.white, size: 30,),
        ),
      ),
    );
  }
}