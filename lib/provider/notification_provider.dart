import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/notification/notification_model.dart';

final firestoreNotificationProvider =
    StreamProvider<List<NotificationItem>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    return const Stream.empty();
  }

  final refCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .orderBy('timestamp', descending: true)
      .limit(50); // Increased limit if needed

  return refCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return NotificationItem.fromMap(doc.id, data as Map<String, dynamic>);
    }).toList();
  });
});

final unreadCountProvider = Provider<int>((ref) {
  final asyncNotifications = ref.watch(firestoreNotificationProvider);
  return asyncNotifications.maybeWhen(
    data: (notifications) =>
        notifications.where((n) => !(n.isRead ?? false)).length,
    orElse: () => 0,
  );
});
