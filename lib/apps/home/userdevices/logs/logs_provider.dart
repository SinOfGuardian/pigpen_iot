// logs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'logs_model.dart';

final logsStreamProvider = StreamProvider.family
    .autoDispose<List<LogEntry>, LogQueryParams>((ref, params) {
  final dbRef = FirebaseDatabase.instance.ref(
    'realtime/logs/${params.deviceId}'
    '/year_${params.year}'
    '/month_${params.month.toString().padLeft(2, '0')}'
    '/day_${params.day.toString().padLeft(2, '0')}'
    '/hour_${params.hour.toString().padLeft(2, '0')}'
    '/minute_${params.minute.toString().padLeft(2, '0')}',
  );

  final stream =
      dbRef.onValue.timeout(const Duration(seconds: 10)).map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return <LogEntry>[];

    final logs = data.entries.map((e) {
      return LogEntry.fromRawString(e.value.toString());
    }).toList();

    logs.sort((a, b) => a.time.compareTo(b.time)); // Ascending
    return logs;
  }).handleError((error) {
    print('Stream error: $error');
    return <LogEntry>[];
  });

  return stream;
});
