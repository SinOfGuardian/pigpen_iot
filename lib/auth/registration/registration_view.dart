import 'package:entry/entry.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/auth/registration/registration_viewmodel.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/hyperlink_text.dart';
import 'package:pigpen_iot/extensions/app_snackbar.dart';
import 'package:pigpen_iot/models/auth_model.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class RegistrationPage extends ConsumerWidget with InternetConnection {
  const RegistrationPage({super.key});

  void registerOnPressed(BuildContext context, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!ref.read(registrationFieldsProvider.notifier).validateFields()) return;

    showLoader(
      context,
      process: isConnected(true, context).then((isConnected) {
        if (!isConnected) return null;
        return ref
            .read(registrationProvider.notifier)
            .registerUser()
            .catchError(
          (error) {
            if (!context.mounted) return null;
            onError(error as FirebaseException, context, ref);
            return null;
          },
        );
      }),
    ).then((result) {
      if (result == null) return;
      if (context.mounted) context.go('/get-to-know');
    });
  }

  void onError(
      FirebaseException exception, BuildContext context, WidgetRef ref) {
    final code = exception.code;
    final message = code.trim().replaceAll('-', ' ').toCapitalizeFirst();
    AuthFieldsMessage newState = const AuthFieldsMessage();

    if (code == 'invalid-email' || code == 'email-already-in-use') {
      newState = newState.copyWith(emailMessage: message);
    } else if (code == 'weak-password') {
      newState = newState.copyWith(
          passwordMessage: message, passwordMessage2: message);
    } else if (code == 'network-request-failed') {
      context.showSnackBar(kNoInternet, theme: SnackbarTheme.error);
    } else {
      context.showSnackBar('$code $message', theme: SnackbarTheme.error);
      debugPrint('$code $message');
    }
    ref.read(registrationFieldsProvider.notifier).updateState(newState);
  }

  Widget _graphic(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05),
      child: Image.asset('assets/images/pig_padlock.png', fit: BoxFit.fitWidth),
    );
  }

  Widget _fields(WidgetRef ref) {
    final authFieldsMessage = ref.watch(registrationFieldsProvider);
    final showPassword = ref.watch(showPasswordSignupProvider);
    return Column(
      children: [
        const Entry.all(
          delay: Duration(milliseconds: 50),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FormTitle('Sign Up', padding: EdgeInsets.only(bottom: 10)),
          ),
        ),
        Entry.all(
          delay: const Duration(milliseconds: 100),
          child: AppTextField(
            labelText: 'Email',
            errorText: authFieldsMessage.emailMessage,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autoFocus: false,
            controller: null,
            onChanged: (newText) {
              ref.read(registrationFieldsProvider.notifier).resetEmail();
              ref.read(registrationProvider.notifier).update(email: newText);
            },
          ),
        ),
        Entry.all(
          delay: const Duration(milliseconds: 150),
          child: InputPasswordField(
            labelText: 'Password',
            errorText: authFieldsMessage.passwordMessage,
            textInputAction: TextInputAction.next,
            showPassword: showPassword,
            onEyePressed: ref.read(showPasswordSignupProvider.notifier).toggle,
            controller: null,
            onChanged: (newText) {
              ref.read(registrationFieldsProvider.notifier).resetPassword();
              ref.read(registrationProvider.notifier).update(password: newText);
            },
          ),
        ),
        Entry.all(
          delay: const Duration(milliseconds: 200),
          child: InputPasswordField(
            labelText: 'Confirm Password',
            errorText: authFieldsMessage.passwordMessage2,
            textInputAction: TextInputAction.done,
            showPassword: showPassword,
            onEyePressed: ref.read(showPasswordSignupProvider.notifier).toggle,
            controller: null,
            onChanged: (newText) {
              ref.read(registrationFieldsProvider.notifier).resetPassword2();
              ref
                  .read(registrationProvider.notifier)
                  .update(password2: newText);
            },
          ),
        ),
      ],
    );
  }

  Widget _button(BuildContext context, WidgetRef ref) {
    return Entry.all(
      delay: const Duration(milliseconds: 250),
      child: AppFilledButton.big(
        text: 'Register',
        icon: EvaIcons.personAddOutline,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        onPressed: () => registerOnPressed(context, ref),
      ),
    );
  }

  Widget _hyperlink(BuildContext context, WidgetRef ref) {
    return Entry.all(
      delay: const Duration(milliseconds: 500),
      child: HyperLinkText(
        text: "I already have an account, ",
        hyperlink: 'Sign In',
        onPressed: () => context.pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _graphic(context),
                _fields(ref),
                _button(context, ref),
                _hyperlink(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
