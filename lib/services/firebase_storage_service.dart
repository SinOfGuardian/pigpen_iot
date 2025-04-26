import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Deep recursive list
  Future<List<Reference>> listAllLogs(String deviceId) async {
    final List<Reference> allRefs = [];

    Future<void> _recursiveList(Reference ref) async {
      final result = await ref.listAll();
      allRefs.addAll(result.items); // Add files
      for (final folder in result.prefixes) {
        await _recursiveList(folder); // Dive into subfolders
      }
    }

    final rootRef = _storage.ref().child('logs/$deviceId');
    await _recursiveList(rootRef);

    return allRefs;
  }

  Future<Map<String, dynamic>> downloadLog(Reference ref) async {
    final data = await ref.getData();
    if (data == null) throw Exception("No data found for ${ref.fullPath}");

    final jsonString = utf8.decode(data);
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return jsonData;
  }
}
