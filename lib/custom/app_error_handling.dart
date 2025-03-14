import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pigpen_iot/services/internet_connection.dart';


class AppErrorWidget extends StatelessWidget {
  final Exception exception;
  final Widget widget;
  final StackTrace stackTrace;
  const AppErrorWidget(this.exception, this.stackTrace, this.widget,
      {super.key});

  @override
  Widget build(context) {
    debugPrint('[widget]: ${widget.toString()}');
    debugPrint('[error]: $exception');
    debugPrintStack(stackTrace: stackTrace, maxFrames: 10);

    if (exception is TimeoutException) return const NoInternetWithIcon();
    return const ErrorEncountered();
  }
}

class ErrorEncountered extends StatelessWidget {
  const ErrorEncountered({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'There is an error encountered. '
        'Please report a bug or give us an feedback.',
      ),
    );
  }
}

class NoInternetWithIcon extends StatelessWidget with InternetConnection {
  final TimeoutException? e;
  const NoInternetWithIcon({super.key, this.e});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: colorScheme.outline),
          const SizedBox(height: 10),
          Text(
            noInternetTitle(),
            style: TextStyle(color: colorScheme.outline, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Text(
            'No internet Connection.',
            style: TextStyle(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
