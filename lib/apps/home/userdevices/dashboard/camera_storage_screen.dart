import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pigpen_iot/custom/loader_dialog.dart';
import 'package:pigpen_iot/services/video_conversion_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'snapshot_viewer_screen.dart';
import 'video_player_screen.dart';

class SnapshotImage {
  final String url;
  final String path;
  final DateTime date;
  final bool isVideo;
  final String? localThumbnailPath;

  SnapshotImage({
    required this.url,
    required this.path,
    required this.date,
    required this.isVideo,
    this.localThumbnailPath,
  });
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
  bool _isGridView = true;
  List<SnapshotImage> _allImages = [];

  @override
  void initState() {
    super.initState();
    _refreshImages();
  }

  Future<void> _refreshImages() async {
    setState(() {
      _imageFutures = _loadMediaItems();
      _selectedPaths.clear();
      _isSelectionMode = false;
    });
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${cacheDir.path}/thumbnails');

      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      final thumbnailFileName = '${md5.convert(utf8.encode(videoUrl))}.jpg';
      final thumbnailPath = '${thumbnailsDir.path}/$thumbnailFileName';

      final file = File(thumbnailPath);
      if (await file.exists()) return thumbnailPath;

      final generatedPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: thumbnailsDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      return generatedPath;
    } catch (e) {
      debugPrint("⚠️ Thumbnail generation failed: $e");
      return null;
    }
  }

  Future<List<SnapshotImage>> _loadMediaItems() async {
    final List<SnapshotImage> allItems = [];

    final snapshotResult =
        await FirebaseStorage.instance.ref("snapshots").listAll();
    final snapshotFutures = snapshotResult.items.map((ref) async {
      if (ref.name.endsWith('.jpg') || ref.name.endsWith('.jpeg')) {
        final url = await ref.getDownloadURL();
        final metadata = await ref.getMetadata();
        return SnapshotImage(
          url: url,
          path: ref.fullPath,
          date: metadata.timeCreated ?? DateTime.now(),
          isVideo: false,
        );
      }
      return null;
    });

    final List<Reference> recordingFolders = [
      FirebaseStorage.instance.ref("recordings"),
      FirebaseStorage.instance.ref("recordings/recordings"),
    ];

    final List<Future<SnapshotImage?>> videoFutures = [];

    for (final folder in recordingFolders) {
      final result = await folder.listAll();
      for (final ref in result.items) {
        if (ref.name.endsWith('.mp4') ||
            ref.name.endsWith('.avi') ||
            ref.name.endsWith('.mjpg') ||
            ref.name.endsWith('.mjpeg')) {
          videoFutures.add(() async {
            final url = await ref.getDownloadURL();
            final metadata = await ref.getMetadata();
            String? thumbnailPath;

            if (ref.name.endsWith('.mp4') || ref.name.endsWith('.avi')) {
              thumbnailPath = await _generateThumbnail(url);
            }

            return SnapshotImage(
              url: url,
              path: ref.fullPath,
              date: metadata.timeCreated ?? DateTime.now(),
              isVideo: true,
              localThumbnailPath: thumbnailPath,
            );
          }());
        }
      }
    }

    final results = await Future.wait([...snapshotFutures, ...videoFutures]);
    allItems.addAll(results.whereType<SnapshotImage>());
    allItems.sort((a, b) => b.date.compareTo(a.date));
    _allImages = allItems;
    return allItems;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Selected"),
        content: const Text("Are you sure you want to delete these items?"),
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

    if (confirmed == true) {
      for (final path in _selectedPaths) {
        await FirebaseStorage.instance.ref(path).delete();
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Items deleted.")));
      _refreshImages();
    }
  }

  Future<void> _shareSelected() async {
    final files = _allImages.where((img) => _selectedPaths.contains(img.path));
    final tempDir = await getTemporaryDirectory();
    final filePaths = <String>[];

    for (final image in files) {
      final response = await http.get(Uri.parse(image.url));
      final file = File('${tempDir.path}/${image.path.split('/').last}');
      await file.writeAsBytes(response.bodyBytes);
      filePaths.add(file.path);
    }

    await Share.shareXFiles(filePaths.map((p) => XFile(p)).toList());
  }

  Map<String, List<SnapshotImage>> _groupByDate(List<SnapshotImage> items) {
    final Map<String, List<SnapshotImage>> grouped = {};
    for (var item in items) {
      final dateKey =
          "${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }
    return grouped;
  }

  void _openViewer(SnapshotImage item) async {
    if (item.isVideo) {
      if (item.path.endsWith('.mjpg') || item.path.endsWith('.mjpeg')) {
        final resultUrl = await showDialog<String?>(
          context: context,
          barrierDismissible: false,
          builder: (_) => LoaderDialog(
            onConfirm: ({required onLog, required onProgress}) =>
                VideoConversionService.convertAndUploadMjpg(
              mjpgUrl: item.url,
              storagePath: item.path,
              onLog: onLog,
              onProgress: onProgress,
            ),
          ),
        );

        if (resultUrl != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoUrl: resultUrl),
            ),
          );
          await _refreshImages();
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(videoUrl: item.url),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SnapshotViewerScreen(
            imageUrl: item.url,
            storagePath: item.path,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text("${_selectedPaths.length} selected")
            : const Text("Camera Storage"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          if (_isSelectionMode) ...[
            IconButton(
                icon: const Icon(Icons.share), onPressed: _shareSelected),
            IconButton(
                icon: const Icon(Icons.delete), onPressed: _deleteSelected),
          ]
        ],
      ),
      body: FutureBuilder<List<SnapshotImage>>(
        future: _imageFutures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final grouped = _groupByDate(snapshot.data!);

          return RefreshIndicator(
            onRefresh: _refreshImages,
            child: ListView(
              children: grouped.entries.expand((entry) {
                final items = entry.value;
                return [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected =
                                _selectedPaths.contains(item.path);
                            return GestureDetector(
                              onTap: () => _isSelectionMode
                                  ? _toggleSelect(item.path)
                                  : _openViewer(item),
                              onLongPress: () {
                                setState(() => _isSelectionMode = true);
                                _toggleSelect(item.path);
                              },
                              child: Stack(
                                children: [
                                  item.isVideo
                                      ? (item.localThumbnailPath != null
                                          ? Image.file(
                                              File(item.localThumbnailPath!),
                                              fit: BoxFit.cover)
                                          : const Icon(Icons.videocam,
                                              size: 48))
                                      : Image.network(item.url,
                                          fit: BoxFit.cover),
                                  if (isSelected)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(Icons.check_circle,
                                          color: Colors.blue),
                                    ),
                                ],
                              ),
                            );
                          },
                        )
                      : Column(
                          children: items.map((item) {
                            final isSelected =
                                _selectedPaths.contains(item.path);
                            return ListTile(
                              leading: item.isVideo
                                  ? (item.localThumbnailPath != null
                                      ? Image.file(
                                          File(item.localThumbnailPath!),
                                          width: 60,
                                          height: 60)
                                      : const Icon(Icons.videocam))
                                  : Image.network(item.url,
                                      width: 60, height: 60),
                              title: Text(item.path.split('/').last),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.blueAccent)
                                  : null,
                              onTap: () => _isSelectionMode
                                  ? _toggleSelect(item.path)
                                  : _openViewer(item),
                              onLongPress: () {
                                setState(() => _isSelectionMode = true);
                                _toggleSelect(item.path);
                              },
                            );
                          }).toList(),
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
