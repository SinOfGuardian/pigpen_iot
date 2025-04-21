import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

class SnapshotViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String storagePath;

  const SnapshotViewerScreen({
    super.key,
    required this.imageUrl,
    required this.storagePath,
  });

  Future<void> _shareImage() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final tempDir = await Directory.systemTemp.createTemp();
      final file = File('${tempDir.path}/shared.jpg');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out this snapshot!');
    } catch (e) {
      print("❌ Error sharing image: $e");
    }
  }

  Future<void> _deleteImage(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete snapshot?"),
        content:
            const Text("This will permanently delete the image from Firebase."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseStorage.instance.ref(storagePath).delete();
        Navigator.pop(context); // Go back to gallery after delete
      } catch (e) {
        print("❌ Error deleting image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareImage),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteImage(context)),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
