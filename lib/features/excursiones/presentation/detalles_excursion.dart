import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/features/excursiones/presentation/widgets/contact_widget.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ExcursionDetallePage extends StatelessWidget {
  final Map<String, dynamic> excursion;
  const ExcursionDetallePage({super.key, required this.excursion});

  // Helper method para obtener texto según idioma
  String _getLocalizedText(BuildContext context, String fieldPrefix) {
    final currentLanguage = context.locale.languageCode;
    final key = '${fieldPrefix}_$currentLanguage';
    return excursion[key] ?? excursion['${fieldPrefix}_es'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDarkMode),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(context, isDarkMode),
                _buildDetailsSection(context, isDarkMode),
                _buildDescriptionSection(context, isDarkMode),
                const SizedBox(height: 100), // Espacio para el bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomReservationBar(context, isDarkMode),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (excursion['imagen_url'] != null)
              Image.network(
                excursion['imagen_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorImage(isDarkMode),
              )
            else
              _buildErrorImage(isDarkMode),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
          size: 50,
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        _getLocalizedText(context, 'titulo'),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isDarkMode) {
    final ubicacion = excursion['ubicacion'];
    final duracion = excursion['duracion'];
    final horaSalida = excursion['hr_salida'];

    // Si no hay información, no mostrar la sección
    if ((ubicacion == null || ubicacion.toString().isEmpty) && 
        (duracion == null || duracion.toString().isEmpty) && 
        (horaSalida == null || horaSalida.toString().isEmpty)) {
      return const SizedBox.shrink();
    }

    List<Widget> details = [];

    if (ubicacion != null && ubicacion.toString().isNotEmpty) {
      details.add(_buildDetailChip(Icons.location_on, ubicacion.toString(), isDarkMode));
    }
    
    if (duracion != null && duracion.toString().isNotEmpty) {
      details.add(_buildDetailChip(Icons.schedule, '$duracion', isDarkMode));
    }
    
    if (horaSalida != null && horaSalida.toString().isNotEmpty) {
      details.add(_buildDetailChip(Icons.departure_board, horaSalida.toString(), isDarkMode));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: details,
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, bool isDarkMode) {
    final descripcion = _getLocalizedText(context, 'descripcion');
    if (descripcion.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'descripcion'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomReservationBar(BuildContext context, bool isDarkMode) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'total'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${excursion['precio']}',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showReservationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'reservar'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // 90% del ancho de pantalla
        ),
        child: ReservationFormDialog(excursion: excursion),
      ),
    ),    );
  }
}