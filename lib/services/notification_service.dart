import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _timeZonesInitialized = false;

  /// Initializes the notification service
  static Future<void> init() async {
    try {
      // Initialize timezones only once
      if (!_timeZonesInitialized) {
        tz_data.initializeTimeZones();
        _timeZonesInitialized = true;
      }

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/pig_icon250x250');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
      );

      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification tapped: ${response.payload}');
        },
      );

      await _createNotificationChannel();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
      rethrow;
    }
  }

  /// Creates the notification channel
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid && (await _isAndroid8OrHigher())) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'pig_wash_channel',
        'Pig Wash Reminders',
        description: 'Reminders for pig wash schedules',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        showBadge: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Checks Android version
  static Future<bool> _isAndroid8OrHigher() async {
    return Platform.isAndroid && int.parse(Platform.version.split('.')[0]) >= 8;
  }

  /// Handles exact alarm permissions
  static Future<bool> checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid && (await _isAndroid13OrHigher())) {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();
        return result.isGranted;
      }
      return true;
    }
    return true;
  }

  /// Checks Android 13+
  static Future<bool> _isAndroid13OrHigher() async {
    return Platform.isAndroid &&
        int.parse(Platform.version.split('.')[0]) >= 13;
  }

  /// Schedules a notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final hasPermission = await checkAndRequestExactAlarmPermission();
      if (!hasPermission) {
        throw Exception('Exact alarm permission not granted');
      }

      final tz.TZDateTime scheduledTime = scheduledDate is tz.TZDateTime
          ? scheduledDate
          : tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pig_wash_channel',
        'Pig Wash Reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/pig_icon250x250',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/pig_icon250x250'),
        color: Colors.green,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('Notification scheduled at $scheduledTime (local time)');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
      rethrow;
    }
  }

  /// Cancels all notifications
  static Future<void> cancelAllNotifications(int id) async {
    await _notifications.cancelAll();
    debugPrint('All notifications canceled');
  }
}
//this is how to use of call this service
// In your widget
// final notificationService = ref.read(notificationServiceProvider);

// // Initialize early in your app lifecycle
// await notificationService.init();

// // Schedule a notification
// await notificationService.scheduleNotification(
//   title: 'Test',
//   body: 'Notification',
//   scheduledDate: DateTime.now().add(Duration(seconds: 5)),
// );
