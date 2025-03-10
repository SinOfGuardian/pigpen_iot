import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_icon.dart';


const double _kButtonElevation = 3;

const double _kBigButtonVerticalPadding = 14;
const double _kbigButtonHorizontalPadding = 20;
const double _kBigButtonIconSpacing = 10;

const double _kSmallButtonVerticalPadding = 8;
const double _kSmallButtonHorizontalPadding = 12;
const double _kSmallButtonIconSpacing = 5;

/// The primary button where the color depends on the primary color of the app
///
class AppNotFilledButton extends AppFilledButton {
  @override
  final String? text;
  @override
  final void Function()? onPressed;
  @override
  final IconData? icon;
  final Color? transparentButtonColor;
  @override
  final double? width;
  @override
  final EdgeInsetsGeometry? margin;
  @override
  final double? elevation;
  @override
  final double? verticalPadding;
  @override
  final double? horizontalPadding;
  @override
  final double? iconSpacing;
  @override
  final Alignment alignment;

  const AppNotFilledButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.transparentButtonColor,
    this.width,
    this.margin,
    this.elevation,
    this.verticalPadding,
    this.horizontalPadding,
    this.iconSpacing,
    this.alignment = Alignment.center,
  });

  const AppNotFilledButton.big({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.transparentButtonColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kBigButtonVerticalPadding,
    this.horizontalPadding = _kbigButtonHorizontalPadding,
    this.iconSpacing = _kBigButtonIconSpacing,
    this.alignment = Alignment.center,
  });
  const AppNotFilledButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.transparentButtonColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kSmallButtonVerticalPadding,
    this.horizontalPadding = _kSmallButtonHorizontalPadding,
    this.iconSpacing = _kSmallButtonIconSpacing,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    const buttonTextStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        margin: margin,
        child: OutlinedButton(
          onPressed: onPressed,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null ? AppIcon(icon!) : const SizedBox(),
              icon != null ? SizedBox(width: iconSpacing) : const SizedBox(),
              Text(text ?? '', style: buttonTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class AppFilledButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? buttonColor;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? iconSpacing;
  final Alignment alignment;

  const AppFilledButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.buttonColor,
    this.width,
    this.margin,
    this.elevation,
    this.verticalPadding,
    this.horizontalPadding,
    this.iconSpacing,
    this.alignment = Alignment.center,
  });

  const AppFilledButton.big({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kBigButtonVerticalPadding,
    this.horizontalPadding = _kbigButtonHorizontalPadding,
    this.iconSpacing = _kBigButtonIconSpacing,
    this.alignment = Alignment.center,
  });
  const AppFilledButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kSmallButtonVerticalPadding,
    this.horizontalPadding = _kSmallButtonHorizontalPadding,
    this.iconSpacing = _kSmallButtonIconSpacing,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    const buttonTextStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        margin: margin,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: elevation,
            backgroundColor: buttonColor,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 0,
              vertical: verticalPadding ?? 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null ? AppIcon(icon!) : const SizedBox(),
              icon != null ? SizedBox(width: iconSpacing) : const SizedBox(),
              Text(text ?? '', style: buttonTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// A button that doesn't have a filled color
class AppTextButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? buttonColor;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? iconSpacing;
  final Alignment alignment;
  const AppTextButton({
    this.text,
    this.icon,
    this.onPressed,
    this.buttonColor,
    this.width,
    this.margin,
    this.verticalPadding,
    this.horizontalPadding,
    this.iconSpacing,
    this.alignment = Alignment.center,
    super.key,
  });

  const AppTextButton.big({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.width,
    this.margin,
    this.verticalPadding = _kBigButtonVerticalPadding,
    this.horizontalPadding = _kbigButtonHorizontalPadding,
    this.iconSpacing = _kBigButtonIconSpacing,
    this.alignment = Alignment.center,
  });
  const AppTextButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.width,
    this.margin,
    this.verticalPadding = _kSmallButtonVerticalPadding,
    this.horizontalPadding = _kSmallButtonHorizontalPadding,
    this.iconSpacing = _kSmallButtonIconSpacing,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    const buttonTextStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        margin: margin,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            foregroundColor: buttonColor,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 0,
              vertical: verticalPadding ?? 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null ? AppIcon(icon!, size: 20) : const SizedBox(),
              icon != null ? SizedBox(width: iconSpacing) : const SizedBox(),
              Text(text ?? '', style: buttonTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button for delegate or cancel action
class AppElevatedButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? buttonColor;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? iconSpacing;
  final Alignment alignment;
  const AppElevatedButton({
    this.text,
    this.icon,
    this.onPressed,
    this.buttonColor,
    this.width,
    this.margin,
    this.elevation,
    this.verticalPadding,
    this.horizontalPadding,
    this.iconSpacing,
    this.alignment = Alignment.center,
    super.key,
  });

  const AppElevatedButton.big({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kBigButtonVerticalPadding,
    this.horizontalPadding = _kbigButtonHorizontalPadding,
    this.iconSpacing = _kBigButtonIconSpacing,
    this.alignment = Alignment.center,
  });
  const AppElevatedButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kSmallButtonVerticalPadding,
    this.horizontalPadding = _kSmallButtonHorizontalPadding,
    this.iconSpacing = _kSmallButtonIconSpacing,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    const buttonTextStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        margin: margin,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: elevation,
            surfaceTintColor: buttonColor,
            foregroundColor: buttonColor,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 0,
              vertical: verticalPadding ?? 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null
                  ? AppIcon(icon!, color: buttonColor, size: 20)
                  : const SizedBox(),
              icon != null ? SizedBox(width: iconSpacing) : const SizedBox(),
              Text(text ?? '', style: buttonTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tonal button
class AppTonalButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? buttonColor;
  final Color? backgroundColor;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? iconSpacing;
  final Alignment alignment;
  const AppTonalButton({
    this.text,
    this.icon,
    this.onPressed,
    this.buttonColor,
    this.backgroundColor,
    this.width,
    this.margin,
    this.elevation,
    this.verticalPadding,
    this.horizontalPadding,
    this.iconSpacing,
    this.alignment = Alignment.center,
    super.key,
  });

  const AppTonalButton.big({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.backgroundColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kBigButtonVerticalPadding,
    this.horizontalPadding = _kbigButtonHorizontalPadding,
    this.iconSpacing = _kBigButtonIconSpacing,
    this.alignment = Alignment.center,
  });
  const AppTonalButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.buttonColor,
    this.backgroundColor,
    this.width,
    this.margin,
    this.elevation = _kButtonElevation,
    this.verticalPadding = _kSmallButtonVerticalPadding,
    this.horizontalPadding = _kSmallButtonHorizontalPadding,
    this.iconSpacing = _kSmallButtonIconSpacing,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    const buttonTextStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        margin: margin,
        child: FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: elevation,
            foregroundColor: buttonColor,
            backgroundColor: backgroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 0,
              vertical: verticalPadding ?? 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null ? AppIcon(icon!, size: 20) : const SizedBox(),
              icon != null ? SizedBox(width: iconSpacing) : const SizedBox(),
              Text(text ?? '', style: buttonTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}
