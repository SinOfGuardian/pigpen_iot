import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String email;
  final String password;
  final String password2;

  const AuthUser({
    required this.email,
    required this.password,
    required this.password2,
  });

  factory AuthUser.clear() =>
      const AuthUser(email: '', password: '', password2: '');

  AuthUser copyWith({String? email, String? password, String? password2}) {
    return AuthUser(
      email: email ?? this.email,
      password: password ?? this.password,
      password2: password2 ?? this.password2,
    );
  }

  @override
  String toString() {
    return 'AuthUser('
        'email: $email, '
        'password: $password, '
        'password2: $password2'
        ')';
  }
}

@immutable
class AuthFieldsMessage {
  final String? emailMessage;
  final String? passwordMessage;
  final String? passwordMessage2;

  const AuthFieldsMessage({
    this.emailMessage,
    this.passwordMessage,
    this.passwordMessage2,
  });

  AuthFieldsMessage copyWith({
    String? emailMessage,
    String? passwordMessage,
    String? passwordMessage2,
  }) {
    return AuthFieldsMessage(
      emailMessage: emailMessage ?? this.emailMessage,
      passwordMessage: passwordMessage ?? this.passwordMessage,
      passwordMessage2: passwordMessage2 ?? this.passwordMessage2,
    );
  }

  AuthFieldsMessage cloneWith(AuthFieldsMessage authFieldsMessage) {
    return AuthFieldsMessage(
      emailMessage: authFieldsMessage.emailMessage,
      passwordMessage: authFieldsMessage.passwordMessage,
      passwordMessage2: authFieldsMessage.passwordMessage2,
    );
  }

  @override
  String toString() {
    return 'AuthFieldsMessage('
        'emailMessage: $emailMessage, '
        'passwordMessage: $passwordMessage, '
        'passwordMessage2: $passwordMessage2'
        ')';
  }
}
