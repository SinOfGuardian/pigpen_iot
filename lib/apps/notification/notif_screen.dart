import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/provider/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifs = ref.watch(firestoreNotificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: asyncNotifs.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final notification = notifs[index];

              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.horizontal,
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.mark_email_read, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) return false;

                  if (direction == DismissDirection.startToEnd) {
                    // Swipe Right → Mark as Read
                    if (!notification.isRead) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('notifications')
                          .doc(notification.id)
                          .update({'isRead': true});
                    }
                    return false; // Don't dismiss widget
                  } else if (direction == DismissDirection.endToStart) {
                    // Swipe Left → Delete
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Notification'),
                        content: const Text(
                            'Are you sure you want to delete this notification?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    return confirm ?? false;
                  }
                  return false;
                },
                onDismissed: (direction) async {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null &&
                      direction == DismissDirection.endToStart) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('notifications')
                        .doc(notification.id)
                        .delete();
                  }
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
