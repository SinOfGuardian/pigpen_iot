import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission(Permission permission) async {
  final status = await permission.status;

  if (status.isGranted) {
    debugPrint('Permission already granted.');
  } else if (status.isDenied || status.isPermanentlyDenied) {
    if (await permission.request().isGranted) {
      debugPrint('Permission granted.');
    } else {
      debugPrint('Permission denied. Redirecting to app settings...');
      await openAppSettings();
    }
  } else {
    debugPrint('Permission already granted.');
  }
}

// Handle manageExternalStorage for Android 11+
Future<void> requestManageExternalStoragePermission() async {
  if (await Permission.manageExternalStorage.isGranted) {
    debugPrint('Permission already granted.');
  } else {
    // Request permission for managing external storage
    if (await Permission.manageExternalStorage.request().isGranted) {
      debugPrint('Permission granted to manage external storage.');
    } else {
      // Direct the user to settings if they deny
      debugPrint(
          'Permission denied for managing external storage. Redirecting to settings...');
      await openAppSettings();
    }
  }
}

Future<void> requestMultiplePermission() async {
  final statusMap = await [
    Permission.location,
    Permission.camera,
    Permission.storage,
    Permission.microphone,
  ].request();
  debugPrint('Permission Status Location: ${statusMap[Permission.location]}');
  debugPrint('Permission Status Camera: ${statusMap[Permission.camera]}');
  debugPrint('Permission Status storage: ${statusMap[Permission.storage]}');
  debugPrint(
      'Permission Status microphone: ${statusMap[Permission.microphone]}');
}

Future<bool> requestPermissionWithSetting() => openAppSettings();
