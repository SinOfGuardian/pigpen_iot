import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class RegistrationPage extends ConsumerWidget with InternetConnection {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _graphic(context),
                // _fields(ref),
                // _button(context, ref),
                // _hyperlink(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }
}