import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class StorageService {
  final SupabaseClient _supabase;

  StorageService(this._supabase);

  Future<String?> uploadImage({
    required dynamic imageData,
    required String userId,
    required String type,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$userId/$fileName';
      final String bucket = type == 'profile' ? 'profilephotos' : 'vehiclephotos';

      print('Intentando subir imagen a $bucket/$path');

      if (kIsWeb && imageData is Uint8List) {
        await _supabase.storage.from(bucket).uploadBinary(
              path,
              imageData,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
              ),
            );
      } else if (imageData is File) {
        await _supabase.storage.from(bucket).upload(
              path,
              imageData,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
              ),
            );
      } else {
        throw Exception('Tipo de imagen no válido');
      }

      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      print('Imagen subida exitosamente. URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      print('Error detallado al subir imagen: $e');
      return null;
    }
  }

  Future<void> deleteImage({
    required String path,
    required String type,
  }) async {
    try {
      final String bucket = type == 'profile' ? 'profilephotos' : 'vehiclephotos';
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}