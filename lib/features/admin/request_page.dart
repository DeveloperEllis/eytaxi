import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsPage extends StatefulWidget {
  final String title;
  final bool onlyPending;
  final bool onlyAccepted;

  const RequestsPage({
    super.key,
    required this.title,
    this.onlyPending = false,
    this.onlyAccepted = false,
  });

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<dynamic> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final client = Supabase.instance.client;

    var query = client.from('trip_requests').select();

    if (widget.onlyPending) {
      query = query.eq('status', 'pending');
    }
    if (widget.onlyAccepted) {
      query = query.eq('status', 'accepted');
    }

    final data = await query;
    setState(() {
      requests = data as List;
      loading = false;
    });
  }

  Future<void> deleteRequest(int id) async {
    await Supabase.instance.client.from('trip_requests').delete().eq('id', id);
    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.blue),
                    title: Text("Solicitud #${req['id']} - ${req['origen']} → ${req['destino']}"),
                    subtitle: Text("Estado: ${req['status']}"),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            // TODO: Abrir formulario para editar
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteRequest(req['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
