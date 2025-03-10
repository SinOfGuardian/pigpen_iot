import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pigpen_iot/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart'; // For date formatting

part 'user_provider.g.dart'; // Include the generated file

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
    final profile = snapshot.data()?['profile'] as Map<String, dynamic>?;
    if (profile == null) {
      throw Exception('Profile data is missing');
    }
    return PigpenUser.fromJson(profile); // Deserialize from the "profile" field
  });
}

@riverpod
class ActiveUser extends _$ActiveUser {
  @override
  FutureOr<PigpenUser> build() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User is not logged in');
    return await ref.watch(_pigpenUserStreamProvider(uid).future);
  }

  Future<void> addNewUser(String email) async {
    final date = DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now()).toString();
    final newUser = PigpenUser(
      userId: FirebaseAuth.instance.currentUser!.uid,
      email: email,
      firstname: '',
      lastname: '',
      dateRegistered: date,
      role: 'user', // Default role
      things: 0,
      profileImageUrl: '',
    );

    // Save user data to Firestore under the "profile" field
    await _updateUser(newUser);
  }

  Future<void> updateFullname(String firstname, String lastname) async {
    final currentUser = await future; // Access the current user data
    final newUser = currentUser.copyWith(
      firstname: firstname,
      lastname: lastname,
    );

    // Update the display name in Firebase Authentication
    await FirebaseAuth.instance.currentUser?.updateDisplayName(firstname);

    // Update the user data in Firestore
    await _updateUser(newUser);
  }

  Future<void> incrementDevice() async {
    final currentUser = await future; // Access the current user data
    final newUser = currentUser.copyWith(things: currentUser.things + 1);

    // Update the user data in Firestore
    await _updateUser(newUser);
  }

  Future<void> _updateUser(PigpenUser newUser) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User is not logged in');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'profile': newUser.toJson(), // Save user data under the "profile" field
        }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}