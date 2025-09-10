import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';

class TripRequestDetailDialog extends StatelessWidget {
  final TripRequest request;
  final Function(TripRequest)? onUpdateStatus;
  final Function(TripRequest)? onAttendRequest;
  final Function(TripRequest)? onDelete;
  final String? customTitle;
  final Widget? customAlert;

  const TripRequestDetailDialog({
    super.key,
    required this.request,
    this.onUpdateStatus,
    this.onAttendRequest,
    this.onDelete,
    this.customTitle,
    this.customAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // Contenido principal del diálogo
          Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con título
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          customTitle ??
                              '#${request.id?.substring(0, 8) ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido scrolleable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Alerta personalizada o por defecto
                        if (customAlert != null) ...[
                          customAlert!,
                          const SizedBox(height: 20),
                        ] else if (request.status.name.toLowerCase() ==
                            'pending') ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Esta solicitud no ha recibido respuesta de ningún taxista o solo ha sido rechazada.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Información del Viaje
                        _buildSectionHeader(
                          '🚕 Información del Viaje',
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Estado:',
                                _getStatusLabel(request.status.name),
                                Icons.info,
                              ),
                              _buildDetailRow(
                                'Tipo de taxi:',
                                _getTaxiTypeLabel(request.taxiType),
                                Icons.local_taxi,
                              ),
                              _buildDetailRow(
                                'Origen:',
                                request.origen?.nombre,
                                Icons.my_location,
                              ),
                              _buildDetailRow(
                                'Destino:',
                                request.destino?.nombre,
                                Icons.location_on,
                              ),
                              _buildDetailRow(
                                'Pasajeros:',
                                request.cantidadPersonas.toString(),
                                Icons.group,
                              ),
                              _buildDetailRow(
                                'Fecha del viaje:',
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(request.tripDate),
                                Icons.calendar_today,
                              ),

                              if (request.price != null)
                                _buildDetailRow(
                                  'Precio:',
                                  '\$${request.price!.toStringAsFixed(2)}',
                                  Icons.attach_money,
                                ),
                            ],
                          ),
                        ),

                        if (request.contact != null) ...[
                          const SizedBox(height: 16),

                          // Información del Cliente
                          _buildSectionHeader(
                            '👤 Información del Cliente',
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  'Nombre:',
                                  request.contact!.name,
                                  Icons.person,
                                ),
                                _buildDetailRow(
                                  'Teléfono:',
                                  request.contact!.contact,
                                  Icons.phone,
                                ),
                                if (request.contact!.method != null)
                                  _buildDetailRow(
                                    'Método de contacto:',
                                    _getContactMethodLabel(
                                      request.contact!.method!,
                                    ),
                                    Icons.contact_phone,
                                  ),
                                if (request.contact!.address?.isNotEmpty ==
                                    true)
                                  _buildDetailRow(
                                    'Dirección:',
                                    request.contact!.address,
                                    Icons.home,
                                  ),
                                if (request.contact!.extraInfo?.isNotEmpty ==
                                    true)
                                  _buildDetailRow(
                                    'Información adicional:',
                                    request.contact!.extraInfo,
                                    Icons.note,
                                  ),
                              ],
                            ),
                          ),
                        ],

                        if (request.driver != null) ...[
                          const SizedBox(height: 16),

                          // Información del Conductor
                          _buildSectionHeader(
                            '🚖 Información del Conductor',
                            Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  'Nombre:',
                                  '${request.driver?.nombre ?? 'N/A'} ${request.driver?.apellidos ?? ''}'.trim(),
                                  Icons.person,
                                ),
                                _buildDetailRow(
                                  'Teléfono:',
                                  request.driver?.phoneNumber ?? 'N/A',
                                  Icons.phone,
                                ),
                                if (request.driver?.licenseNumber != null && request.driver!.licenseNumber.isNotEmpty)
                                  _buildDetailRow(
                                    'Licencia:',
                                    request.driver!.licenseNumber,
                                    Icons.badge,
                                  ),
                                if (request.driver?.vehicleCapacity != null && request.driver!.vehicleCapacity > 0)
                                  _buildDetailRow(
                                    'Capacidad del vehículo:',
                                    request.driver!.vehicleCapacity.toString(),
                                    Icons.directions_car,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer con acciones
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                      // Mostrar "Atender Solicitud" si está pendiente o tiene respuestas de taxistas
                      ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => onAttendRequest!(request),
                          icon: const Icon(Icons.support_agent, size: 10),
                          label: const Text('Atender Solicitud'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],

                      // Mantener "Editar Estado" como opción secundaria
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botón de eliminar posicionado encima del diálogo
          if (onDelete != null)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Solicitud'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta solicitud? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar confirmación
                  Navigator.pop(context); // Cerrar diálogo principal
                  onDelete!(request);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No especificado',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'accepted':
        return 'Aceptado';
      case 'started':
        return 'Iniciado';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      case 'rejected':
        return 'Rechazado';
      default:
        return status;
    }
  }

  String _getTaxiTypeLabel(String taxiType) {
    switch (taxiType.toLowerCase()) {
      case 'colectivo':
        return 'Colectivo (Compartido)';
      case 'privado':
        return 'Privado (Exclusivo)';
      default:
        return taxiType;
    }
  }

  String _getContactMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'phone':
        return 'Teléfono';
      case 'whatsapp':
        return 'WhatsApp';
      case 'telegram':
        return 'Telegram';
      case 'email':
        return 'Correo electrónico';
      case 'sms':
        return 'SMS';
      default:
        return method;
    }
  }
}
