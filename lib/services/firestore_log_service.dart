import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:tuple/tuple.dart';

class FirestoreLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LogEntry>> getLogsForDate({
    required String deviceId,
    required DateTime date,
    String? filterHour,
    String? filterMinute,
    Tuple2<double?, double?>? tempRange,
    Tuple2<double?, double?>? gasRange,
    Tuple2<double?, double?>? humidRange,
    Tuple2<double?, double?>? heatindexRange,
  }) async {
    final year = 'year_${date.year}';
    final month = 'month_${date.month.toString().padLeft(2, '0')}';
    final day = 'day_${date.day.toString().padLeft(2, '0')}';

    final entries = <LogEntry>[];

    for (int hour = 0; hour < 24; hour++) {
      final hourKey = 'hour_${hour.toString().padLeft(2, '0')}';

      if (filterHour != null && filterHour != hourKey) continue;

      final docPath = _firestore
          .collection('logs')
          .doc(deviceId)
          .collection(year)
          .doc(month)
          .collection(day)
          .doc(hourKey);

      final doc = await docPath.get();
      if (!doc.exists) continue;

      final hourData = doc.data() as Map<String, dynamic>;

      for (final entry in hourData.entries) {
        final minuteKey = entry.key;
        if (filterMinute != null && minuteKey != filterMinute) continue;

        final data = Map<String, dynamic>.from(entry.value);
        final double temp = (data['temperature'] ?? 0).toDouble();
        final double gas = (data['gas_detection'] ?? 0).toDouble();
        final double humid = (data['humidity'] ?? 0).toDouble();
        final double heatIndex = (data['heat_index'] ?? 0).toDouble();

        // Apply range filters
        if ((tempRange?.item1 != null && temp < tempRange!.item1!) ||
            (tempRange?.item2 != null && temp > tempRange!.item2!)) {
          continue;
        }
        if ((gasRange?.item1 != null && gas < gasRange!.item1!) ||
            (gasRange?.item2 != null && gas > gasRange!.item2!)) {
          continue;
        }
        if ((humidRange?.item1 != null && humid < humidRange!.item1!) ||
            (humidRange?.item2 != null && humid > humidRange!.item2!)) {
          continue;
        }
        if ((heatindexRange?.item1 != null &&
                heatIndex < heatindexRange!.item1!) ||
            (heatindexRange?.item2 != null &&
                heatIndex > heatindexRange!.item2!)) {
          continue;
        }

        entries.add(LogEntry(
          time: "${hour.toString().padLeft(2, '0')}:${minuteKey.split('_')[1]}",
          temperature: temp,
          humidity: humid,
          heatIndex: heatIndex,
          gasDetection: gas,
        ));
      }
    }

    entries.sort((a, b) => a.time.compareTo(b.time));
    return entries;
  }
}
