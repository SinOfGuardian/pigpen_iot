// logs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'logs_model.dart';

final dailyLogsProvider = FutureProvider.family
    .autoDispose<List<LogEntry>, LogQueryParams>((ref, params) async {
  final dbRef = FirebaseDatabase.instance.ref(
    'realtime/logs/${params.deviceId}'
    '/year_${params.year}'
    '/month_${params.month.toString().padLeft(2, '0')}'
    '/day_${params.day.toString().padLeft(2, '0')}',
  );

  try {
    final snapshot = await dbRef.get().timeout(const Duration(seconds: 10));

    if (!snapshot.exists || snapshot.value == null) return <LogEntry>[];

    final Map<dynamic, dynamic> dayData =
        snapshot.value as Map<dynamic, dynamic>;

    final List<LogEntry> allLogs = [];

    for (final hourEntry in dayData.entries) {
      final hourKey = hourEntry.key as String;
      final hourValue = hourEntry.value;

      // Example: "hour_01" to 1 ➔ minus 1 ➔ becomes 0
      int hour = int.tryParse(hourKey.replaceFirst('hour_', '')) ?? 0;
      hour = (hour - 1).clamp(0, 23);

      if (hourValue is Map<dynamic, dynamic>) {
        for (final minuteEntry in hourValue.entries) {
          final minuteValue = minuteEntry.value;

          if (minuteValue is Map<dynamic, dynamic>) {
            for (final logEntry in minuteValue.entries) {
              final logString = logEntry.value;

              if (logString is String && logString.trim().isNotEmpty) {
                try {
                  final entry = LogEntry.fromRawString(logString);
                  allLogs.add(entry);
                } catch (e) {
                  print('Failed to parse log: $e');
                  continue; // Skip bad formatted log
                }
              }
            }
          }
        }
      }
    }

    allLogs.sort((a, b) => a.time.compareTo(b.time)); // sort ascending by time
    return allLogs;
  } catch (e) {
    print('Error fetching daily logs: $e');
    return <LogEntry>[];
  }
});
