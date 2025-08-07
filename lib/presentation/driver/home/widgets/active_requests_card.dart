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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
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
      final origen = request.origen?.nombre?.toLowerCase() ?? 'desconocido';
      final destino = request.destino?.nombre?.toLowerCase() ?? 'desconocido';
      return origen.contains(_searchQuery) || destino.contains(_searchQuery);
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
        if (filteredRequests.isEmpty)
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
  print('Filtered Requests in _buildRequestsList: ${filteredRequests.map((r) => 'ID=${r.id}, Contact=${r.contact?.address}, ExtraInfo=${r.contact?.extraInfo}').toList()}');
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
        (request.origen?.nombre?.toLowerCase().contains(_searchQuery) == true ||
            request.destino?.nombre?.toLowerCase().contains(_searchQuery) == true 
            );
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isHighlighted ? AppColors.primary.withOpacity(0.5) : Colors.grey[200]!,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      color: isHighlighted ? AppColors.primary.withOpacity(0.05) : Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedStates[request.id!] = !isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(request),
                  const SizedBox(height: 12),
                  _buildMetadata(request, isExpanded),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildDetails(request),
          _buildActions(request),
        ],
      ),
    );
  }

  Widget _buildHeader(TripRequest request) {
    return Row(
      children: [
        // Icono tipo taxi
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTaxiTypeColor(request.taxiType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            request.taxiType == 'colectivo' ? Icons.group : Icons.directions_car,
            color: _getTaxiTypeColor(request.taxiType),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${request.origen?.nombre ?? 'Origen desconocido'}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.arrow_downward, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${request.destino?.nombre ?? 'Destino desconocido'}',
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
        Text(
          '\$${request.price?.toStringAsFixed(0) ?? 'N/A'}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(TripRequest request, bool isExpanded) {
    return Row(
      children: [
        // Personas
        Icon(Icons.person, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '${request.cantidadPersonas}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        
        const SizedBox(width: 16),
        
        // Fecha
        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          DateFormat('dd/MM HH:mm').format(request.tripDate.toLocal()),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        
        const SizedBox(width: 16),
        
        // Tipo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getTaxiTypeColor(request.taxiType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            request.taxiType == 'colectivo' ? 'Colectivo' : 'Privado',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getTaxiTypeColor(request.taxiType),
            ),
          ),
        ),
        
        const Spacer(),
        
        // Indicador de expansión
        Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          size: 20,
          color: Colors.grey[500],
        ),
      ],
    );
  }

 Widget _buildDetails(TripRequest request) {
  print('Contact en _buildDetails: ${request.contact}');
  print('Address en _buildDetails: ${request.contact?.address}');
  print('ExtraInfo en _buildDetails: ${request.contact?.extraInfo}');
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey[200]),
        const SizedBox(height: 12),
        
        _buildDetailItem(
          icon: Icons.location_on_outlined,
          label: 'Dirección',
          value: request.contact?.address?.isNotEmpty == true ? request.contact!.address! : 'No disponible',
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[25],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => widget.onRequestRejected(request),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Rechazar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onRequestAccepted(request),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}