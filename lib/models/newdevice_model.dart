import 'package:flutter/material.dart';

@immutable
class NewDevice {
  final String deviceId;
  final String deviceName;
  final String graphicName;
  final String graphicUrl;

  const NewDevice({
    required this.deviceId,
    required this.deviceName,
    required this.graphicUrl,
    required this.graphicName,
  });

  factory NewDevice.empty() {
    return const NewDevice(
      deviceId: '',
      deviceName: '',
      graphicName: '',
      graphicUrl: '',
    );
  }
  NewDevice copyWith({
    String? deviceId,
    String? deviceName,
    String? graphicName,
    String? graphicUrl,
    int? deviceCount,
  }) {
    return NewDevice(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      graphicUrl: graphicUrl ?? this.graphicUrl,
      graphicName: graphicName ?? this.graphicName,
    );
  }
}
