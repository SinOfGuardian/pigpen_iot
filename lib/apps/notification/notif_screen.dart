import 'package:flutter/material.dart';
import 'package:pigpen_iot/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _showNotification() async {
    try {
      await NotificationService.init();

      // Get current time in local timezone
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime =
          now.add(const Duration(hours: 8, minutes: 0, seconds: 5));

      // Format for display
      final formattedTime =
          DateFormat('yyyy-MM-dd hh:mm a').format(scheduledTime);
      debugPrint('Notification scheduled at $formattedTime (local time)');

      await NotificationService.scheduleNotification(
        title: 'PigPen Alert',
        body: 'Hello from PigPen! Scheduled at $formattedTime',
        scheduledDate: scheduledTime,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Notifications'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showNotification,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            'Show Notification',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
