import 'package:flutter/material.dart';

const String kNoInternet = 'Please check your internet connection';
const String kSomethingWentWrong = 'Something went wrong';

enum SnackbarTheme { none, success, warning, error, notif, info, black }

extension SnackbarExtension on BuildContext {
  void showSnackBar(
    String message, {
    bool showCloseIcon = false,
    SnackbarTheme theme = SnackbarTheme.none,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!mounted) return;

    final textDark =
        theme == SnackbarTheme.notif || theme == SnackbarTheme.none;
    final col = Theme.of(this).colorScheme;
    final textStyle = TextStyle(
      color: textDark ? col.onSurface : col.surface,
      // fontWeight: FontWeight.bold,
    );

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: SizedBox(child: Text(message, style: textStyle)),
        backgroundColor: _color(this, theme),
        elevation: 12,
        duration: duration,
        behavior: behavior,
        showCloseIcon: showCloseIcon,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      ),
    );
  }

  void showSnackBarTryAll(String message) {
    for (SnackbarTheme theme in SnackbarTheme.values) {
      showSnackBar(message, theme: theme);
    }
  }
}

Color _color(BuildContext context, SnackbarTheme theme) {
  final col = Theme.of(context).colorScheme;
  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

  final Map<SnackbarTheme, Color?> mappedColor = {
    SnackbarTheme.none: col.surface,
    SnackbarTheme.success: col.primary,
    SnackbarTheme.warning: Colors.orange,
    SnackbarTheme.error: isDarkTheme ? col.onError : col.error,
    SnackbarTheme.notif: col.tertiaryContainer,
    SnackbarTheme.info: Colors.grey,
    SnackbarTheme.black: col.onSurface,
  };
  return mappedColor[theme] as Color;
}
