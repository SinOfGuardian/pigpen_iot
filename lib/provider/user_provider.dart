import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart'; // For date formatting

part 'user_provider.g.dart';

@riverpod
Stream<PigpenUser> _pigpenUserStream(Ref ref, String uid) {
  final path = FirebaseFirestore.instance.collection('users').doc(uid);
  return path.snapshots().map((snapshot) {
    if (!snapshot.exists) {
      throw Exception('User not found');
    }
    return PigpenUser.fromJson(snapshot.data()!);
  });
}

@riverpod
class ActiveUser extends _$ActiveUser {
  @override
  FutureOr<PigpenUser> build() async {
    await Future.delayed(const Duration(seconds: 1));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('UID is null');
    return await ref.watch(_pigpenUserStreamProvider(uid).future);
  }

  Future<void> addNewUser(String email) async {
    final date = DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now());
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
    return _updateUser(newUser);
  }

  Future<void> updateFullname(String firstname, String lastname) async {
    final newUser = await future.then(
        (user) => user.copyWith(firstname: firstname, lastname: lastname));
    await FirebaseAuth.instance.currentUser?.updateDisplayName(firstname);
    return _updateUser(newUser);
  }

  Future<void> incrementDevice() async {
    final newUser = await future.then(
        (user) => user.copyWith(things: user.things + 1));
    return _updateUser(newUser);
  }

  Future<void> _updateUser(PigpenUser newUser) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('UID is null');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(newUser.toJson(), SetOptions(merge: true))
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
