// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ionicons/ionicons.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pigpen_iot/auth/login_viewmodel.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgetPage extends ConsumerStatefulWidget {
  const ForgetPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgetPageState();
}

class _ForgetPageState extends ConsumerState<ForgetPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      AwesomeDialog(
        context: context,
        animType: AnimType.topSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.success,
        //showCloseIcon: true,
        title: 'Success',
        desc:
            'Reset link has been sent to your email. Please check your email.',
        btnOkOnPress: () async {
          final Uri gmailUri = Uri.parse('https://mail.google.com/');
          if (await canLaunchUrl(gmailUri)) {
            await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('Could not launch Gmail');
          }
        },
        btnOkIcon: Ionicons.checkmark_outline,
        onDismissCallback: (type) {
          debugPrint('Dialog Dismissed from callback $type');
        },
      ).show();
    } on FirebaseAuthException catch (e) {
      //body: Text(e.message.toString()),
      AwesomeDialog(
        context: context,
        animType: AnimType.topSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.warning,
        //showCloseIcon: true,
        title: 'Info',
        body: Text(e.message.toString()),
        padding: const EdgeInsets.all(20.0),
        onDismissCallback: (type) {
          debugPrint('Dialog Dismissed from callback $type');
        },
      ).show();
    }
  }

  Widget _graphic(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
      child:
          Image.asset('assets/images/reset_graphics.png', fit: BoxFit.fitWidth),
    );
  }

  Widget _fields(BuildContext context, WidgetRef ref) {
    final authFieldsMessage = ref.watch(loginFieldsProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        children: [
          const Entry.all(
            delay: Duration(milliseconds: 50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FormTitle('Forgot Password',
                  padding: EdgeInsets.only(bottom: 10)),
            ),
          ),
          const Entry.all(
            delay: Duration(milliseconds: 50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter your email and we will send you a reset link.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color.fromARGB(255, 44, 44, 44),
                  fontWeight: FontWeight.normal,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
          Entry.all(
            delay: const Duration(milliseconds: 100),
            child: AppTextField(
              labelText: 'Email',
              errorText: authFieldsMessage.emailMessage,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              controller: _emailController,
              onChanged: (newText) {
                ref.read(loginFieldsProvider.notifier).resetEmail();
                ref.read(loginProvider.notifier).update(email: newText);
              },
            ),
          ),
        ],
      ),
    );
  }

//unused
  Widget _text(BuildContext context, WidgetRef ref) {
    return const Entry.all(
      delay: Duration(milliseconds: 200),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    "Forgot Password?",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color.fromARGB(255, 44, 44, 44),
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                ],
              ),
            ),
            Text('Enter your email and we will send you a reset link.'),
          ],
        ),
      ),
    );
  }

  Widget _button(BuildContext context, WidgetRef ref) {
    return Entry.all(
      delay: const Duration(milliseconds: 200),
      child: AppFilledButton.big(
        text: 'Reset',
        icon: Ionicons.refresh_outline,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 2),
        onPressed: passwordReset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
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
                  //_text(context, ref),
                  _fields(context, ref),
                  _button(context, ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
