import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';

import 'package:pigpen_iot/services/firestore_log_service.dart';

final logServiceProvider = Provider((ref) => FirestoreLogService());
final selectedHourProvider =
    StateProvider<String?>((ref) => null); // hour_06, hour_07 etc.
final selectedMinuteProvider =
    StateProvider<String?>((ref) => null); // minute_13, etc.
final selectedLogDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final deviceIdProvider = Provider<String>((ref) => 'pigpeniot_38eba81f8a3c');

final logsByDateProvider = FutureProvider<List<LogEntry>>((ref) async {
  final service = ref.read(logServiceProvider);
  final date = ref.watch(selectedLogDateProvider);
  final deviceId = ref.watch(deviceIdProvider);
  final hour = ref.watch(selectedHourProvider);
  final minute = ref.watch(selectedMinuteProvider);

  return await service.getLogsForDate(
    deviceId: deviceId,
    date: date,
    filterHour: hour,
    filterMinute: minute,
  );
});
