import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final service = NotificationService();
  await service.init();
  await service.showNotification(
    title: message.notification?.title ?? "Ninja Kaato",
    body: message.notification?.body ?? "You have a new message!",
  );
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 🔹 INIT
  Future<void> init() async {
    await _fcm.requestPermission();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initializationSettings);

    await _createChannel(); // IMPORTANT

    /// 🔹 FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
        title: message.notification?.title ?? "Ninja Kaato",
        body: message.notification?.body ?? "Slice some faces!",
      );
    });
  }

  /// 🔹 CREATE CHANNEL (FIXED)
  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(channel);
  }

  /// 🔹 SHOW NOTIFICATION (FIXED)
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel', // channelId
        'High Importance Notifications', // channelName
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}