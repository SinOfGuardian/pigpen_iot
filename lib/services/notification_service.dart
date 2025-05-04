import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pigpen_iot/apps/notification/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  static Future<void> handleScheduleConfirmation(String payload) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (navigatorKey.currentContext == null) {
      debugPrint('No context available for confirmation dialog.');
      return;
    }

    final parts = payload.split('|');
    if (parts.length != 3) return;

    final deviceId = parts[0];
    final scheduleKey = parts[1];
    final category = parts[2];

    bool? userResponded;

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Task"),
          content: Text("Did you complete the $category task?"),
          actions: [
            TextButton(
              onPressed: () {
                userResponded = true;
                Navigator.pop(context);
                _logAndRemove(deviceId, scheduleKey, category, "success");
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                userResponded = true;
                Navigator.pop(context);
                _logAndRemove(deviceId, scheduleKey, category, "failed");
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(minutes: 5)).then((_) async {
      if (userResponded != true) {
        await _logAndRemove(deviceId, scheduleKey, category, "timeout");
      }
    });
  }

  static Future<void> _logAndRemove(String deviceId, String scheduleKey,
      String category, String status) async {
    final database = FirebaseDatabase.instance;

    final snapshot = await database
        .ref('/realtime/schedules/$deviceId/$scheduleKey/dateTime')
        .get();

    final dateTime = snapshot.exists
        ? DateTime.parse(snapshot.value.toString())
        : DateTime.now();

    await database.ref('/realtime/logs/$deviceId/$scheduleKey').set({
      'status': status,
      'category': category,
      'dateTime': dateTime.toIso8601String(),
      'loggedAt': DateTime.now().toIso8601String(),
    });

    await database.ref('/realtime/schedules/$deviceId/$scheduleKey').remove();

    debugPrint(
        "Logged $status and removed schedule $scheduleKey for $category");
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
      onDidReceiveNotificationResponse: (response) async {
        debugPrint("Notification tapped: \${response.payload}");
        if (response.payload != null) {
          await handleScheduleConfirmation(response.payload!);
        }
      },
    );

    await _createNotificationChannel();
    await _requestPermissions();
  }

  // Firebase Cloud Messaging setup

  static Future<void> saveFCMToken(String token, String userId) async {
    final database = FirebaseDatabase.instance;
    await database.ref('/users/$userId/fcmToken').set(token);
  }

  static Future<void> _initFirebaseMessaging() async {
    if (!_fcmInitialized) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.instance
          .getInitialMessage()
          .then(_handleTerminatedMessage);

      // ✅ Get and save FCM token after initializing
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint('📱 FCM Token: $token');

      final user = FirebaseAuth.instance.currentUser;

      if (token != null && user != null) {
        await saveFCMToken(token, user.uid);
      }

      _fcmInitialized = true;
    }
  }

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

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await _initTimezone();
    await _initLocalNotifications();
    await showNotificationFromFirebase(message);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await showNotificationFromFirebase(message);
  }

  static Future<void> _handleTerminatedMessage(RemoteMessage? message) async {
    if (message != null) {
      await showNotificationFromFirebase(message);
    }
  }

  static Future<void> showNotificationFromFirebase(
      RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    if (notification != null && android != null) {
      final newNotif = NotificationItem(
        id: '', // Firestore will generate it
        title: notification.title ?? '',
        body: notification.body ?? '',
        timestamp: DateTime.now(),
      );

      //  Save to Firestore only
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .add(newNotif.toMap());
        debugPrint("✅ Notification saved to Firestore");
      }

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pig_wash_channel',
            'Pig Wash Alerts',
            importance: Importance.high,
          ),
        ),
        payload: message.data['payload'],
      );
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final newNotif = NotificationItem(
      id: '',
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add(newNotif.toMap());
    }

    const androidDetails = AndroidNotificationDetails(
      'pig_wash_channel',
      'Pig Wash Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    final notification = NotificationItem(
      id: '',
      title: title,
      body: body,
      timestamp: scheduledTime,
    );

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add(notification.toMap());
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'pig_wash_channel',
      'Pig Wash Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      tzTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
