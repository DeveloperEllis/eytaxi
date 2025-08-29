import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eytaxi/models/trip_request_model.dart';


class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  
  void _launchContact(String metodo, String contacto) async {
    final lower = metodo.toLowerCase();
    if (lower.contains('whatsapp')) {
      final url = 'https://wa.me/$contacto';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else if (lower.contains('mail') || lower.contains('correo')) {
      final url = 'mailto:$contacto';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else if (lower.contains('tel') || lower.contains('llama') || lower.contains('phone')) {
      final url = 'tel:$contacto';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }
  List<TripRequest> pendingRequests = [];
  String searchOrigen = '';
  String searchDestino = '';
  bool isLoading = false;
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    setState(() => isLoading = true);
    final client = Supabase.instance.client;
    final response = await client
        .from('trip_requests')
        .select(
          '*,origen:origen_id(*),destino:destino_id(*), contact:guest_contacts!contact_id(id,name,method,contact,address,extra_info)',
        )
        .eq('status', 'pending');
    final List<TripRequest> requests =
        (response as List)
            .map((json) => TripRequest.fromJson(json as Map<String, dynamic>))
            .toList();
    setState(() {
      pendingRequests = requests;
      isLoading = false;
    });
  }

  List<TripRequest> get filteredRequests {
    return pendingRequests.where((req) {
      final origen = req.origen?.nombre.toLowerCase() ?? '';
      final destino = req.destino?.nombre.toLowerCase() ?? '';
      final provinciaOrigen = req.origen?.provincia.toLowerCase() ?? '';
      final provinciaDestino = req.destino?.provincia.toLowerCase() ?? '';
      final matchOrigen =
          searchOrigen.isEmpty ||
          origen.contains(searchOrigen.toLowerCase()) ||
          provinciaOrigen.contains(searchOrigen.toLowerCase());
      final matchDestino =
          searchDestino.isEmpty ||
          destino.contains(searchDestino.toLowerCase()) ||
          provinciaDestino.contains(searchDestino.toLowerCase());
      return matchOrigen && matchDestino;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Pendientes'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body:
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final req = filteredRequests[index];
                  final isExpanded = _expandedStates[req.id!] ?? false;
                  final nombre = req.contact?.name ?? '';
                  final direccion = req.contact?.address ?? '';
                  final metodo = req.contact?.method ?? '';
                  final contact = req.contact?.contact ?? '';
                  final extraInfo = req.contact?.extraInfo ?? '';
                  final descripcion = nombre + direccion + metodo + contact + extraInfo;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isExpanded ? Colors.blue.shade400 : Colors.grey.shade200,
                        width: isExpanded ? 1.5 : 1,
                      ),
                    ),
                    elevation: isExpanded ? 6 : 2,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(Icons.local_taxi, color: Colors.blue, size: 26),
                          ),
                          title: Text(
                            '${req.origen?.nombre ?? ''} (${req.origen?.provincia ?? ''})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '→ ${req.destino?.nombre ?? ''} (${req.destino?.provincia ?? ''})',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: Colors.blue.shade400,
                            ),
                            onPressed: () => setState(() => _expandedStates[req.id!] = !isExpanded),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          alignment: Alignment.topCenter,
                          child: isExpanded
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                                          const SizedBox(width: 6),
                                          Text('ID: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
                                          Text('${req.id ?? ''}', style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.people, color: Colors.purple, size: 18),
                                          const SizedBox(width: 6),
                                          Text('Personas: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
                                          Text('${req.cantidadPersonas}', style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, color: Colors.teal, size: 18),
                                          const SizedBox(width: 6),
                                          Text('Fecha: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
                                          Text('${req.tripDate}', style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (descripcion.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.grey.withOpacity(0.13),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Datos de contacto
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.person, color: Colors.blue, size: 20),
                                                          const SizedBox(width: 8),
                                                          Expanded(child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.location_on, color: Colors.teal, size: 20),
                                                          const SizedBox(width: 8),
                                                          Expanded(child: Text(direccion, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.phone_android, color: Colors.green, size: 20),
                                                          const SizedBox(width: 8),
                                                          Text(metodo, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                          const SizedBox(width: 8),
                                                          Expanded(child: Text(contact, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                                          const SizedBox(width: 8),
                                                          Expanded(child: Text(extraInfo, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Icono lateral derecho según método de contacto
                                                Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child: Builder(
                                                    builder: (context) {
                                                      Widget icono;
                                                      if (metodo.toLowerCase().contains('whatsapp')) {
                                                        icono = IconButton(
                                                          onPressed: () => _launchContact(metodo, contact),
                                                          icon: FaIcon(FontAwesomeIcons.whatsapp, size: 36, color: AppColors.confirmed,),
                                                        );
                                                      } else if (metodo.toLowerCase().contains('mail') || metodo.toLowerCase().contains('correo')) {
                                                        icono = IconButton(
                                                          icon: const Icon(Icons.email, color: Colors.red, size: 36),
                                                          tooltip: 'Enviar correo',
                                                          onPressed: () => _launchContact(metodo, contact),
                                                        );
                                                      } else if (metodo.toLowerCase().contains('tel') || metodo.toLowerCase().contains('llama') || metodo.toLowerCase().contains('phone')) {
                                                        icono = IconButton(
                                                          icon: const Icon(Icons.phone, color: Colors.blue, size: 36),
                                                          tooltip: 'Llamar',
                                                          onPressed: () => _launchContact(metodo, contact),
                                                        );
                                                      } else {
                                                        icono = IconButton(
                                                          icon: const Icon(Icons.contact_mail, color: Colors.grey, size: 36),
                                                          tooltip: 'Contactar',
                                                          onPressed: () => _launchContact(metodo, contact),
                                                        );
                                                      }
                                                      return icono;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      // Botón Asignar driver
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // Acción para asignar driver aquí
                                          },
                                          icon: const Icon(Icons.person_add_alt_1),
                                          label: const Text('Asignar driver'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade700,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
