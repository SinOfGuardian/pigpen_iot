import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
        // Handle notification tap (e.g., navigate to a specific screen)
      },
    );

    await createNotificationChannel(); // Create the notification channel
  }

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pig_wash_channel', // Channel ID
      'Pig Wash Reminders', // Channel name
      importance: Importance.max,
      description: 'Channel for pig wash reminders',
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(channel);
  }

  static Future<bool> checkAndRequestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  static Future<void> scheduleNotification({
    required String deviceId,
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

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pig_wash_channel', // Channel ID
        'Pig Wash Reminders', // Channel name
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        0, // Notification ID
        title,
        body,
        tz.TZDateTime.from(
            scheduledDate, tz.local), // Convert to local time zone
        notificationDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      print('Notification scheduled at $scheduledDate');
    } catch (e) {
      print('Failed to schedule notification: $e');
      rethrow;
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications canceled');
  }
}
