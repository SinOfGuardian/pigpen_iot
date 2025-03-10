import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pigpen_iot/models/auth_model.dart';

part 'registration_viewmodel.g.dart';

@riverpod
class ShowPasswordSignup extends _$ShowPasswordSignup {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

@Riverpod(keepAlive: true)
class Registration extends _$Registration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  AuthUser build() => AuthUser.clear();

  void clear() => AuthUser.clear();

  void update({String? email, String? password, String? password2}) {
    state =
        state.copyWith(email: email, password: password, password2: password2);
  }

  Future<User?> registerUser() async {
    final email = state.email.trim();
    final password = state.password.trim();
    if (email.isEmpty || password.isEmpty) return null;

    try {
      // Create user with Firebase Authentication
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 5));

      if (credential.user == null || credential.user?.email == null) {
        return null;
      }

      // Save user data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now(),
      });

      // Update the active user in the app
      //await ref.read(activeUserProvider.notifier).addNewUser(email);

      return credential.user;
    } catch (e) {
      // Handle errors (e.g., display a snackbar)
      rethrow;
    }
  }
}

@riverpod
class RegistrationFields extends _$RegistrationFields {
  @override
  AuthFieldsMessage build() => const AuthFieldsMessage();

  void updateState(AuthFieldsMessage newState) => state = newState;

  void resetEmail() => state = state.cloneWith(AuthFieldsMessage(
        passwordMessage: state.passwordMessage,
        passwordMessage2: state.passwordMessage2,
      ));
  void resetPassword() => state = state.cloneWith(AuthFieldsMessage(
        emailMessage: state.emailMessage,
        passwordMessage2: state.passwordMessage2,
      ));
  void resetPassword2() => state = state.cloneWith(AuthFieldsMessage(
        emailMessage: state.emailMessage,
        passwordMessage: state.passwordMessage,
      ));

  bool validateFields() {
    final emailFormat = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    final authUser = ref.read(registrationProvider);
    bool isValid = true;
    AuthFieldsMessage newState = const AuthFieldsMessage();

    if (authUser.email.isEmpty) {
      isValid = false;
      newState = newState.copyWith(emailMessage: 'Please enter email');
      
    } else if (!emailFormat.hasMatch(authUser.email)) {
      isValid = false;
      newState = newState.copyWith(emailMessage: 'Please enter valid email');
    }
    if (authUser.password.isEmpty) {
      isValid = false;
      newState = newState.copyWith(passwordMessage: 'Please enter a password');
    }
    if (authUser.password2.isEmpty) {
      isValid = false;
      newState = newState.copyWith(passwordMessage2: 'Please confirm password');
    }
    if (authUser.password != authUser.password2 &&
        authUser.password.isNotEmpty &&
        authUser.password2.isNotEmpty) {
      const message = 'Passwords does not match';
      newState = newState.copyWith(
          passwordMessage: message, passwordMessage2: message);
      isValid = false;
    }
    state = newState;
    return isValid;
  }
}
