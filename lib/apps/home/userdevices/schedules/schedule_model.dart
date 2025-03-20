import 'package:flutter/foundation.dart';

@immutable
class Schedule {
  final String key;
  final DateTime dateTime;
  const Schedule({required this.dateTime, required this.key});
}
