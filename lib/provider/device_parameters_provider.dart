import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/database.dart';

final parameterStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, deviceId) {
  return DeviceFirebase().getParameterStream(deviceId);
});
