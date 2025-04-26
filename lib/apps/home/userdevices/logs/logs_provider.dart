import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:pigpen_iot/services/firebase_storage_service.dart';

// Provide FirebaseStorageService
final firebaseStorageServiceProvider =
    Provider((ref) => FirebaseStorageService());

// Provide the list of logs
final logListProvider = FutureProvider<List<LogModel>>((ref) async {
  final service = ref.read(firebaseStorageServiceProvider);

  final deviceId =
      "pigpeniot-38eba81f8a3c"; // <-- Update this if you want it dynamic

  // Get all the logs (deep scan)
  final refs = await service.listAllLogs(deviceId);
  List<LogModel> logs = [];

  for (final refItem in refs) {
    // Only JSON files
    if (refItem.name.endsWith('.json')) {
      final data = await service.downloadLog(refItem);
      final metadata = await refItem.getMetadata();
      final updatedAt = metadata.updated ?? DateTime.now();

      logs.add(LogModel(
        fileName: refItem.name,
        date: updatedAt,
        data: data,
      ));
    }
  }

  // Sort by newest first
  logs.sort((a, b) => b.date.compareTo(a.date));

  return logs;
});
