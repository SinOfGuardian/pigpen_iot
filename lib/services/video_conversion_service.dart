// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pigpen_iot/services/notification_service.dart';

class VideoConversionService {
  static Future<String?> convertAndUploadMjpg({
    required String mjpgUrl,
    required String storagePath,
    required Function(String message) onLog,
    required Function(double progress) onProgress,
  }) async {
    try {
      onLog("📦 Checking for existing converted video...");

      final baseName = Uri.parse(mjpgUrl)
          .pathSegments
          .last
          .replaceAll('.mjpg', '')
          .replaceAll('.mjpeg', '');
      final firebaseRoot = FirebaseStorage.instance.ref('recordings');

      // ✅ Check if already uploaded (.avi or .mp4)
      try {
        final aviUrl =
            await firebaseRoot.child('$baseName.avi').getDownloadURL();
        onLog("📥 Already uploaded (.avi)");
        return aviUrl;
      } catch (_) {}

      try {
        final mp4Url =
            await firebaseRoot.child('$baseName.mp4').getDownloadURL();
        onLog("📥 Already uploaded (.mp4)");
        return mp4Url;
      } catch (_) {}

      // 📥 Download .mjpg
      onLog("📥 Downloading MJPEG...");
      final response = await http.get(Uri.parse(mjpgUrl));
      if (response.statusCode != 200) throw Exception("Download failed");

      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final workingDir = Directory(
          '${tempDir.path}/frames_${DateTime.now().millisecondsSinceEpoch}');
      if (!workingDir.existsSync()) workingDir.createSync(recursive: true);

      // 🧩 Extract frames
      onLog("🧩 Extracting frames...");
      final SOI = [0xFF, 0xD8], EOI = [0xFF, 0xD9];
      List<int> buffer = [];
      int frameCount = 0;

      for (int i = 0; i < bytes.length - 1; i++) {
        if (bytes[i] == SOI[0] && bytes[i + 1] == SOI[1]) {
          buffer = [bytes[i], bytes[i + 1]];
        } else if (bytes[i] == EOI[0] && bytes[i + 1] == EOI[1]) {
          buffer.addAll([bytes[i], bytes[i + 1]]);
          frameCount++;
          final frame = File(
              '${workingDir.path}/frame_${frameCount.toString().padLeft(4, '0')}.jpg');
          await frame.writeAsBytes(buffer);
          onProgress(frameCount.toDouble());
          i++;
        } else {
          buffer.add(bytes[i]);
        }
      }

      if (frameCount == 0) throw Exception("No valid frames found.");

      // 🎞️ Convert to .avi first
      File? finalVideo;
      String extension = '';
      final mp4Path = "${workingDir.path}/output.mp4";
      final mp4Command =
          "-y -framerate 3 -i '${workingDir.path}/frame_%04d.jpg' -c:v mpeg4 '$mp4Path'";

      // final aviPath = "${workingDir.path}/output.avi";
      // final aviCommand =
      //     "-y -framerate 1 -i '${workingDir.path}/frame_%04d.jpg' -c:v mjpeg '$aviPath'";
      onLog("🎞️ Converting to AVI...");
      var session = await FFmpegKit.execute(mp4Command);
      var returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        finalVideo = File(mp4Path);
        extension = 'avi';
      } else {
        // ⚠️ Fallback to .mp4
        final mp4Path = "${workingDir.path}/output.mp4";
        final mp4Command =
            "-y -framerate 3 -i '${workingDir.path}/frame_%04d.jpg' -c:v mpeg4 '$mp4Path'";
        onLog("⚠️ AVI failed. Trying MP4...");
        session = await FFmpegKit.execute(mp4Command);
        returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          finalVideo = File(mp4Path);
          extension = 'mp4';
        } else {
          throw Exception("FFmpeg failed to convert to AVI or MP4.");
        }
      }

      if (!finalVideo.existsSync()) {
        throw Exception("Conversion file not created.");
      }

      // ☁️ Upload
      onLog("☁️ Uploading $extension...");
      final uploadRef = FirebaseStorage.instance.ref('$baseName.$extension');
      await uploadRef.putFile(finalVideo);
      final downloadUrl = await uploadRef.getDownloadURL();

      // 🔔 Notify user
      await NotificationService.showNotification(
        title: "✅ Video Ready",
        body: "$baseName.$extension has been converted and uploaded.",
      );

      // 🧹 Cleanup
      onLog("🧹 Cleaning up...");
      await workingDir.delete(recursive: true);
      await FirebaseStorage.instance.ref(storagePath).delete();

      onLog("✅ Done!");
      return downloadUrl;
    } catch (e) {
      onLog("❌ $e");
      debugPrint("❌ Error: $e");
      return null;
    }
  }
}
