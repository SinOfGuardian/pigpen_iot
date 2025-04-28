import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Deep recursive list of all log files under deviceId
  Future<List<Reference>> listAllLogs(String deviceId) async {
    final List<Reference> allRefs = [];

    Future<void> recursiveList(Reference ref) async {
      final result = await ref.listAll();
      allRefs.addAll(result.items); // Add files
      for (final folder in result.prefixes) {
        await recursiveList(folder); // Dive into subfolders
      }
    }

    final rootRef = _storage.ref().child('logs/$deviceId');
    try {
      await recursiveList(rootRef);
      print('Total files found: ${allRefs.length}');
      return allRefs;
    } catch (e) {
      print('Error listing logs: $e');
      rethrow;
    }
  }

  /// Download and decode JSON log file
  Future<Map<String, dynamic>> downloadLog(Reference ref) async {
    try {
      final data = await ref.getData(1024 * 1024); // Max 1MB
      if (data == null) throw Exception("No data found for ${ref.fullPath}");

      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      print('Downloaded log: ${ref.name}');
      return jsonData;
    } catch (e) {
      print('Error downloading log ${ref.fullPath}: $e');
      rethrow;
    }
  }
}
