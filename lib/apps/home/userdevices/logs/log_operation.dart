import 'package:firebase_database/firebase_database.dart';

class LogOperations {
  final database = FirebaseDatabase.instance;
  final String logPath = '/realtime/logs/';

  Future<void> addToLogs({
    required String deviceId,
    required String scheduleKey,
    required String category,
    required DateTime dateTime,
    required String status, // 'success', 'failed', 'timeout'
  }) async {
    await database.ref('$logPath$deviceId/$scheduleKey').set({
      'category': category,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'loggedAt': DateTime.now().toIso8601String(),
    });
  }
}
