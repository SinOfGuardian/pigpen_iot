import 'package:flutter/foundation.dart';

@immutable
class Schedule {
  final String key;
  final DateTime dateTime;
  final String category; // "shower" or "feeding"

  const Schedule({
    required this.dateTime,
    required this.key,
    required this.category,
  });
}
