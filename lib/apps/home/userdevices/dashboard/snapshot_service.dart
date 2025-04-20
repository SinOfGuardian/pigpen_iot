import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class SnapshotService {
  static Future<void> takeSnapshotAndUpload({
    required String snapshotUrl,
    String? deviceId,
  }) async {
    try {
      print("📸 Snapshot request to: $snapshotUrl");
      final response = await http.get(Uri.parse(snapshotUrl));

      if (response.statusCode != 200) {
        throw Exception("Invalid HTTP response: ${response.statusCode}");
      }

      final Uint8List bytes = response.bodyBytes;
      final now = DateTime.now();
      final formatted = DateFormat('MM-dd-yyyy_HH-mm-ss').format(now);
      final fileName = 'snapshot_$formatted.jpg';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final storagePath = deviceId != null
          ? 'snapshots/$deviceId/$fileName'
          : 'snapshots/$fileName';

      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(file);

      print("✅ Snapshot uploaded to Firebase: $storagePath");
    } catch (e, stack) {
      print("❌ Snapshot error: $e");
      print(stack);
      rethrow;
    }
  }
}
