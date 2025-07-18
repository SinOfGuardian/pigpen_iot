// ignore_for_file: non_constant_identifier_names

import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pigpen_iot/auth/forgetpassword/forgot_view.dart';
import 'package:pigpen_iot/auth/login_viewmodel.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/hyperlink_text.dart';
import 'package:pigpen_iot/extensions/app_snackbar.dart';
import 'package:pigpen_iot/models/auth_model.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class LoginScreen extends ConsumerWidget with InternetConnection {
  const LoginScreen({super.key});

  void loginOnPressed(BuildContext context, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!ref.read(loginFieldsProvider.notifier).validateFields()) return;

    showLoader(
      context,
      process: isConnected(true, context).then((isConnected) {
        if (!isConnected) return null;
        return ref.read(loginProvider.notifier).loginUser().catchError((error) {
          if (!context.mounted) return null;
          onError(error as FirebaseException, context, ref);
          return null;
        });
      }),
    ).then((user) async {
      if (user == null || user.isAnonymous) return;

      final role = await ref.read(loginProvider.notifier).fetchUserRole(user);
      if (context.mounted) {
        if (role == 'admin') {
          context.go('/admin-dashboard');
        } else {
          context.go('/home');
        }
      }
      ref.read(loginProvider.notifier).clear();
    });
  }

  void GoogleOnPressed(BuildContext context, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();

    showLoader(
      context,
      process: isConnected(true, context).then((isConnected) {
        if (!isConnected) return null;

        // Attempt to sign in with Google
        return ref
            .read(loginProvider.notifier)
            .loginWithGoogle()
            .catchError((error) {
          if (!context.mounted) return null;

          onError(error as FirebaseException, context, ref);
          return null;
        });
      }),
    ).then((userCredential) async {
      if (userCredential is UserCredential) {
        // Get the signed-in user
        final user = userCredential.user;

        if (user != null) {
          // Fetch user role from Firebase Realtime Database
          final role =
              await ref.read(loginProvider.notifier).fetchUserRole(user);

          if (context.mounted) {
            if (role == 'admin') {
              context.go('/admin-dashboard');
            } else if (role == 'user') {
              context.go('/home');
            } else {
              context.go('/get-to-know');
            }
          }
        }
        ref.read(loginProvider.notifier).clear();
      }
    });
  }

  void onError(
      FirebaseException exception, BuildContext context, WidgetRef ref) {
    final code = exception.code;
    final message = code.trim().replaceAll('-', ' ').toCapitalizeFirst();
    AuthFieldsMessage newState = const AuthFieldsMessage();
    if (code == 'invalid-email' ||
        code == 'user-not-found' ||
        code == 'user-disabled') {
      newState = newState.copyWith(emailMessage: message);
    } else if (code == 'wrong-password') {
      newState = newState.copyWith(
          passwordMessage: message, passwordMessage2: message);
    } else if (code == 'network-request-failed') {
      context.showSnackBar(kNoInternet, theme: SnackbarTheme.error);
    } else {
      context.showSnackBar('$code $message', theme: SnackbarTheme.error);
      debugPrint('$code $message');
    }
    ref.read(loginFieldsProvider.notifier).updateState(newState);
  }

  Widget _graphic(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Image.asset('assets/images/pig_padlock.png', fit: BoxFit.fitWidth),
    );
  }

  Widget _fields(BuildContext context, WidgetRef ref) {
    final authFieldsMessage = ref.watch(loginFieldsProvider);
    return Column(
      children: [
        const Entry.all(
          delay: Duration(milliseconds: 50),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FormTitle('Sign In', padding: EdgeInsets.only(bottom: 10)),
          ),
        ),
        Entry.all(
          delay: const Duration(milliseconds: 100),
          child: AppTextField(
            labelText: 'Email',
            errorText: authFieldsMessage.emailMessage,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: null,
            onChanged: (newText) {
              ref.read(loginFieldsProvider.notifier).resetEmail();
              ref.read(loginProvider.notifier).update(email: newText);
            },
          ),
        ),
        Entry.all(
          delay: const Duration(milliseconds: 150),
          child: InputPasswordField(
            labelText: 'Password',
            errorText: authFieldsMessage.passwordMessage,
            textInputAction: TextInputAction.next,
            onEyePressed: ref.read(showPasswordLoginProvider.notifier).toggle,
            showPassword: ref.watch(showPasswordLoginProvider),
            controller: null,
            onSubmitted: () => null, //loginOnPressed(context, ref),
            onChanged: (newText) {
              ref.read(loginFieldsProvider.notifier).resetPassword();
              ref.read(loginProvider.notifier).update(password: newText);
            },
          ),
        ),
      ],
    );
  }

//forget password
  Widget _forgetpass(BuildContext context, WidgetRef ref) {
    return Entry.all(
      delay: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding here
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ForgetPage();
                    },
                  ),
                );
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 167, 85),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0, // Set font size here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(BuildContext context, WidgetRef ref) {
    return Entry.all(
      delay: const Duration(milliseconds: 200),
      child: AppFilledButton.big(
        text: 'Log In',
        icon: EvaIcons.logInOutline,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 2),
        onPressed: () => loginOnPressed(context, ref),
      ),
    );
  }

//divider
  Widget _divider(BuildContext context, WidgetRef ref) {
    return const Entry.all(
      delay: Duration(milliseconds: 200),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                color: Color.fromARGB(255, 208, 208, 208),
                thickness: 1.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "or",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 145, 145, 145),
                  fontWeight: FontWeight.normal,
                  fontSize: 13.0,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Color.fromARGB(255, 208, 208, 208),
                thickness: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleButton(BuildContext context, WidgetRef ref) {
    //final _authService = Login();
    return Entry.all(
      delay: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity, // Full screen width
        child: OutlinedButton.icon(
          onPressed: () => GoogleOnPressed(context, ref),
          //add async code here
          //     async {
          //   // Create an instance of AuthService
          //   await authService.loginWithGoogle();
          // },
          icon: const Icon(
            Ionicons.logo_google,
            color: Color.fromARGB(255, 1, 167, 85),
            size: 18.0, // Set icon size to 20
          ),
          label: const Text(
            'Sign in with Google',
            style: TextStyle(color: Color.fromARGB(255, 1, 167, 85)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
                color: Color.fromARGB(255, 1, 167, 85)), // Outline color
            padding:
                const EdgeInsets.symmetric(vertical: 16.0), // Adjust padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            backgroundColor: Colors.transparent, // Transparent background
          ),
        ),
      ),
    );
  }

  Widget _hyperlink(BuildContext context, WidgetRef ref) {
    return Entry.all(
      delay: const Duration(milliseconds: 400),
      child: HyperLinkText(
        text: "I'm new to Pig Pen IoT, ",
        hyperlink: 'Sign Up',
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          ref.read(loginFieldsProvider.notifier).resetLoginFields();
          ref.read(showPasswordLoginProvider.notifier).reset();
          context.push('/login/registration');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _graphic(context),
                  _fields(context, ref),
                  _forgetpass(context, ref),
                  _button(context, ref),
                  _divider(context, ref),
                  _googleButton(context, ref),
                  _hyperlink(context, ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
