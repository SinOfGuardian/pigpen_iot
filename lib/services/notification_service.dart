import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification service with your custom icon
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/pig_icon250x250');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
        // Handle notification tap (navigate, etc.)
      },
    );

    await _createNotificationChannel();
  }

  /// Creates the notification channel with your custom icon
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid && (await _isAndroid8OrHigher())) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'pig_wash_channel',
        'Pig Wash Reminders',
        description: 'Reminders for pig wash schedules',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound(
            'notification_sound'), // Optional sound
        enableVibration: true,
        showBadge: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Checks if the device runs Android 8.0+ (API 26+)
  static Future<bool> _isAndroid8OrHigher() async {
    return Platform.isAndroid && int.parse(Platform.version.split('.')[0]) >= 8;
  }

  /// Handles exact alarm permissions for Android 13+
  static Future<bool> checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid && (await _isAndroid13OrHigher())) {
      if (await Permission.scheduleExactAlarm.isGranted) {
        return true;
      }
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true;
  }

  /// Checks if the device runs Android 13+ (API 33+)
  static Future<bool> _isAndroid13OrHigher() async {
    return Platform.isAndroid &&
        int.parse(Platform.version.split('.')[0]) >= 13;
  }

  /// Schedules a notification with your custom icon
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final hasPermission = await checkAndRequestExactAlarmPermission();
      if (!hasPermission) {
        print('Exact alarm permission not granted');
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pig_wash_channel', // Channel ID
        'Pig Wash Reminders', // Channel name
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/pig_icon250x250',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/pig_icon250x250'),
        color: Colors.green, // Accent color
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.zonedSchedule(
        0, // Notification ID
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      print('Notification scheduled at $scheduledDate');
    } catch (e) {
      print('Failed to schedule notification: $e');
      rethrow;
    }
  }

  /// Cancels all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications canceled');
  }
}
