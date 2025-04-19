import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/modules/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pigpen_iot/models/userdevice_model.dart';

part 'userdevices_provider.g.dart';

@riverpod
Stream<List<UserDevice>> userDevicesStream(
    // ignore: deprecated_member_use_from_same_package
    UserDevicesStreamRef ref,
    String uid) {
  final path = 'userdata/user_devices/$uid/';
  return FirebaseDatabase.instance.ref(path).onValue.map((event) {
    final json = event.snapshot.value as Map<Object?, Object?>?;
    if (json == null) return [];
    return json.values
        .map((deviceJson) =>
            UserDevice.fromJson(deviceJson as Map<Object?, Object?>))
        .toList();
  });
}

@riverpod
class UserDevices extends _$UserDevices {
  @override
  FutureOr<List<UserDevice>> build() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw UserException('UID is null');
    return ref.watch(userDevicesStreamProvider(uid).future);
  }

  Future<void> addDeviceToCurrentUser(UserDevice userDevice) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return addDeviceToUser(uid, userDevice);
  }

  Future<void> addDeviceToUser(String? userId, UserDevice userDevice) async {
    if (userId == null) throw UserException('UID is null');
    final path = 'userdata/user_devices/$userId/';
    final dateNow =
        DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now()).toString();
    return FirebaseDatabase.instance
        .ref(path)
        .child(dateNow)
        .update(userDevice.toJson())
        .timeout(const Duration(seconds: 5));
  }

  final streamUrlProvider =
      FutureProvider.family<String, String>((ref, deviceId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref('contents/devices/$deviceId/streamUrl')
        .get();

    if (snapshot.exists && snapshot.value is String) {
      return snapshot.value as String;
    } else {
      throw UserException('Stream URL not found for device $deviceId');
    }
  });
}
