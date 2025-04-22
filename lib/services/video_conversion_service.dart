import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoConversionService {
  static Future<String?> convertAndUploadMjpg({
    required String mjpgUrl,
    required String storagePath,
    required Function(String message) onLog,
    required Function(double progress) onProgress,
  }) async {
    try {
      onLog("📥 Downloading MJPG stream...");
      final response = await http.get(Uri.parse(mjpgUrl));
      if (response.statusCode != 200) {
        throw Exception(
            "Failed to download MJPG file. Status: ${response.statusCode}");
      }

      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final localCacheDir = await getApplicationDocumentsDirectory();

      final cacheFileName =
          Uri.parse(mjpgUrl).pathSegments.last.replaceAll('.mjpg', '.mp4');
      final cachedFile = File("${localCacheDir.path}/$cacheFileName");

      if (cachedFile.existsSync()) {
        onLog("📦 Using cached MP4");
        return cachedFile.path;
      }

      final workingDir = Directory(
          '${dir.path}/frames_${DateTime.now().millisecondsSinceEpoch}');
      if (!workingDir.existsSync()) {
        workingDir.createSync(recursive: true);
      }

      onLog("🧩 Extracting JPG frames...");
      final SOI = [0xFF, 0xD8]; // Start of Image
      final EOI = [0xFF, 0xD9]; // End of Image

      List<int> buffer = [];
      int frameCount = 0;

      for (int i = 0; i < bytes.length - 1; i++) {
        if (bytes[i] == SOI[0] && bytes[i + 1] == SOI[1]) {
          buffer = [bytes[i], bytes[i + 1]];
        } else if (bytes[i] == EOI[0] && bytes[i + 1] == EOI[1]) {
          buffer.addAll([bytes[i], bytes[i + 1]]);
          frameCount++;
          final filename =
              "${workingDir.path}/frame_${frameCount.toString().padLeft(4, '0')}.jpg";
          final file = File(filename);
          await file.writeAsBytes(buffer);
          onProgress(frameCount.toDouble()); // progress update per frame
          i++;
        } else {
          buffer.add(bytes[i]);
        }
      }

      if (frameCount == 0) {
        throw Exception("No frames found in MJPG stream.");
      }

      onLog("🎞️ Converting $frameCount frames to MP4...");
      final outputMp4 = "${workingDir.path}/output.mp4";
      final command =
          "-y -framerate 1 -i ${workingDir.path}/frame_%04d.jpg -c:v libx264 -preset fast -crf 28 $outputMp4";

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        throw Exception("FFmpeg failed to convert the file.");
      }

      final mp4File = File(outputMp4);
      if (!mp4File.existsSync()) {
        throw Exception("MP4 file was not created.");
      }

      onLog("☁️ Uploading to Firebase...");
      final mp4Ref = FirebaseStorage.instance
          .ref("recordings/${mp4File.uri.pathSegments.last}");
      await mp4Ref.putFile(mp4File);

      onLog("📁 Caching locally...");
      await mp4File.copy(cachedFile.path);

      onLog("🗑️ Cleaning up...");
      await workingDir.delete(recursive: true);
      await FirebaseStorage.instance.ref(storagePath).delete();

      final downloadUrl = await mp4Ref.getDownloadURL();
      onLog("✅ Done! MP4 ready.");
      return downloadUrl;
    } catch (e) {
      onLog("❌ Failed: $e");
      print("❌ Error: $e");
      return null;
    }
  }
}
