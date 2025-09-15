import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:intl/intl.dart';

class TripRequestCardWidget extends StatelessWidget {
  final TripRequest request;
  final VoidCallback onTap;
  final bool showTimeElapsed;

  const TripRequestCardWidget({
    super.key,
    required this.request,
    required this.onTap,
    this.showTimeElapsed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${request.id?.substring(0, 8) ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      _buildTaxiTypeChip(request.taxiType),
                      const SizedBox(width: 8),
                      _buildStatusChip(request.status.name),
                      const SizedBox(width: 8),
                      Text(
                        request.price.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.confirmed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.origen?.nombre ?? 'Origen no especificado',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.destino?.nombre ?? 'Destino no especificado',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.group, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${request.cantidadPersonas} personas',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTripDateTime(request.tripDate, request.taxiType),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  // Mostrar tiempo transcurrido en la esquina inferior derecha
                  if (showTimeElapsed &&
                      request.status.name.toLowerCase() == 'pending')
                    _buildTimeElapsedChip(request.createdAt),
                ],
              ),
              const SizedBox(height: 12),
              if (request.driverId != null)
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'CONDUCTOR ASIGNADO',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxiTypeChip(String taxiType) {
    Color color;
    String label;

    switch (taxiType.toLowerCase()) {
      case 'colectivo':
        color = Colors.purple;
        label = 'Colectivo';
        break;
      case 'privado':
        color = Colors.indigo;
        label = 'Privado';
        break;
      default:
        color = Colors.grey;
        label = taxiType;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final s = status.toLowerCase();
    Color color;
    String label;

    switch (s) {
      case 'pending':
      case 'pendiente':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'accepted':
      case 'aceptado':
        color = Colors.green;
        label = 'Aceptado';
        break;
      case 'started':
      case 'iniciado':
        color = Colors.blue;
        label = 'Iniciado';
        break;
      case 'completed':
      case 'completado':
        color = Colors.teal;
        label = 'Completado';
        break;
      case 'cancelled':
      case 'canceled':
      case 'cancelado':
        color = Colors.red;
        label = 'Cancelado';
        break;
      case 'rejected':
      case 'rechazado':
        color = Colors.grey;
        label = 'Rechazado';
        break;
      default:
        color = Colors.grey;
        // Preserve original with capitalized first letter
        label =
            status.isNotEmpty
                ? '${status[0].toUpperCase()}${status.substring(1)}'
                : status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatTripDateTime(DateTime dateTime, String taxiType) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    if(taxiType == 'colectivo'){
      return '$formattedDate';
    }
    
    return '$formattedDate $formattedTime';
  }

  String _getShortTimeElapsed(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return '<1min';
    }
  }

  Widget _buildTimeElapsedChip(DateTime createdAt) {
    final timeText = _getShortTimeElapsed(createdAt);
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    // Determinar color basado en el tiempo transcurrido
    Color color;
    if (difference.inDays > 2) {
      color = Colors.red.shade600;
    } else if (difference.inDays > 0 || difference.inHours > 12) {
      color = Colors.orange.shade600;
    } else {
      color = Colors.amber.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        timeText,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
