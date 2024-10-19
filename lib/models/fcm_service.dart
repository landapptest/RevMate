import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FCMService() {
    _initializeFCM();
  }

  // FCM 초기화 및 메시지 리스너 설정
  void _initializeFCM() {
    // 포그라운드 메시지 수신 리스너 등록
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 수신 처리 리스너 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 로컬 알림 설정
    _setupLocalNotifications();
  }

  // 포그라운드에서 메시지 수신 처리
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showLocalNotification(message.notification!);
    }
  }

  // 로컬 알림 설정
  void _setupLocalNotifications() {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    _localNotificationsPlugin.initialize(initSettings);
  }

  // 로컬 알림 표시
  void _showLocalNotification(RemoteNotification notification) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id', // 채널 ID
      'channel_name', // 채널 이름
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  // 백그라운드 메시지 수신 처리 (중요)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Firebase 초기화가 필요할 수도 있음
    print('Handling a background message: ${message.messageId}');

    if (message.notification != null) {
      // 백그라운드에서 받은 알림을 처리하여 로컬 알림으로 표시
      FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initSettings = InitializationSettings(android: androidSettings);
      await localNotificationsPlugin.initialize(initSettings);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'channel_id', // 채널 ID
        'channel_name', // 채널 이름
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      localNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification!.title,
        message.notification!.body,
        platformDetails,
      );
    }
  }
}
