import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:tuple/tuple.dart';

import 'package:pigpen_iot/services/firestore_log_service.dart';

final logServiceProvider = Provider((ref) => FirestoreLogService());
final selectedHourProvider =
    StateProvider<String?>((ref) => null); // hour_06, hour_07 etc.
final selectedMinuteProvider =
    StateProvider<String?>((ref) => null); // minute_13, etc.
final selectedLogDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());
final tempRangeProvider =
    StateProvider<Tuple2<double?, double?>>((ref) => const Tuple2(null, null));
final gasRangeProvider =
    StateProvider<Tuple2<double?, double?>>((ref) => const Tuple2(null, null));
final humidRangeProvider =
    StateProvider<Tuple2<double?, double?>>((ref) => const Tuple2(null, null));
final heatindexRangeProvider =
    StateProvider<Tuple2<double?, double?>>((ref) => const Tuple2(null, null));

final deviceIdProvider = Provider<String>((ref) => 'pigpeniot_38eba81f8a3c');

final logsByDateProvider = FutureProvider<List<LogEntry>>((ref) async {
  final service = ref.read(logServiceProvider);
  final date = ref.watch(selectedLogDateProvider);
  final deviceId = ref.watch(deviceIdProvider);
  final hour = ref.watch(selectedHourProvider);
  final minute = ref.watch(selectedMinuteProvider);
  final tempRange = ref.watch(tempRangeProvider);
  final humidRange = ref.watch(humidRangeProvider);
  final heatindexRange = ref.watch(heatindexRangeProvider);
  final gasRange = ref.watch(gasRangeProvider);

  return await service.getLogsForDate(
    deviceId: deviceId,
    date: date,
    filterHour: hour,
    filterMinute: minute,
    tempRange: tempRange,
    humidRange: humidRange,
    heatindexRange: heatindexRange,
    gasRange: gasRange,
  );
});
