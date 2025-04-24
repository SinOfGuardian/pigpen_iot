import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class StorageService {
  Future<List<Map<String, dynamic>>> loadArchivedLogs(String deviceId) async {
    final ref = FirebaseStorage.instance.ref().child("logs/$deviceId.json");
    final url = await ref.getDownloadURL();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load archived logs');
    }

    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.cast<Map<String, dynamic>>();
  }
}
