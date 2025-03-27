import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pigpen_iot/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

part 'user_provider.g.dart';

@riverpod
Stream<PigpenUser> _pigpenUserStream(_PigpenUserStreamRef ref, String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      throw Exception('User document does not exist');
    }
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    final profile = data['profile'] as Map<String, dynamic>?;
    if (profile == null) {
      throw Exception('Profile data is missing');
    }
    return PigpenUser.fromJson(profile);
  });
}

@riverpod
class ActiveUser extends _$ActiveUser {
  late final StreamSubscription<PigpenUser>? _userSubscription;

  @override
  FutureOr<PigpenUser> build() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User is not logged in');

    // Get initial data
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) throw Exception('User document does not exist');

    final profile = doc.data()?['profile'] as Map<String, dynamic>?;
    if (profile == null) throw Exception('Profile data is missing');

    // Set up stream listener
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists) throw Exception('User document does not exist');
      final data = snap.data()?['profile'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Profile data is missing');
      return PigpenUser.fromJson(data);
    }).listen((user) {
      state = AsyncValue.data(user);
    });

    ref.onDispose(() {
      _userSubscription?.cancel();
    });

    return PigpenUser.fromJson(profile);
  }

  Future<void> addNewUser(String email) async {
    final date =
        DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now()).toString();
    final newUser = PigpenUser(
      userId: FirebaseAuth.instance.currentUser!.uid,
      email: email,
      firstname: '',
      lastname: '',
      dateRegistered: date,
      role: 'user',
      things: 0,
      profileImageUrl: '',
    );

    await _updateUser(newUser);
  }

  Future<void> updateFullname(String firstname, String lastname) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User is not logged in');

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profile.firstname': firstname,
      'profile.lastname': lastname,
    });

    await FirebaseAuth.instance.currentUser?.updateDisplayName(
      '$firstname $lastname'.trim(),
    );
  }

  Future<void> incrementDevice() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User is not logged in');

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profile.things': FieldValue.increment(1),
    });
  }

  Future<void> _updateUser(PigpenUser newUser) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User is not logged in');

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'profile': newUser.toJson(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
