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

    final doc = await _firestore.collection('logs').doc(deviceId).get();
    if (!doc.exists) return [];

    final rawData = doc.data() ?? {};
    if (!rawData.containsKey(year) ||
        !(rawData[year] as Map).containsKey(month) ||
        !(rawData[year][month] as Map).containsKey(day)) return [];

    final dayData = Map<String, dynamic>.from(rawData[year][month][day]);
    final List<LogEntry> entries = [];

    for (final hourEntry in dayData.entries) {
      final hour = hourEntry.key;
      if (filterHour != null && hour != filterHour) continue;

      final hourMap = Map<String, dynamic>.from(hourEntry.value);

      for (final minuteEntry in hourMap.entries) {
        final minute = minuteEntry.key;
        if (filterMinute != null && minute != filterMinute) continue;

        final dataMap = Map<String, dynamic>.from(minuteEntry.value);

        final double temp = (dataMap['temperature'] ?? 0).toDouble();
        final double gas = (dataMap['gas_detection'] ?? 0).toDouble();
        final double humid = (dataMap['humidity'] ?? 0).toDouble();
        final double heatIndex = (dataMap['heat_index'] ?? 0).toDouble();

        // Apply range filters
        if ((tempRange?.item1 != null && temp < tempRange!.item1!) ||
            (tempRange?.item2 != null && temp > tempRange!.item2!)) continue;
        if ((gasRange?.item1 != null && gas < gasRange!.item1!) ||
            (gasRange?.item2 != null && gas > gasRange!.item2!)) continue;
        if ((humidRange?.item1 != null && humid < humidRange!.item1!) ||
            (humidRange?.item2 != null && humid > humidRange!.item2!)) continue;
        if ((heatindexRange?.item1 != null &&
                heatIndex < heatindexRange!.item1!) ||
            (heatindexRange?.item2 != null &&
                heatIndex > heatindexRange!.item2!)) continue;

        entries.add(
          LogEntry(
            time: "${hour.split('_')[1]}:${minute.split('_')[1]}",
            temperature: temp,
            humidity: humid,
            heatIndex: heatIndex,
            gasDetection: gas,
          ),
        );
      }
    }

    entries.sort((a, b) => a.time.compareTo(b.time));
    return entries;
  }
}
