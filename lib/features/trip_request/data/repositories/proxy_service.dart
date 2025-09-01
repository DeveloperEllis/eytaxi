import 'dart:convert';
import 'package:http/http.dart' as http;

class ProxyService {
  static const String baseUrl = "https://proxy-notificaciones-vksp.vercel.app/api";

  static Future<Map<String, dynamic>> crearTrip(String tripId) async {
    final url = Uri.parse("$baseUrl/index");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"tripId": tripId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error: ${response.statusCode} -> ${response.body}");
      }
    } catch (e) {
      throw Exception("Error en la solicitud: $e");
    }
  }
}