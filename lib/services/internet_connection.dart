import 'dart:math';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pigpen_iot/extensions/app_snackbar.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';

const List<String> _noInternetMessages = [
  'Oh no!',
  'Oh snap!',
  'Not again!',
  'Oops!',
  'Uh oh!',
  'Whoops!',
  'Yikes!',
];

mixin InternetConnection {
  String noInternetTitle() {
    final random = Random();
    return _noInternetMessages[random.nextInt(_noInternetMessages.length)].toTitleCase();
  }

  Future<bool> isConnected([bool showSnackbar = false, BuildContext? context]) async {
    return InternetConnectionChecker.instance.hasConnection.then((value) {
      if (!value && showSnackbar && context != null && context.mounted) {
        context.showSnackBar(kNoInternet, theme: SnackbarTheme.error);
      }
      return value;
    });
  }
}

