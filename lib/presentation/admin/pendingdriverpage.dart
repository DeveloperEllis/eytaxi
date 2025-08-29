// pages/pending_drivers_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingDriversPage extends StatefulWidget {
  const PendingDriversPage({super.key});

  @override
  State<PendingDriversPage> createState() => _PendingDriversPageState();
}

class _PendingDriversPageState extends State<PendingDriversPage> {
  List<dynamic> pendingDrivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingDrivers();
  }

  Future<void> fetchPendingDrivers() async {
    final client = Supabase.instance.client;
    final response = await client
        .from('drivers')
        .select()
        .eq('driver_status', 'pending');

    setState(() {
      pendingDrivers = response as List;
      isLoading = false;
    });
  }

  Future<void> updateDriverStatus(int id, String newStatus) async {
    final client = Supabase.instance.client;
    await client.from('drivers').update({'driver_status': newStatus}).eq('id', id);
    fetchPendingDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conductores Pendientes')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingDrivers.isEmpty
              ? const Center(child: Text("No hay conductores pendientes"))
              : ListView.builder(
                  itemCount: pendingDrivers.length,
                  itemBuilder: (context, index) {
                    final drv = pendingDrivers[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(drv['name'] ?? "Sin nombre"),
                        subtitle: Text("Teléfono: ${drv['phone'] ?? 'N/A'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => updateDriverStatus(drv['id'], 'approved'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => updateDriverStatus(drv['id'], 'rejected'),
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
