import 'package:entry/entry.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/modules/mystrings.dart';
import 'package:pigpen_iot/provider/user_provider.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class DisplayName extends ConsumerStatefulWidget {
  const DisplayName({super.key});
  @override
  ConsumerState<DisplayName> createState() => _DisplayNameState();
}

class _DisplayNameState extends ConsumerState<DisplayName>
    with InternetConnection {
  String? fnameError, lnameError;
  final fname = TextEditingController();
  final lname = TextEditingController();

  @override
  void dispose() {
    fname.dispose();
    lname.dispose();
    super.dispose();
  }

  @override
  void initState() {
    fnameError = null;
    lnameError = null;
    super.initState();
  }

  void resetErrorText() {
    setState(() {
      fnameError = null;
      lnameError = null;
    });
  }

  bool validFormat() {
    resetErrorText();
    bool isValid = true;
    if (fname.text.isEmpty) {
      setState(() => fnameError = 'Please enter your First Name');
      isValid = false;
    }
    if (lname.text.isEmpty) {
      setState(() => lnameError = 'Please enter your Last Name');
      isValid = false;
    }
    return isValid;
  }

  void enterAction(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!validFormat()) return;
    resetErrorText();

    showLoader(
      context,
      process: isConnected(true, context).then((isConnected) async {
        if (!isConnected) return null;
        return ref
            .read(activeUserProvider.notifier)
            .updateFullname(fname.text, lname.text)
            .then((_) => true);
      }).then((result) {
        if (result == null || !result) return;
        if (context.mounted) context.go('/home');
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
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
                  // @Graphic
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                    child: Image.asset(
                      'assets/images/displayname_graphic.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),

                  // @Page Title Label
                  const Entry.all(
                    delay: Duration(milliseconds: 50),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FormTitle(
                        'Welcome',
                        padding: EdgeInsets.symmetric(vertical: 5),
                      ),
                    ),
                  ),

                  // @Page Description
                  const Entry.all(
                    delay: Duration(milliseconds: 100),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppText.description16(NAMEPAGE_DESCRIPTION),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // @Input Fileds
                  Entry.all(
                    delay: const Duration(milliseconds: 150),
                    child: AppTextField(
                      labelText: 'First Name',
                      errorText: fnameError,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (fn) => setState(() => fnameError = null),
                      controller: fname,
                    ),
                  ),

                  Entry.all(
                    delay: const Duration(milliseconds: 200),
                    child: AppTextField(
                      labelText: 'Last Name',
                      errorText: lnameError,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      onChanged: (fn) => setState(() => lnameError = null),
                      controller: lname,
                    ),
                  ),

                  // @Enter Button
                  Entry.all(
                    delay: const Duration(milliseconds: 250),
                    child: AppFilledButton.big(
                      text: 'Enter',
                      icon: EvaIcons.personDoneOutline,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
                      onPressed: () => enterAction(context),
                    ),
                  ),
                  // @Enter Button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
