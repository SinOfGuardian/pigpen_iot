import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:  EdgeInsets.symmetric(horizontal: 30),
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
