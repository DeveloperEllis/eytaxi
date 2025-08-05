import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/presentation/passengers/excursion/detalles_excursion.dart';
import 'package:flutter/material.dart';

class ExcursionCard extends StatelessWidget {
  final Map<String, dynamic> excursion;
  final VoidCallback onReservePressed;

  const ExcursionCard({
    super.key,
    required this.excursion,
    required this.onReservePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExcursionDetallePage(excursion: excursion),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: excursion['imagen_url'] != null
                ? Image.network(
                    excursion['imagen_url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorImage(context),
                  )
                : _buildErrorImage(context),
          ),
          _buildPriceTag(context),
        ],
      ),
    );
  }

  Widget _buildPriceTag(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;      
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '\$${excursion['precio']}',
          style: TextStyle(
            color:AppColors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;     
    return Container(
      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 6),
          _buildDescription(context),
          const SizedBox(height: 12),
          _buildInfoRow(context),
          const SizedBox(height: 16),
          _buildReserveButton(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;     
    return Text(
      excursion['titulo'] ?? '',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      excursion['descripcion'] ?? '',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      children: [
        _buildInfoChip(Icons.location_on, excursion['ubicacion'] ?? ''),
        const SizedBox(width: 12),
        _buildInfoChip(Icons.access_time, '${excursion['duracion'] ?? ''} hrs'),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReserveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onReservePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reservar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}