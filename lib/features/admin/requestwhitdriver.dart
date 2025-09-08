import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsWithResponsesPage extends StatefulWidget {
  const RequestsWithResponsesPage({super.key});

  @override
  State<RequestsWithResponsesPage> createState() => _RequestsWithResponsesPageState();
}

class _RequestsWithResponsesPageState extends State<RequestsWithResponsesPage> {
  List<Map<String, dynamic>> groupedResponses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchResponses();
  }

  Future<void> fetchResponses() async {
    final client = Supabase.instance.client;

    final responses = await client
        .from('driver_responses')
        .select('id, request_id, driver_id, drivers(name), trip_requests(origen, destino)');

    final data = responses as List;

    // Agrupar por trip_request_id
    final Map<int, Map<String, dynamic>> grouped = {};
    for (var r in data) {
      final tripId = r['trip_request_id'] as int;
      grouped.putIfAbsent(tripId, () => {
            'request_id': tripId,
            'origen': r['trip_requests']['origen'],
            'destino': r['trip_requests']['destino'],
            'drivers': [],
          });
      grouped[tripId]!['drivers'].add(r['drivers']['name']);
    }

    setState(() {
      groupedResponses = grouped.values.toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitudes con interesados")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groupedResponses.length,
              itemBuilder: (context, index) {
                final item = groupedResponses[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.directions_car, color: Colors.blue),
                    title: Text("Solicitud #${item['request_id']}"),
                    subtitle: Text("${item['origen']} → ${item['destino']}"),
                    children: [
                      ...item['drivers'].map<Widget>((d) => ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(d),
                          )),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
