import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_constants.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // URLs para redes sociales y WhatsApp
  static const String whatsappUrl = 'https://wa.me/${AppConstants.numero_soporte}?text=¡Hola!%20Quiero%20más%20información%20sobre%20TaxiCuba';
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
                        ? [AppColors.primary, AppColors.primary.withOpacity(0.6)]
                        : [AppColors.primary, AppColors.primary.withOpacity(0.6)],
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
                
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          AppConstants.iconoapk,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                    Text(
                      AppConstants.slogan,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    title: AppConstants.appname,
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
                      '${AppConstants.appname} es la aplicación líder en Cuba que conecta de manera segura y eficiente a viajeros con taxistas profesionales. Facilitamos todo tipo de transporte en la isla: viajes locales, excursiones turísticas, viajes personalizados y traslados especiales. Tu medio de transporte ideal, cuando lo necesites.',
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
                  
                  // Lista de características
                  Container(
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
                        _buildFeatureListItem(
                          context: context,
                          icon: Icons.local_taxi,
                          title: 'Viajes locales',
                          description: 'Transporte rápido y confiable en toda Cuba',
                          isDarkMode: isDarkMode,
                          isFirst: true,
                        ),
                        _buildFeatureListItem(
                          context: context,
                          icon: Icons.landscape,
                          title: 'Excursiones turísticas',
                          description: 'Descubre los mejores destinos de Cuba con guías expertos',
                          isDarkMode: isDarkMode,
                        ),
                        _buildFeatureListItem(
                          context: context,
                          icon: Icons.route,
                          title: 'Viajes personalizados',
                          description: 'Rutas completamente adaptadas a tus necesidades específicas',
                          isDarkMode: isDarkMode,
                        ),
                        _buildFeatureListItem(
                          context: context,
                          icon: Icons.payment,
                          title: 'Tarifas transparentes',
                          description: 'Precios justos y conocidos antes de confirmar tu viaje',
                          isDarkMode: isDarkMode,
                        ),
                        _buildFeatureListItem(
                          context: context,
                          icon: Icons.star_rate,
                          title: 'Sistema de calificaciones',
                          description: 'Conductores verificados y evaluados por otros usuarios',
                          isDarkMode: isDarkMode,
                        ),
                        _buildFeatureListItem(
                          context: context,
                          icon: Icons.schedule,
                          title: 'Disponibilidad 24/7',
                          description: 'Servicio disponible las 24 horas, todos los días del año',
                          isDarkMode: isDarkMode,
                          isLast: true,
                        ),
                      ],
                    ),
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
                  
                  // Lista de beneficios organizada
                  Container(
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
                        _buildBenefitListItem(
                          context: context,
                          emoji: '💰',
                          title: 'Aumenta tus ingresos',
                          description: 'Maximiza tus ganancias con múltiples tipos de servicios y tarifas competitivas',
                          isDarkMode: isDarkMode,
                          isFirst: true,
                        ),
                        _buildBenefitListItem(
                          context: context,
                          emoji: '🚗',
                          title: 'Viajes locales y excursiones',
                          description: 'Ofrece tanto transporte urbano como experiencias turísticas completas',
                          isDarkMode: isDarkMode,
                        ),
                        _buildBenefitListItem(
                          context: context,
                          emoji: '✈️',
                          title: 'Traslados aeropuerto',
                          description: 'Conecta con turistas que necesitan transporte desde y hacia el aeropuerto',
                          isDarkMode: isDarkMode,
                        ),
                        _buildBenefitListItem(
                          context: context,
                          emoji: '🗺️',
                          title: 'Rutas personalizadas',
                          description: 'Crea itinerarios únicos según las necesidades específicas de cada cliente',
                          isDarkMode: isDarkMode,
                        ),
                        _buildBenefitListItem(
                          context: context,
                          emoji: '📱',
                          title: 'Gestión fácil desde móvil',
                          description: 'Administra tus servicios, horarios y ganancias desde una aplicación intuitiva',
                          isDarkMode: isDarkMode,
                        ),
                        _buildBenefitListItem(
                          context: context,
                          emoji: '⭐',
                          title: 'Construye tu reputación',
                          description: 'Recibe calificaciones de clientes y construye una reputación sólida',
                          isDarkMode: isDarkMode,
                        ),
                        _buildBenefitListItem(
                          context: context,
                          emoji: '🛡️',
                          title: 'Pagos seguros garantizados',
                          description: 'Sistema de pagos confiable que protege tanto a conductores como a pasajeros',
                          isDarkMode: isDarkMode,
                          isLast: true,
                        ),
                      ],
                    ),
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

  Widget _buildFeatureListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(
            color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDarkMode ? AppColors.grey : AppColors.grey.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Flecha indicadora
         
        ],
      ),
    );
  }

  Widget _buildBenefitListItem({
    required BuildContext context,
    required String emoji,
    required String title,
    required String description,
    required bool isDarkMode,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(
            color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji como icono
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDarkMode ? AppColors.grey : AppColors.grey.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Punto indicador
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}