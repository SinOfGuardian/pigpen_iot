import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/userdevices/schedules/schedule_model.dart';
import 'package:pigpen_iot/modules/database.dart';

final schedulesStreamProvider =
    StreamProvider.family.autoDispose<DatabaseEvent, String>((ref, deviceId) {
  final database = ScheduleOperations();
  return database.listenToSchedules(deviceId);
});

DateTime _parseDateTime(dynamic value) {
  if (value is Map && value['dateTime'] != null) {
    return DateTime.parse(value['dateTime'].toString());
  } else if (value is String) {
    return DateTime.parse(value);
  }
  return DateTime.now(); // fallback
}

final schedulesProvider = FutureProvider.family
    .autoDispose<List<Schedule>, String>((ref, deviceId) async {
  return ref
      .watch(schedulesStreamProvider(deviceId).future)
      .then((databaseEvent) async {
    List<Schedule> schedules = [];

    if (databaseEvent.snapshot.exists) {
      final unSortedSchedules =
          databaseEvent.snapshot.value as Map<Object?, Object?>;
      final sortedSchedules = SplayTreeMap<Object?, Object?>.from(
        unSortedSchedules,
        (a, b) {
          final aDate = _parseDateTime(unSortedSchedules[a]);
          final bDate = _parseDateTime(unSortedSchedules[b]);
          return aDate.compareTo(bDate);
        },
      );

      final now = DateTime.now();
      sortedSchedules.removeWhere((key, value) {
        final dateTime = _parseDateTime(value);
        return dateTime.isBefore(now);
      });

      if (sortedSchedules.length != unSortedSchedules.length) {
        final database = ScheduleOperations();
        await database.overwriteSchedules(deviceId, sortedSchedules);
      }

      sortedSchedules.forEach((key, value) {
        if (value is Map) {
          final dateTime = DateTime.parse(value['dateTime'].toString());
          final category =
              value['category']?.toString() ?? 'shower'; // default fallback
          schedules.add(Schedule(
            key: key.toString(),
            dateTime: dateTime,
            category: category,
          ));
        }
      });
    }

    await Future.delayed(const Duration(seconds: 1));
    return schedules;
  });
});

/// Schedule-page viewmodels
final dateTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dateController = StateProvider.autoDispose<TextEditingController>(
    (ref) => TextEditingController());
final timeController = StateProvider.autoDispose<TextEditingController>(
    (ref) => TextEditingController());
final dateErrorProvider = StateProvider.autoDispose<String?>((ref) => null);
final timeErrorProvider = StateProvider.autoDispose<String?>((ref) => null);
