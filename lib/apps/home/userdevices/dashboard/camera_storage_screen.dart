import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'snapshot_viewer_screen.dart';

class SnapshotImage {
  final String url;
  final String path;
  final DateTime date;

  SnapshotImage({required this.url, required this.path, required this.date});
}

class CameraStorageScreen extends StatefulWidget {
  const CameraStorageScreen({super.key});

  @override
  State<CameraStorageScreen> createState() => _CameraStorageScreenState();
}

class _CameraStorageScreenState extends State<CameraStorageScreen> {
  late Future<List<SnapshotImage>> _imageFutures;
  final Set<String> _selectedPaths = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _refreshImages();
  }

  Future<void> _refreshImages() async {
    setState(() {
      _imageFutures = _loadSnapshotImages();
      _selectedPaths.clear();
      _isSelectionMode = false;
    });
  }

  Future<List<SnapshotImage>> _loadSnapshotImages() async {
    final ListResult result =
        await FirebaseStorage.instance.ref("snapshots").listAll();

    final files = result.items.where((item) =>
        item.name.toLowerCase().endsWith('.jpg') ||
        item.name.toLowerCase().endsWith('.jpeg'));

    final images = await Future.wait(files.map((ref) async {
      final url = await ref.getDownloadURL();
      final metadata = await ref.getMetadata();
      final date = metadata.timeCreated ?? DateTime.now();
      return SnapshotImage(url: url, path: ref.fullPath, date: date);
    }));

    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
  }

  Map<String, List<SnapshotImage>> _groupByDate(List<SnapshotImage> images) {
    final Map<String, List<SnapshotImage>> grouped = {};
    for (var image in images) {
      final dateKey =
          "${image.date.year}-${image.date.month.toString().padLeft(2, '0')}-${image.date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(image);
    }
    return grouped;
  }

  void _toggleSelect(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  Future<void> _deleteSelected() async {
    for (final path in _selectedPaths) {
      await FirebaseStorage.instance.ref(path).delete();
    }
    _refreshImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? "${_selectedPaths.length} selected"
            : "Camera Storage"),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedPaths.isEmpty ? null : _deleteSelected,
            ),
        ],
      ),
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

          final groupedImages = _groupByDate(images);

          return RefreshIndicator(
            onRefresh: _refreshImages,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: groupedImages.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entry.value.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final image = entry.value[index];
                      final isSelected = _selectedPaths.contains(image.path);

                      return GestureDetector(
                        onLongPress: () {
                          setState(() => _isSelectionMode = true);
                          _toggleSelect(image.path);
                        },
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelect(image.path);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SnapshotViewerScreen(
                                  imageUrl: image.url,
                                  storagePath: image.path,
                                ),
                              ),
                            ).then((_) => _refreshImages());
                          }
                        },
                        child: Stack(
                          children: [
                            Image.network(image.url, fit: BoxFit.cover),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Icon(Icons.check_circle,
                                    color: Colors.blueAccent.withOpacity(0.9)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ];
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
