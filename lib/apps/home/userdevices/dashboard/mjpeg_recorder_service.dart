import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MJPEGRecorderService {
  final String streamUrl;
  final List<File> _recordedFrames = [];

  MJPEGRecorderService({required this.streamUrl});

  Future<void> startRecording() async {
    _recordedFrames.clear();
  }

  Future<void> stopRecording() async {
    final dir = Directory.systemTemp.createTempSync();
    final folderPath =
        '${dir.path}/recordings/${DateTime.now().millisecondsSinceEpoch}';
    final folder = Directory(folderPath)..createSync(recursive: true);

    for (int i = 0; i < _recordedFrames.length; i++) {
      final frame = _recordedFrames[i];
      final ref = FirebaseStorage.instance.ref('recordings/frame_$i.jpg');
      await ref.putFile(frame);
    }
  }

  Future<void> recordSnapshot() async {
    final bytes = await http.readBytes(Uri.parse(streamUrl));
    final filename =
        "${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.jpg";
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes);
    _recordedFrames.add(file);
  }

  Future<String> takeSnapshot() async {
    final bytes = await http.readBytes(Uri.parse(streamUrl));
    final filename =
        "snapshot_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.jpg";
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes);

    final ref = FirebaseStorage.instance.ref('snapshots/$filename');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
