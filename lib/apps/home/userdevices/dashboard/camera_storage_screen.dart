import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'snapshot_viewer_screen.dart';

class SnapshotImage {
  final String url;
  final String path;

  SnapshotImage({required this.url, required this.path});
}

class CameraStorageScreen extends StatefulWidget {
  const CameraStorageScreen({super.key});

  @override
  State<CameraStorageScreen> createState() => _CameraStorageScreenState();
}

class _CameraStorageScreenState extends State<CameraStorageScreen> {
  late Future<List<SnapshotImage>> _imageFutures;

  @override
  void initState() {
    super.initState();
    _imageFutures = _loadSnapshotImages();
  }

  Future<List<SnapshotImage>> _loadSnapshotImages() async {
    final ListResult result =
        await FirebaseStorage.instance.ref("snapshots").listAll();

    final files = result.items.where((item) {
      return item.name.toLowerCase().endsWith('.jpg') ||
          item.name.toLowerCase().endsWith('.jpeg');
    });

    final images = await Future.wait(files.map((ref) async {
      final url = await ref.getDownloadURL();
      return SnapshotImage(url: url, path: ref.fullPath);
    }));

    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Snapshot Gallery")),
      body: FutureBuilder<List<SnapshotImage>>(
        future: _imageFutures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading snapshots: ${snapshot.error}'));
          }

          final images = snapshot.data!;
          if (images.isEmpty) {
            return const Center(child: Text("No snapshots found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SnapshotViewerScreen(
                        imageUrl: image.url,
                        storagePath: image.path,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  image.url,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
