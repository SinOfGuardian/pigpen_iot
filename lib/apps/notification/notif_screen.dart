import 'package:flutter/material.dart';
import 'package:pigpen_iot/services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Notification Testing'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final now = DateTime.now().add(const Duration(seconds: 5));
            const testDeviceId = 'testDeviceId';
            const testScheduleKey = 'testKey123';
            const testCategory = 'shower';

            await NotificationService.scheduleLocalNotification(
              title: 'PigPen Reminder',
              body: 'Time to $testCategory the pigs!',
              scheduledTime: now,
              payload: '$testDeviceId|$testScheduleKey|$testCategory',
            );
          },
          child: const Text('Send Test Notification (5 sec)'),
        ),
      ),
    );
  }
}
