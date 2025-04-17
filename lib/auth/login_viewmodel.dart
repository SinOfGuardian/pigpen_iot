// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/models/auth_model.dart';
import 'package:pigpen_iot/models/user_model.dart';
import 'package:pigpen_iot/provider/user_provider.dart';
import 'package:pigpen_iot/services/internet_connection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'login_viewmodel.g.dart';

@riverpod
class ShowPasswordLogin extends _$ShowPasswordLogin {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void reset() => state = false;
}

@Riverpod(keepAlive: true)
class Login extends _$Login {
  @override
  AuthUser build() => AuthUser.clear();
  void clear() => state = AuthUser.clear();

  void update({String? email, String? password, String? password2}) {
    state =
        state.copyWith(email: email, password: password, password2: password2);
  }

  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(cred);
      final user = userCredential.user;

      if (user != null) {
        await _initializeUserInFirestore(user);
      }

      return userCredential;
    } catch (e) {
      print('Error during Google Sign-In:  $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      ref.invalidate(activeUserProvider);
      clear();
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }

  Future<void> _initializeUserInFirestore(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final dateRegistered =
          DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now());
      final newUser = PigpenUser(
        userId: user.uid,
        email: user.email ?? '',
        firstname: user.displayName?.split(' ').first ?? '',
        lastname: user.displayName?.split(' ').skip(1).join(' ') ?? '',
        dateRegistered: dateRegistered,
        role: 'user',
        things: 0,
        profileImageUrl: user.photoURL ?? '',
      );

      await userRef.set({'profile': newUser.toJson()});
    }
  }

  Future<User?> loginUser() async {
    final email = state.email.trim();
    final password = state.password.trim();
    if (email.isEmpty || password.isEmpty) return null;

    final credential = await _auth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 5));

    return credential.user;
  }

  Future<String?> fetchUserRole(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()?['profile'] as Map<String, dynamic>?;
      return data?['role'] as String?;
    }
    return null;
  }
}

@riverpod
class LoginFields extends _$LoginFields with InternetConnection {
  @override
  AuthFieldsMessage build() => const AuthFieldsMessage();

  void updateState(AuthFieldsMessage newState) => state = newState;
  void resetLoginFields() => ref.invalidateSelf();
  void resetEmail() => state = state.cloneWith(AuthFieldsMessage(
        passwordMessage: state.passwordMessage,
      ));
  void resetPassword() => state = state.cloneWith(AuthFieldsMessage(
        emailMessage: state.emailMessage,
      ));

  bool validateFields() {
    final emailFormat = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    final authUser = ref.read(loginProvider);
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
    state = newState;
    return isValid;
  }
}
