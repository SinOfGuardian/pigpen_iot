// ignore_for_file: use_build_context_synchronously

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_circularprogressindicator.dart';
import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_error_handling.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/app_menu_tile.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/single_info.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';
import 'package:pigpen_iot/custom/ui_avatar_icon.dart';
import 'package:pigpen_iot/extensions/app_snackbar.dart';
import 'package:pigpen_iot/models/user_model.dart';
import 'package:pigpen_iot/provider/user_provider.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class ProfileScreen extends ConsumerWidget with InternetConnection {
  const ProfileScreen({super.key});

  Widget _userInfos(BuildContext context, PigpenUser user) {
    // final colorScheme = Theme.of(context).colorScheme;
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleInfo(text: user.fullname, label: 'Name'),
        SingleInfo(text: user.email, label: 'Email'),
        DoubleInfo(
          label1: 'Date Registered',
          info1: user.dateRegistered,
          flex1: 2,
          label2: 'Devices',
          info2: user.things.toString(),
          flex2: 1,
        ),
      ],
    );
  }

  Widget _singleData({required String label, required String value}) {
    return AppDataField(labelText: label, value: value);
  }

  Widget _doubleData(
      {required String label1,
      required String value1,
      int flex1 = 1,
      required String label2,
      required String value2,
      int flex2 = 1}) {
    return Row(
      children: [
        Expanded(flex: flex1, child: _singleData(label: label1, value: value1)),
        const SizedBox(width: 10),
        Expanded(flex: flex2, child: _singleData(label: label2, value: value2)),
      ],
    );
  }

  Widget _titleLabel(String title, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleSmall = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: colorScheme.primary);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: titleSmall),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = ref.watch(activeUserProvider);

    return Scaffold(
      appBar: TitledAppBar2(
        title: 'Profile',
        leadingAction: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SectionLabel('Personal Details'),
              userProvider.when(
                data: (user) {
                  return AppContainer(
                    color: isDark
                        ? colorScheme.surfaceContainer
                        : colorScheme.surfaceBright,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        AvatarIcon.big(
                            firstname: user.firstname, lastname: user.lastname),

                        // _userData(context, user),
                        _userInfos(context, user),
                      ],
                    ),
                  );
                },
                loading: () => const AppCircularProgressIndicator(),
                error: (e, st) => AppErrorWidget(e as Exception, st, this),
              ),
              AppContainer(
                color: isDark
                    ? colorScheme.surfaceContainer
                    : colorScheme.surfaceBright,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingTile(
                      title: 'Update Name',
                      leadingIcon: EvaIcons.editOutline,
                      callback: () => userProvider.whenData(
                        (user) => _updateNameDialog(context, ref),
                      ),
                    ),
                    SettingTile(
                      title: 'Change Password',
                      leadingIcon: EvaIcons.lockOutline,
                      callback: () => _updateChangePasswordDialog(context, ref),
                    ),
                  ],
                ),
              ),
              AppFilledButton.big(
                text: 'Sign out',
                buttonColor: Theme.of(context).colorScheme.error,
                icon: EvaIcons.logOutOutline,
                width: double.infinity,
                onPressed: () => _logoutAction(context),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateNameDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(activeUserProvider).value;
    if (user == null) return;

    final firstNameController = TextEditingController(text: user.firstname);
    final lastNameController = TextEditingController(text: user.lastname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleLabel('First Name :', context),
            AppTextField(
              controller: firstNameController,
              errorText: null,
              labelText: 'Enter First Name',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            const SizedBox(height: 10),
            _titleLabel('Last Name :', context),
            AppTextField(
              controller: lastNameController,
              errorText: null,
              labelText: 'Enter Last Name',
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedFirstName = firstNameController.text.trim();
              final updatedLastName = lastNameController.text.trim();

              if (updatedFirstName.isEmpty || updatedLastName.isEmpty) {
                context.showSnackBar('Both fields are required.',
                    theme: SnackbarTheme.warning);
                return;
              }

              try {
                await ref
                    .read(activeUserProvider.notifier)
                    .updateFullname(updatedFirstName, updatedLastName);

                if (context.mounted) {
                  context.showSnackBar('Name Updated Successfully',
                      theme: SnackbarTheme.success);
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  context.showSnackBar('Failed to update name: $e',
                      theme: SnackbarTheme.error);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool isCurrentPasswordVisible = false;
        bool isNewPasswordVisible = false;
        bool isConfirmPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _titleLabel('Change Password', context),
                    const SizedBox(height: 20),
                    AppTextField(
                      labelText: 'Enter Current Password',
                      controller: currentPasswordController,
                      errorText: null,
                      obscureText: !isCurrentPasswordVisible,
                      textInputAction: TextInputAction.next,
                      suffixIconData: isCurrentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconTapped: () {
                        setState(() {
                          isCurrentPasswordVisible = !isCurrentPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      labelText: 'Enter New Password',
                      controller: newPasswordController,
                      errorText: null,
                      obscureText: !isNewPasswordVisible,
                      textInputAction: TextInputAction.next,
                      suffixIconData: isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconTapped: () {
                        setState(() {
                          isNewPasswordVisible = !isNewPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      labelText: 'Confirm New Password',
                      controller: confirmPasswordController,
                      errorText: null,
                      obscureText: !isConfirmPasswordVisible,
                      textInputAction: TextInputAction.done,
                      suffixIconData: isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconTapped: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final currentPassword = currentPasswordController.text.trim();
                  final newPassword = newPasswordController.text.trim();
                  final confirmPassword = confirmPasswordController.text.trim();

                  if (currentPassword.isEmpty ||
                      newPassword.isEmpty ||
                      confirmPassword.isEmpty) {
                    context.showSnackBar('All fields are required.',
                        theme: SnackbarTheme.warning);
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    context.showSnackBar('Passwords do not match.',
                        theme: SnackbarTheme.warning);
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final credential = EmailAuthProvider.credential(
                      email: user!.email!,
                      password: currentPassword,
                    );

                    await user.reauthenticateWithCredential(credential);
                    await user.updatePassword(newPassword);

                    Navigator.pop(context);

                    context.showSnackBar('Password updated successfully.',
                        theme: SnackbarTheme.success);
                  } catch (error) {
                    context.showSnackBar('Error updating password: $error',
                        theme: SnackbarTheme.error);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  //LOG OUT ACTION COMBINED WITH GOOGLE SIGN OUT
  void _logoutAction(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    showLoader(context, process: isConnected(true, context))
        .then((result) async {
      if (result == null || !result) return;
      await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 5));
      await GoogleSignIn().signOut().timeout(const Duration(seconds: 5));
      //HERE THE GOOGLE SIGN OUT THIS TRY CATCH
      try {
        await auth.signOut();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
          if (FirebaseAuth.instance.currentUser != null) return;
        }
      } catch (e) {
        print('Error during sign-out: $e');
      }
      if (context.mounted) context.go('/signin');
    });
  }
}
