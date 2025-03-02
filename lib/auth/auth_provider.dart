import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication State Provider
class AuthState extends StateNotifier<bool> {
  AuthState() : super(false);

  Future<void> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    state = true;
  }

  void logout() {
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthState, bool>((ref) {
  return AuthState();
});
