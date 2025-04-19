import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class MJPEGRecorderService {
  final String sessionId;
  final String streamUrl;
  final Duration interval;
  bool _isRecording = false;
  int _frameCount = 0;

  MJPEGRecorderService({
    required this.sessionId,
    required this.streamUrl,
    this.interval = const Duration(seconds: 1),
  });

  Future<void> startRecording() async {
    _isRecording = true;
    _frameCount = 0;

    while (_isRecording) {
      try {
        final response = await http.get(Uri.parse(streamUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          await _uploadFrame(bytes);
          _frameCount++;
        }
      } catch (e) {
        print("Frame capture error: $e");
      }

      await Future.delayed(interval);
    }

    await _uploadDoneMarker();
  }

  void stopRecording() {
    _isRecording = false;
  }

  Future<void> _uploadFrame(Uint8List bytes) async {
    final paddedNumber = _frameCount.toString().padLeft(3, '0');
    final fileName = 'photo_$paddedNumber.jpg';

    final storageRef =
        FirebaseStorage.instance.ref().child('recordings/$sessionId/$fileName');

    await storageRef.putData(
        bytes, SettableMetadata(contentType: 'image/jpeg'));
  }

  Future<void> _uploadDoneMarker() async {
    final ref =
        FirebaseStorage.instance.ref().child('recordings/$sessionId/done.txt');
    await ref.putString('');
  }
}
