// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailService {
  // static Future<String?> generateThumbnail(String videoUrl) async {
  //   final cacheDir = await getApplicationDocumentsDirectory();
  //   final thumbnailsDir = Directory('${cacheDir.path}/thumbnails');

  //   if (!await thumbnailsDir.exists()) {
  //     await thumbnailsDir.create(recursive: true);
  //   }

  //   final thumbnailFileName = '${md5.convert(utf8.encode(videoUrl))}.jpg';
  //   final thumbnailPath = '${thumbnailsDir.path}/$thumbnailFileName';

  //   final thumbnailFile = File(thumbnailPath);
  //   if (await thumbnailFile.exists()) {
  //     return thumbnailPath;
  //   }

  //   final generatedPath = await VideoThumbnail.thumbnailFile(
  //     video: videoUrl,
  //     thumbnailPath: thumbnailsDir.path,
  //     imageFormat: ImageFormat.JPEG,
  //     quality: 75,
  //   );

  //   return generatedPath;
  // }
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
}
