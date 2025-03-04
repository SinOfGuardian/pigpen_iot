import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_icon.dart';


class AppTextField extends StatelessWidget {
  final String labelText;
  final Function(String)? onChanged;
  final Function()? onSubmitted;
  final Function()? onTapped;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool autoFocus;
  final bool obscureText;
  final TextEditingController? controller;
  final bool readOnly;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final FloatingLabelBehavior floatingLabelBehavior;
  final Function()? onSuffixIconTapped;

  const AppTextField({
    required this.labelText,
    required this.controller,
    required this.errorText,
    required this.textInputAction,
    this.onTapped,
    this.onSubmitted,
    this.keyboardType,
    this.onChanged,
    this.autoFocus = false,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIconData,
    this.suffixIconData,
    this.onSuffixIconTapped,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacer = MediaQuery.of(context).size.height * 0.008;

    const textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: colorScheme.outline,
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: spacer),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        onChanged: onChanged,
        onSubmitted: (text) => onSubmitted != null ? onSubmitted!() : () {},
        onTap: onTapped,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        readOnly: readOnly,
        style: textStyle,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          filled: true,
          fillColor: colorScheme.surfaceContainer,
          labelStyle: labelStyle,
          floatingLabelBehavior: floatingLabelBehavior,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          prefixIcon: prefixIconData == null
              ? null
              : AppIcon(
                  prefixIconData!,
                  color: colorScheme.outline,
                  // weight: FontWeight.normal,
                ),
          suffixIcon: suffixIconData == null
              ? null
              : IconButton(
                  icon: AppIcon(
                    suffixIconData!,
                    color: colorScheme.outline,
                    // weight: FontWeight.normal,
                  ),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: onSuffixIconTapped,
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class InputPasswordField extends StatelessWidget {
  final String labelText;
  final Function(String)? onChanged;
  final Function()? onSubmitted;
  final Function()? onTapped;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool autoFocus;
  final TextEditingController? controller;
  final bool readOnly;
  final Function() onEyePressed;
  final bool? showPassword;

  const InputPasswordField(
      {required this.labelText,
      required this.controller,
      required this.errorText,
      required this.onEyePressed,
      required this.textInputAction,
      this.onSubmitted,
      this.onTapped,
      this.keyboardType,
      this.onChanged,
      this.autoFocus = false,
      this.readOnly = false,
      required this.showPassword,
      super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      labelText: labelText,
      errorText: errorText,
      obscureText: !showPassword!,
      textInputAction: textInputAction,
      controller: controller,
      onSuffixIconTapped: onEyePressed,
      suffixIconData: showPassword!
          ? Icons.visibility_rounded
          : Icons.visibility_off_rounded,
    );
  }
}

class RoleSelectionField extends StatelessWidget {
  final String labelText;
  final String initialRole;
  final List<String> roles;
  final ValueChanged<String> onRoleSelected;
  final bool isEditing;

  const RoleSelectionField({
    Key? key,
    required this.labelText,
    required this.initialRole,
    required this.roles,
    required this.onRoleSelected,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialRole);

    return AppTextField(
      labelText: labelText,
      controller: controller,
      errorText: null,
      textInputAction: TextInputAction.done,
      readOnly: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      onTapped: isEditing
          ? null
          : () async {
              final selectedRole = await _showRoleSelectionDialog(context);
              if (selectedRole != null) {
                controller.text = selectedRole;
                onRoleSelected(selectedRole);
              }
            },
      suffixIconData: isEditing ? null : Icons.arrow_drop_down,
    );
  }

  Future<String?> _showRoleSelectionDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Role',
            style: TextStyle(color: colorScheme.primary),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: roles.length,
              itemBuilder: (BuildContext context, int index) {
                final role = roles[index];
                return ListTile(
                  title: Text(role),
                  onTap: () => Navigator.pop(context, role),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class StatusSelectionField extends StatelessWidget {
  final String labelText;
  final String initialRole;
  final List<String> status;
  final ValueChanged<String> onStatusSelected;
  final bool isEditing;

  const StatusSelectionField({
    Key? key,
    required this.labelText,
    required this.initialRole,
    required this.status,
    required this.onStatusSelected,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialRole);

    return AppTextField(
      labelText: labelText,
      controller: controller,
      errorText: null,
      textInputAction: TextInputAction.done,
      readOnly: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      onTapped: isEditing
          ? null
          : () async {
              final selectedStatus = await _showStatusSelectionDialog(context);
              if (selectedStatus != null) {
                controller.text = selectedStatus;
                onStatusSelected(selectedStatus);
              }
            },
      suffixIconData: Icons.arrow_drop_down,
    );
  }

  Future<String?> _showStatusSelectionDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Status',
            style: TextStyle(color: colorScheme.primary),
          ),
          content: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainer,
            ),
            child: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: status.length,
                itemBuilder: (BuildContext context, int index) {
                  final role = status[index];
                  return ListTile(
                    title: Text(role),
                    onTap: () => Navigator.pop(context, role),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppDataField extends StatelessWidget {
  final String labelText;
  final String? value;
  final IconData? prefixIconData;

  const AppDataField({
    required this.labelText,
    required this.value,
    this.prefixIconData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final spacer = MediaQuery.of(context).size.height * 0.008;

    final textStyle = textTheme.labelLarge;
    final labelStyle = textTheme.bodyLarge;

    return Container(
      margin: EdgeInsets.symmetric(vertical: spacer),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: value),
        readOnly: true,
        style: textStyle,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: labelStyle,
          filled: true,
          fillColor: colorScheme.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          prefixIcon: prefixIconData == null
              ? null
              : AppIcon(
                  prefixIconData!,
                  color: colorScheme.outline,
                  weight: FontWeight.normal,
                ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
