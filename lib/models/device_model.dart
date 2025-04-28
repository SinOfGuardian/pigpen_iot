import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Device {
  final String id;
  final String model;
  final String dateRegistered;
  final String status;
  final String cameraIp;

  const Device({
    required this.id,
    required this.model,
    required this.dateRegistered,
    required this.status,
    required this.cameraIp,
  });

  factory Device.fromJson(Map<Object?, Object?> json) {
    return Device(
      id: json['id'] as String,
      model: json['model'] as String,
      dateRegistered: json['date_registered'] as String,
      status: json['status'] as String,
      cameraIp: json['camera_ip'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'model': model,
      'date_registered': dateRegistered,
      'status': status,
      'camera_ip': cameraIp,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'date_registered': dateRegistered,
      'status': status,
      'camera_ip': cameraIp,
    };
  }

  factory Device.empty() {
    return const Device(
        id: '', model: '', dateRegistered: '', status: '', cameraIp: '');
  }

  Device copyWith({
    String? id,
    String? model,
    String? dateRegistered,
    String? status,
    String? cameraIp,
  }) {
    return Device(
      id: id ?? this.id,
      model: model ?? this.model,
      dateRegistered: dateRegistered ?? this.dateRegistered,
      status: status ?? this.status,
      cameraIp: cameraIp ?? this.cameraIp,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, model: $model, dateRegistered: $dateRegistered, status: $status, cameraIp: $cameraIp)';
  }
}
