import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:pigpen_iot/services/firebase_storage_service.dart';

// Provide the Firebase storage service
final firebaseStorageServiceProvider =
    Provider((ref) => FirebaseStorageService());

// Provide the list of logs
final logListProvider = FutureProvider<List<LogModel>>((ref) async {
  final service = ref.read(firebaseStorageServiceProvider);
  final deviceId = "pigpeniot-38eba81f8a3c"; // Later: make it dynamic

  final refs = await service.listAllLogs(deviceId);

  List<LogModel> logs = [];

  for (final refItem in refs) {
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

  logs.sort((a, b) => b.date.compareTo(a.date)); // Newest first

  return logs;
});
