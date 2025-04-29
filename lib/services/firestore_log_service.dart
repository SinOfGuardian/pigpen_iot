import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';

class FirestoreLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LogEntry>> getLogsForDate({
    required String deviceId,
    required DateTime date,
    String? filterHour, // add these
    String? filterMinute,
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
        entries.add(
          LogEntry(
            time: "${hour.split('_')[1]}:${minute.split('_')[1]}",
            temperature: (dataMap['temperature'] ?? 0).toDouble(),
            humidity: (dataMap['humidity'] ?? 0).toDouble(),
            heatIndex: (dataMap['heat_index'] ?? 0).toDouble(),
            gasDetection: (dataMap['gas_detection'] ?? 0).toDouble(),
          ),
        );
      }
    }

    entries.sort((a, b) => a.time.compareTo(b.time));
    return entries;
  }
}
