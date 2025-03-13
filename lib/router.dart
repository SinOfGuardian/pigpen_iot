// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/apps/app_view.dart';
import 'package:pigpen_iot/apps/intro/displayname_page.dart';
import 'package:pigpen_iot/auth/login_screen.dart';
import 'package:pigpen_iot/auth/registration/registration_view.dart';
import 'package:pigpen_iot/auth/registration/registration_viewmodel.dart';
import 'package:pigpen_iot/custom/app_transition_animation.dart';

import 'package:pigpen_iot/splashscreen.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (_, __) async {
        // Redirect to login if the user is not signed in
        if (!_isSignedIn()) return '/login';

        // Redirect to get-to-know if the user hasn't set a display name
        if (!_isDoneWithDisplayName()) return '/get-to-know';

        // Fetch the user's role and redirect accordingly
        final role = await fetchUserRole();
        return role == 'admin' ? '/admin-dashboard' : '/home';
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (_, state) =>
          sharedAxisTransition(state: state, child: const AppScreen()),
      onExit: (BuildContext context, _) {
        if (!_isSignedIn()) return true;
        return showExitDialog(
          context,
          cancelLabel: 'Stay',
          confirmLabel: 'Yes, for now',
        ).then((result) {
          if (result != null && result) return true;
          return false;
        });
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (_, state) => sharedAxisTransition(
        state: state,
        transitionType: TransitionType.horizontal,
        child: const LoginScreen(),
      ),
      onExit: (BuildContext context, _) {
        if (_isSignedIn()) return true;
        return showExitDialog(context).then((result) {
          if (result != null && result) return true;
          return false;
        });
      },
      routes: [
        GoRoute(
          path: 'registration',
          pageBuilder: (_, state) => sharedAxisTransition(
            state: state,
            transitionType: TransitionType.horizontal,
            child: const RegistrationPage(),
          ),
          onExit: (BuildContext context, _) {
            final ref = ProviderScope.containerOf(context);
            ref.read(registrationProvider.notifier).clear();
            return true;
          },
        ),
      ],
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (_, state) =>
          MaterialPage<void>(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: '/get-to-know',
      pageBuilder: (_, state) =>
          MaterialPage<void>(key: state.pageKey, child: const DisplayName()),
      onExit: (BuildContext context, _) {
        if (_isDoneWithDisplayName()) return true;
        return showExitDialog(context).then((result) {
          if (result != null && result) return true;
          return false;
        });
      },
    ),
  ],
);

// Helper functions
bool _isSignedIn() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}

bool _isDoneWithDisplayName() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null && user.displayName != null && user.displayName != '';
}

// bool _isDoneIntro() {
//   const prefs = SharedPrefs();
//   return prefs.readBool(kDoneIntro) ?? false;
// }

// Future<String?> fetchUserRole() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     final DatabaseReference userRoleRef =
//         FirebaseDatabase.instance.ref("users/${user.uid}/profile/role");
//     final snapshot = await userRoleRef.get();
//     if (snapshot.exists) {
//       return snapshot.value as String?;
//     }
//   }
//   return null;
// }
Future<String?> fetchUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Fetch the user document from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Check if the document exists and has a 'role' field
    if (doc.exists) {
      final data = doc.data();
      return data?['role'] as String?; // Return the role if it exists
    }
  }
  return null; // Return null if the user or document doesn't exist
}

// Exit dialog
Future<bool> showExitDialog(BuildContext context,
    {String title = 'Exit',
    String message = 'Are you sure you want to exit?',
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Exit'}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}
