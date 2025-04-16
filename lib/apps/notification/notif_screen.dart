import 'package:flutter/material.dart';
import 'package:pigpen_iot/services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final now = DateTime.now().add(const Duration(seconds: 5));
            await NotificationService.scheduleLocalNotification(
              title: 'PigPen Reminder',
              body: 'Time to wash the pigs!',
              scheduledTime: now, // 5 seconds from now,
            );
          },
          child: const Text('Send Test Notification (5 sec)'),
        ),
      ),
    );
  }
}
