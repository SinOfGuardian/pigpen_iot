import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:video_player/video_player.dart';

import 'snapshot_viewer_screen.dart';

class SnapshotImage {
  final String url;
  final String path;
  final DateTime date;
  final bool isVideo;

  SnapshotImage({
    required this.url,
    required this.path,
    required this.date,
    required this.isVideo,
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

  Future<List<SnapshotImage>> _loadMediaItems() async {
    final List<SnapshotImage> allItems = [];

    final snapshotResult =
        await FirebaseStorage.instance.ref("snapshots").listAll();
    for (var ref in snapshotResult.items) {
      if (ref.name.endsWith('.jpg') || ref.name.endsWith('.jpeg')) {
        final url = await ref.getDownloadURL();
        final metadata = await ref.getMetadata();
        final date = metadata.timeCreated ?? DateTime.now();
        allItems.add(SnapshotImage(
          url: url,
          path: ref.fullPath,
          date: date,
          isVideo: false,
        ));
      }
    }

    final videoRef = FirebaseStorage.instance.ref("recordings");
    final videoResult = await videoRef.listAll();

    // Convert any .mjpg files to .mp4 and wait for all conversions
    for (var ref in videoResult.items) {
      if (ref.name.endsWith('.mjpg')) {
        await _convertMjpgToMp4(ref);
      }
    }

    // Re-fetch the list after conversions to include .mp4
    final refreshedVideoResult = await videoRef.listAll();
    for (var ref in refreshedVideoResult.items) {
      if (ref.name.endsWith('.mp4')) {
        final url = await ref.getDownloadURL();
        final metadata = await ref.getMetadata();
        final date = metadata.timeCreated ?? DateTime.now();
        allItems.add(SnapshotImage(
          url: url,
          path: ref.fullPath,
          date: date,
          isVideo: true,
        ));
      }
    }

    allItems.sort((a, b) => b.date.compareTo(a.date));
    _allImages = allItems;
    return allItems;
  }

  Future<void> _convertMjpgToMp4(Reference mjpgRef) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = mjpgRef.name;
      final localMjpg = File('${dir.path}/$fileName');

      final downloadUrl = await mjpgRef.getDownloadURL();
      final response = await http.get(Uri.parse(downloadUrl));
      await localMjpg.writeAsBytes(response.bodyBytes);

      final mp4Path = localMjpg.path.replaceAll('.mjpg', '.mp4');
      final command =
          "-i ${localMjpg.path} -c:v libx264 -preset fast -crf 28 $mp4Path";
      await FFmpegKit.execute(command);

      final mp4File = File(mp4Path);
      final mp4Ref = FirebaseStorage.instance
          .ref("recordings/${mp4File.uri.pathSegments.last}");
      await mp4Ref.putFile(mp4File);

      await mjpgRef.delete();
      print("✅ Converted and uploaded: ${mp4Ref.name}");
    } catch (e) {
      print("❌ MJPG to MP4 conversion failed: $e");
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Items deleted successfully.")),
      );
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

  void _openViewer(SnapshotImage item) {
    if (item.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: item.url),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SnapshotViewerScreen(
            imageUrl: item.url,
            storagePath: item.path,
          ),
        ),
      ).then((_) => _refreshImages());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? "${_selectedPaths.length} selected"
            : "Camera Storage"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _selectedPaths.isEmpty ? null : _shareSelected,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedPaths.isEmpty ? null : _deleteSelected,
            ),
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
            return Center(
                child: Text('Error loading files: ${snapshot.error}'));
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No snapshots or videos found."));
          }

          final grouped = _groupByDate(items);

          return RefreshIndicator(
            onRefresh: _refreshImages,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: grouped.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _isGridView
                      ? GridView.builder(
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
                            final item = entry.value[index];
                            final isSelected =
                                _selectedPaths.contains(item.path);

                            return GestureDetector(
                              onLongPress: () {
                                setState(() => _isSelectionMode = true);
                                _toggleSelect(item.path);
                              },
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelect(item.path);
                                } else {
                                  _openViewer(item);
                                }
                              },
                              child: Stack(
                                children: [
                                  item.isVideo
                                      ? const Center(
                                          child: Icon(Icons.videocam, size: 48))
                                      : Image.network(item.url,
                                          fit: BoxFit.cover),
                                  if (isSelected)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(Icons.check_circle,
                                          color: Colors.blueAccent
                                              .withOpacity(0.9)),
                                    ),
                                ],
                              ),
                            );
                          },
                        )
                      : Column(
                          children: entry.value.map((item) {
                            final isSelected =
                                _selectedPaths.contains(item.path);
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              leading: item.isVideo
                                  ? const Icon(Icons.videocam)
                                  : Image.network(item.url,
                                      width: 60, height: 60),
                              title: Text(item.path.split('/').last),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.blueAccent)
                                  : null,
                              onLongPress: () {
                                setState(() => _isSelectionMode = true);
                                _toggleSelect(item.path);
                              },
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelect(item.path);
                                } else {
                                  _openViewer(item);
                                }
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

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) => setState(() {}))
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
