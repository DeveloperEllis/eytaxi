import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/features/excursiones/presentation/detalles_excursion.dart';
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
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
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
          _buildDepartureTimeTag(context),
        ],
      ),
    );
  }

  Widget _buildPriceTag(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;      
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
              color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          '\$${excursion['precio']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDepartureTimeTag(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final horaSalida = excursion['hora_salida'] ?? '';
    
    if (horaSalida.isEmpty) return const SizedBox.shrink();
    
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.black.withOpacity(0.7) 
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              horaSalida,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;     
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
          const SizedBox(height: 8),
          _buildDescription(context),
          const SizedBox(height: 14),
          _buildInfoGrid(context),
          const SizedBox(height: 16),
          _buildReserveButton(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;     
    return Text(
      excursion['titulo'] ?? '',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDarkMode ? Colors.white : Colors.black87,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Text(
      excursion['descripcion'] ?? '',
      style: TextStyle(
        fontSize: 14,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    final ubicacion = excursion['ubicacion'] ?? '';
    final duracion = excursion['duracion'] ?? '';
    final horaSalida = excursion['hr_salida'] ?? '';

    return Column(
      children: [
        Row(
          children: [
            if (ubicacion.isNotEmpty)
              Expanded(child: _buildInfoChip(Icons.location_on_outlined, ubicacion)),
            if (ubicacion.isNotEmpty && duracion.isNotEmpty)
              const SizedBox(width: 12),
            if (duracion.isNotEmpty)
              Expanded(child: _buildInfoChip(Icons.schedule_outlined, '$duracion')),
          ],
        ),
        if (horaSalida.isNotEmpty && (ubicacion.isNotEmpty || duracion.isNotEmpty))
          const SizedBox(height: 10),
        if (horaSalida.isNotEmpty)
          Row(
            children: [
              Expanded(child: _buildInfoChip(Icons.departure_board, 'Salida: $horaSalida')),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onReservePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reservar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}