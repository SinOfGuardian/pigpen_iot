import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _tzInitialized = false;
  static bool _fcmInitialized = false;

  // Initialize all notification services
  static Future<void> init() async {
    await _initTimezone();
    await _initLocalNotifications();
    await _initFirebaseMessaging();
  }

  // Timezone initialization
  static Future<void> _initTimezone() async {
    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      final String timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone));
      _tzInitialized = true;
    }
  }

  // Local notifications setup
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/pig_icon250x250');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notification tapped: ${response.payload}");
        // Handle notification tap here
      },
    );

    await _createNotificationChannel();
    await _requestPermissions();
  }

  // Firebase Cloud Messaging setup
  static Future<void> _initFirebaseMessaging() async {
    if (!_fcmInitialized) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Terminated message handler
      FirebaseMessaging.instance
          .getInitialMessage()
          .then(_handleTerminatedMessage);

      _fcmInitialized = true;
    }
  }

  // Create notification channel (Android)
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pig_wash_channel',
      'Pig Wash Alerts',
      description: 'Alerts for pig monitoring system',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Request notification permissions
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (int.parse(Platform.version.split('.')[0]) >= 13) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await _initTimezone();
    await _initLocalNotifications();
    await showNotificationFromFirebase(message);
  }

  // Foreground message handler
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await showNotificationFromFirebase(message);
  }

  // Terminated message handler
  static Future<void> _handleTerminatedMessage(RemoteMessage? message) async {
    if (message != null) {
      await showNotificationFromFirebase(message);
    }
  }

  // Show immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pig_wash_channel',
      'Pig Wash Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule a notification
  static Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTz = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pig_wash_channel',
      'Pig Wash Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      scheduledTz,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Handle Firebase Cloud Messages
  static Future<void> showNotificationFromFirebase(
      RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pig_wash_channel',
      'Pig Wash Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      message.hashCode,
      message.notification?.title ?? "PigPen Alert",
      message.notification?.body ?? "New alert from PigPen",
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Get FCM token for device
  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
