import 'package:flutter/material.dart';
import 'package:pigpen_iot/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Function to trigger a test notification
  Future<void> _triggerTestNotification() async {
    try {
      await NotificationService.scheduleNotification(
        deviceId: 'test_device_id', // Replace with a test device ID
        title: 'Test Notification', // Title of the notification
        body: 'This is a test notification!', // Body of the notification
        scheduledDate: tz.TZDateTime.now(tz.local)
            .add(const Duration(seconds: 5)), // 5 seconds from now
        payload: 'test_payload', // Optional payload
      );
    } catch (e) {
      print('Failed to trigger test notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Notification Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _triggerTestNotification, // Trigger the test notification
              child: const Text('Trigger Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
