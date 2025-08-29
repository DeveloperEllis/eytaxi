import 'package:firebase_messaging/firebase_messaging.dart';

class Fcmtoken {
  Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Pedir permisos (iOS)
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("Permiso concedido");

    // Obtener token
    String? token = await messaging.getToken();
    print("🔑 Token FCM: $token");

    // Escuchar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Notificación: ${message.notification?.title}");
    });
  } else {
    print("Permiso denegado");
  }
}

}