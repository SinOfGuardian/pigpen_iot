import 'package:firebase_database/firebase_database.dart';
import 'package:pigpen_iot/models/device_model.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/modules/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devices_provider.g.dart';

@riverpod
class Devices extends _$Devices {
  @override
  FutureOr<List<Device>> build() async {
    const path = 'contents/devices/';
    final snapshot = await FirebaseDatabase.instance.ref(path).get();
    final json = snapshot.value as Map<Object?, Object?>?;
    if (json == null) return [];
    return json.values
        .map((deviceJson) =>
            Device.fromJson(deviceJson as Map<Object?, Object?>))
        .toList();
  }

  Future<String?> lookForDeviceModel(String deviceId) async {
    final devices = await future;
    for (final device in devices) {
      if (device.id == deviceId) return device.model;
    }
    return null;
  }

  Future<List<Device>> getUserDevices(String userId) async {
    const path = 'contents/devices/';
    final snapshot = await FirebaseDatabase.instance.ref(path).get();
    final json = snapshot.value as Map<Object?, Object?>?;
    if (json == null) return [];

    return json.values
        .map((deviceJson) =>
            Device.fromJson(deviceJson as Map<Object?, Object?>))
        .where(
            (device) => device.toJson()['userId'] == userId) // Filter by userId
        .toList();
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('contents/devices/$deviceId');
      await ref.remove().timeout(const Duration(seconds: 5));
    } catch (e) {
      throw UserException('Error deleting device: $e');
    }
  }

  Future<void> updateDevice(String deviceId, Device updatedDevice) async {
    final ref = FirebaseDatabase.instance.ref('contents/devices/$deviceId');
    await ref.set(updatedDevice.toJson()).timeout(const Duration(seconds: 5));
  }

  final manualStatusProvider =
      StreamProvider.family<int, ({String deviceId, String type})>((ref, args) {
    final firebaseService = DeviceFirebase();
    return firebaseService.manualStatusStream(
      deviceId: args.deviceId,
      type: args.type,
    );
  });
}
