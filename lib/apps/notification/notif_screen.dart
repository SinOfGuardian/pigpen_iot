import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pigpen_iot/provider/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifs = ref.watch(firestoreNotificationProvider);

    return Scaffold(
      body: asyncNotifs.when(
        data: (notifs) => ListView.builder(
          itemCount: notifs.length,
          itemBuilder: (context, index) {
            final notification = notifs[index];

            return Dismissible(
              key: Key(notification.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.green,
                child: const Icon(Icons.done, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                final userId =
                    'exampleUserId'; // Replace with actual user ID retrieval logic
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notifications')
                    .doc(notification.id)
                    .update({'isRead': true});
                return false; // prevent dismissal but mark as read
              },
              child: ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.body),
                trailing: notification.isRead
                    ? null
                    : const Icon(Icons.fiber_manual_record,
                        size: 12, color: Colors.red),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
