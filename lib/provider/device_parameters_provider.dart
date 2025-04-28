import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/modules/exceptions.dart';

final parameterStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, deviceId) {
  return DeviceFirebase().getParameterStream(deviceId);
});

final sprinklerDurationStreamProvider =
    StreamProvider.family<int, String>((ref, deviceId) {
  return DeviceFirebase().manualDurationStream(deviceId, 'sprinkler');
});

final drinkerDurationStreamProvider =
    StreamProvider.family<int, String>((ref, deviceId) {
  return DeviceFirebase().manualDurationStream(deviceId, 'drinker');
});

//STREAM CAMERA
final deviceIpStreamProvider =
    StreamProvider.family<String, String>((ref, deviceId) {
  final refPath = 'contents/devices/$deviceId/ipAddress';
  final dbRef = FirebaseDatabase.instance.ref(refPath);

  return dbRef.onValue.map((event) {
    if (event.snapshot.exists && event.snapshot.value is String) {
      return event.snapshot.value as String;
    } else {
      throw UserException('IP Address not available');
    }
  });
});
