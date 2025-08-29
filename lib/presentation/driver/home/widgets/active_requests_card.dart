import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/models/trip_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveRequestsCard extends StatefulWidget {
  final List<TripRequest> requests;
  final Function(TripRequest) onRequestAccepted;
  final Function(TripRequest) onRequestRejected;
  
  const ActiveRequestsCard({
    super.key,
    required this.requests,
    required this.onRequestAccepted,
    required this.onRequestRejected,
  });

  @override
  State<ActiveRequestsCard> createState() => _ActiveRequestsCardState();
}

class _ActiveRequestsCardState extends State<ActiveRequestsCard> {
  final Map<String, bool> _expandedStates = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = true; // <-- NUEVO

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    // Simula carga de datos (reemplaza esto por tu lógica real de carga)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TripRequest> _filterRequests() {
    if (_searchQuery.isEmpty) return widget.requests;
    return widget.requests.where((request) {
      final origen = request.origen?.nombre.toLowerCase() ?? 'desconocido';
      final destino = request.destino?.nombre.toLowerCase() ?? 'desconocido';
      final origenProvincia = request.origen?.provincia.toLowerCase() ?? 'desconocido';
      final destinoProvincia = request.destino?.provincia.toLowerCase() ?? 'desconocido';
      return origen.contains(_searchQuery) || 
             destino.contains(_searchQuery) || 
             origenProvincia.contains(_searchQuery) || 
             destinoProvincia.contains(_searchQuery);
    }).toList();
  }

  Color _getTaxiTypeColor(String taxiType) {
    return taxiType == 'colectivo' ? Colors.orange : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _filterRequests();
    return Column(
      children: [
        _buildSearchBar(),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (filteredRequests.isEmpty)
          _buildEmptyState()
        else
          _buildRequestsList(filteredRequests),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por origen o destino...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes activas',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Las nuevas solicitudes aparecerán aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<TripRequest> filteredRequests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(TripRequest request) {
    final isExpanded = _expandedStates[request.id] ?? false;
    final isHighlighted = _searchQuery.isNotEmpty &&
        (request.origen?.nombre.toLowerCase().contains(_searchQuery) == true ||
         request.destino?.nombre.toLowerCase().contains(_searchQuery) == true);
    
    return Card(
      elevation: isHighlighted ? 4 : 2,
      shadowColor: isHighlighted ? AppColors.primary.withOpacity(0.3) : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isHighlighted ? AppColors.primary.withOpacity(0.7) : Colors.grey[200]!,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      color: isHighlighted ? AppColors.primary.withOpacity(0.05) : Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedStates[request.id!] = !isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(request),
                  const SizedBox(height: 16),
                  _buildMetadata(request, isExpanded),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: isExpanded ? _buildDetails(request) : const SizedBox.shrink(),
          ),
          _buildActions(request),
        ],
      ),
    );
  }

  Widget _buildHeader(TripRequest request) {
    return Row(
      children: [
        // Icono tipo taxi con texto debajo
        Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getTaxiTypeColor(request.taxiType).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                request.taxiType == 'colectivo' ? Icons.group : Icons.directions_car,
                color: _getTaxiTypeColor(request.taxiType),
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              request.taxiType == 'colectivo' ? 'Colectivo' : 'Privado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getTaxiTypeColor(request.taxiType),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.origen?.nombre ?? 'Origen desconocido',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.arrow_downward, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.destino?.nombre ?? 'Destino desconocido',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Precio
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '\$${request.price?.toStringAsFixed(0) ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(TripRequest request, bool isExpanded) {
    return Row(
      children: [
        // Personas
        _buildMetadataChip(
          icon: Icons.person,
          text: '${request.cantidadPersonas}',
          color: Colors.purple,
        ),
        
        const SizedBox(width: 10),
        
        // Fecha
        _buildMetadataChip(
          icon: Icons.schedule,
          text: DateFormat('dd/MM HH:mm').format(request.tripDate.toLocal()),
          color: Colors.teal,
        ),
        
        const Spacer(),
        
        // Indicador de expansión
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(TripRequest request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
          
          // Dirección
          _buildDetailItem(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: request.contact?.address?.isNotEmpty == true 
                ? request.contact!.address! 
                : 'No disponible',
            iconColor: Colors.red,
          ),
          
          const SizedBox(height: 16),
          
          // Información adicional
          if (request.contact?.extraInfo?.isNotEmpty == true)
            _buildDetailItem(
              icon: Icons.info_outline,
              label: 'Información adicional',
              value: request.contact!.extraInfo!,
              iconColor: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon, 
            size: 20, 
            color: iconColor ?? Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(TripRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => widget.onRequestRejected(request),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                backgroundColor: Colors.red[50],
                side: BorderSide(color: Colors.red[200]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.onRequestAccepted(request),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Aceptar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}