import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriversPage extends StatefulWidget {
  final String title;
  final bool onlyPending;

  const DriversPage({super.key, required this.title, this.onlyPending = false});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<dynamic> drivers = [];
  List<dynamic> filteredDrivers = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDrivers();
    _searchController.addListener(_filterDrivers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDrivers() async {
    final client = Supabase.instance.client;

    // Trae los datos de drivers y user_profiles relacionados
    var query = client
        .from('drivers')
        .select('''
          id, driver_status, 
          user:user_profiles!drivers_id_fkey(nombre, apellidos, phone_number )
        ''');

    if (widget.onlyPending) {
      query = query.eq('driver_status', 'pending');
    }

    final data = await query;
    setState(() {
      drivers = data as List;
      filteredDrivers = drivers;
      loading = false;
    });
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDrivers = drivers.where((drv) {
        final nombre = (drv['user']?['nombre'] ?? '').toString().toLowerCase();
        final apellidos = (drv['user']?['apellidos'] ?? '').toString().toLowerCase();
        final phone = (drv['user']?['phone_number'] ?? '').toString().toLowerCase();
        return nombre.contains(query) ||
            apellidos.contains(query) ||
            phone.contains(query);
      }).toList();
    });
  }

  Future<void> approveDriver(String id) async {
    await Supabase.instance.client
        .from('drivers')
        .update({'driver_status': 'approved'}).eq('id', id);
    fetchDrivers();
  }

  Future<void> blockDriver(String id) async {
    await Supabase.instance.client
        .from('drivers')
        .update({'driver_status': 'blocked'}).eq('id', id);
    fetchDrivers();
  }

  Future<void> deleteDriver(String id) async {
    await Supabase.instance.client
        .from('drivers')
        .delete()
        .eq('id', id);
    fetchDrivers();
  }

  void editDriver(dynamic driver) {
    // Aquí puedes mostrar un dialog o navegar a una pantalla de edición
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar conductor'),
        content: Text('Aquí puedes implementar la edición para ${driver['user']?['nombre'] ?? ''} ${driver['user']?['apellidos'] ?? ''}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar conductor',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredDrivers.isEmpty
                      ? const Center(child: Text('No hay conductores encontrados.'))
                      : ListView.builder(
                          itemCount: filteredDrivers.length,
                          itemBuilder: (context, index) {
                            final drv = filteredDrivers[index];
                            final nombre = drv['user']?['nombre'] ?? '';
                            final apellidos = drv['user']?['apellidos'] ?? '';
                            final email = drv['email'] ?? '';
                            final phone = drv['phone_number'] ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.person, color: Colors.green),
                                title: Text("$nombre $apellidos"),
                                subtitle: Text("Email: $email\nTel: $phone\nEstado: ${drv['driver_status']}"),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Editar',
                                      onPressed: () => editDriver(drv),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Eliminar',
                                      onPressed: () => deleteDriver(drv['id']),
                                    ),
                                    if (widget.onlyPending) ...[
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text("Aprobar"),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () => approveDriver(drv['id']),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.block, size: 18),
                                        label: const Text("Bloquear"),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => blockDriver(drv['id']),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
