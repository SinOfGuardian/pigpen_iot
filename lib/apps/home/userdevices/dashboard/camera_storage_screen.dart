import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CameraStorageScreen extends StatefulWidget {
  const CameraStorageScreen({super.key});

  @override
  State<CameraStorageScreen> createState() => _CameraStorageScreenState();
}

class _CameraStorageScreenState extends State<CameraStorageScreen> {
  late Future<List<String>> _imageUrls;

  @override
  void initState() {
    super.initState();
    _imageUrls = _loadSnapshotUrls();
  }

  Future<List<String>> _loadSnapshotUrls() async {
    final ListResult result =
        await FirebaseStorage.instance.ref("snapshots").listAll();

    final files = result.items.where((item) {
      return item.name.toLowerCase().endsWith('.jpg') ||
          item.name.toLowerCase().endsWith('.jpeg');
    });

    final urls = await Future.wait(files.map((item) => item.getDownloadURL()));
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Snapshot Gallery")),
      body: FutureBuilder<List<String>>(
        future: _imageUrls,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading snapshots: ${snapshot.error}'));
          }

          final urls = snapshot.data!;
          if (urls.isEmpty) {
            return const Center(child: Text("No snapshots found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Image.network(
                urls[index],
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
    );
  }
}
