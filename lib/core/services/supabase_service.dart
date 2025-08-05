import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  late final SupabaseClient client;

  SupabaseService._internal() {
    client = SupabaseClient(
      'https://shkalldjbvnepyfixvtm.supabase.co', // Reemplaza con tu URL Supabase
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNoa2FsbGRqYnZuZXB5Zml4dnRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxMDk3NzMsImV4cCI6MjA2MDY4NTc3M30.5AKIwnCkao1aZZ9pWsGcuXtvOBUgoml5kHyudBZcl00',                 // Reemplaza con tu clave pública
    );
  }

  // Puedes agregar métodos comunes aquí, ejemplo:



  // Más métodos para actualizar, eliminar, etc.
}
