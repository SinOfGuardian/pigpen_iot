import 'package:flutter/material.dart';
import 'package:pigpen_iot/models/newdevice_model.dart';

@immutable
class UserDevice {
  final String deviceId;
  final String deviceName;
  final String graphicUrl;
  final String graphicName;

  const UserDevice({
    required this.deviceId,
    required this.deviceName,
    required this.graphicUrl,
    required this.graphicName,
  });

  factory UserDevice.fromJson(Map<Object?, Object?> json) {
    return UserDevice(
      deviceId: json['deviceId'] as String,
      deviceName: json['name'] as String,
      graphicName: json['graphic'] as String,
      graphicUrl: json['url'] as String,
    );
  }

  factory UserDevice.fromNewDevice(NewDevice newDevice) {
    return UserDevice(
      deviceId: newDevice.deviceId,
      deviceName: newDevice.deviceName,
      graphicName: newDevice.graphicName,
      graphicUrl: newDevice.graphicUrl,
    );
  }

  factory UserDevice.empty() {
    return const UserDevice(
      deviceId: '',
      deviceName: '',
      graphicName: '',
      graphicUrl: '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'deviceId': deviceId,
      'name': deviceName,
      'graphic': graphicName,
      'url': graphicUrl,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'name': deviceName,
      'graphic': graphicName,
      'url': graphicUrl,
    };
  }

  UserDevice copyWith({
    String? deviceId,
    String? deviceName,
    String? graphicUrl,
    String? graphicName,
  }) {
    return UserDevice(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      graphicUrl: graphicUrl ?? this.graphicUrl,
      graphicName: graphicName ?? this.graphicName,
    );
  }

  @override
  String toString() {
    return 'UserDevice('
        'deviceId: $deviceId, '
        'name: $deviceName, '
        'graphic: $graphicName, '
        'url: $graphicUrl, '
        ')';
  }
}
