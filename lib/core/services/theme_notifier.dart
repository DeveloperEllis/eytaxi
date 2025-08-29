import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String prefKey = 'theme_mode';
  bool _isOnline = false;
  String _driverName = 'Conductor';
  List<String> _routers = [];

  bool get isOnline => _isOnline;
  String get driverName => _driverName;
  List<String> get routers => _routers;
  ThemeMode get value => _currentTheme;

  ThemeMode _currentTheme = ThemeMode.light;

  ThemeNotifier() {
    _loadFromPrefs();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        loadDriverStatus();
        loadDriverName();
        loadDriverRoutes();
      }
    });
  }

  Future<void> loadDriverStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      print('Authenticated user for driver status: ${user?.id}');
      if (user != null) {
        final response =
            await Supabase.instance.client
                .from('drivers')
                .select('is_available')
                .eq('id', user.id)
                .single();

        _isOnline = response['is_available'] ?? false;
        notifyListeners();
      } else {
        print('No authenticated user for driver status');
      }
    } catch (e) {
      print('Error loading driver status: $e');
    }
  }


  Future<void> loadDriverName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response =
            await Supabase.instance.client
                .from('user_profiles')
                .select('nombre')
                .eq('id', user.id)
                .single();

        _driverName = response['nombre'] ?? 'Conductor';
        notifyListeners();
      } else {
        print('No authenticated user for driver name');
      }
    } catch (e) {
      print('Error loading driver name: $e');
    }
  }

  Future<void> loadDriverRoutes() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      print('Authenticated user for driver routes: ${user?.id}');
      if (user != null) {
        final response =
            await Supabase.instance.client
                .from('drivers')
                .select('routes')
                .eq('id', user.id)
                .single();

        _routers = List<String>.from(response['routes'] ?? []);
        print('Loaded driver routes: $_routers');
        notifyListeners();
      } else {
        print('No authenticated user for driver routes');
      }
    } catch (e) {
      print('Error loading driver routes: $e');
    }
  }

  Future<void> toggleDriverStatus(bool value) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('drivers')
          .update({'is_available': value})
          .eq('id', user.id);

      _isOnline = value;
      notifyListeners();
    } catch (e) {
      print('Error updating driver status: $e');
      throw Exception('Error al actualizar el estado');
    }
  }

  void toggleTheme() {
    _currentTheme =
        _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(prefKey);

    if (themeIndex != null) {
      if (themeIndex == 0) {
        _currentTheme = ThemeMode.light;
      } else if (themeIndex == 1) {
        _currentTheme = ThemeMode.dark;
      } else {
        _currentTheme = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = 0;
    if (_currentTheme == ThemeMode.light) {
      themeIndex = 0;
    } else if (_currentTheme == ThemeMode.dark) {
      themeIndex = 1;
    } else {
      themeIndex = 2;
    }
    await prefs.setInt(prefKey, themeIndex);
  }
}
