import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Duration refreshInterval;

  FirebaseStorageService({this.refreshInterval = const Duration(seconds: 30)});

  /// Stream log file references under `logs/deviceId`
  Stream<List<Reference>> streamAllLogs(String deviceId) async* {
    final controller = StreamController<List<Reference>>();

    Future<void> poll() async {
      while (!controller.isClosed) {
        try {
          final allRefs = await _listAllLogs(deviceId);
          controller.add(allRefs);
        } catch (e) {
          controller.addError(e);
        }
        await Future.delayed(refreshInterval);
      }
    }

    poll(); // Start polling in background
    yield* controller.stream;
  }

  /// Private recursive list
  Future<List<Reference>> _listAllLogs(String deviceId) async {
    final List<Reference> allRefs = [];

    Future<void> recursiveList(Reference ref) async {
      final result = await ref.listAll();
      allRefs.addAll(result.items); // Add files
      for (final folder in result.prefixes) {
        await recursiveList(folder);
      }
    }

    final rootRef = _storage.ref().child('logs/$deviceId');
    await recursiveList(rootRef);
    return allRefs;
  }

  /// Download and decode JSON log file
  Future<Map<String, dynamic>> downloadLog(Reference ref) async {
    try {
      final data = await ref.getData(1024 * 1024); // Max 1MB
      if (data == null) throw Exception("No data found for ${ref.fullPath}");

      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonData;
    } catch (e) {
      debugPrint('Error downloading log ${ref.fullPath}: $e');
      rethrow;
    }
  }
}
