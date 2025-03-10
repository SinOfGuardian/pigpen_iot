import 'package:cloud_firestore/cloud_firestore.dart';

class PigpenUser {
  final String userId;
  final String email;
  final String firstname;
  final String lastname;
  final String dateRegistered;
  final String role;
  final int things;
  final String profileImageUrl;

  PigpenUser({
    required this.userId,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.dateRegistered,
    required this.role,
    required this.things,
    required this.profileImageUrl,
  });

  // Convert PigpenUser to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'dateRegistered': dateRegistered,
      'role': role,
      'things': things,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create PigpenUser from a Firestore document
  factory PigpenUser.fromJson(Map<String, dynamic> json) {
    return PigpenUser(
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      dateRegistered: json['dateRegistered'] as String,
      role: json['role'] as String,
      things: json['things'] as int,
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }

  // Create PigpenUser from a Firestore DocumentSnapshot
  factory PigpenUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PigpenUser.fromJson(data);
  }

  // CopyWith method for updating fields
  PigpenUser copyWith({
    String? userId,
    String? email,
    String? firstname,
    String? lastname,
    String? dateRegistered,
    String? role,
    int? things,
    String? profileImageUrl,
  }) {
    return PigpenUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      dateRegistered: dateRegistered ?? this.dateRegistered,
      role: role ?? this.role,
      things: things ?? this.things,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'PigpenUser(userId: $userId, email: $email, firstname: $firstname, lastname: $lastname, dateRegistered: $dateRegistered, role: $role, things: $things, profileImageUrl: $profileImageUrl)';
  }
}
