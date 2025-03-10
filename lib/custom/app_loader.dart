import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_circularprogressindicator.dart';
import 'package:pigpen_iot/extensions/app_snackbar.dart';

Future<T?> showLoader<T>(BuildContext context,
    {FutureOr<T?>? process,
    Duration delay = const Duration(milliseconds: 500)}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (_) => const PopScope(
      canPop: false,
      child: AppCircularProgressIndicatorWithShadow(),
    ),
  );
  return Future.delayed(delay).then((_) async {
    if (process == null) return Future.value(null);
    if (process is Future) return process;
    if (process is Function()) return process();
    return process;
  }).onError((e, st) {
    if (e is TimeoutException) {
      if (context.mounted) {
        context.showSnackBar('error: $kNoInternet',
            theme: SnackbarTheme.error);
      }
    } else {
      if (context.mounted) {
        context.showSnackBar(e.toString(), theme: SnackbarTheme.error);
      }
    }
    return Future.value(null);
  }).then((value) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    return value;
  });
}

Future<Object?> doInBackground({
  required BuildContext context,
  required Function() process,
  VoidCallback? callBack,
  int? delayMillis,
}) async {
  Object? result;
  try {
    result = await process();
    if (callBack != null) callBack();
  } on TimeoutException {
    if (context.mounted) {
      context.showSnackBar(kNoInternet, theme: SnackbarTheme.error);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  await Future.delayed(Duration(milliseconds: delayMillis ?? 0));
  return result;
}
