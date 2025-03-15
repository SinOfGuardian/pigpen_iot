import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Device {
  final String id;
  final String model;
  final String dateRegistered;
  final String status;

  const Device({
    required this.id,
    required this.model,
    required this.dateRegistered,
    required this.status,
  });

  factory Device.fromJson(Map<Object?, Object?> json) {
    return Device(
      id: json['id'] as String,
      model: json['model'] as String,
      dateRegistered: json['date_registered'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'model': model,
      'date_registered': dateRegistered,
      'status': status,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'date_registered': dateRegistered,
      'status': status,
    };
  }

  factory Device.empty() {
    return const Device(id: '', model: '', dateRegistered: '', status: '');
  }

  Device copyWith({
    String? id,
    String? model,
    String? dateRegistered,
    String? status,
  }) {
    return Device(
      id: id ?? this.id,
      model: model ?? this.model,
      dateRegistered: dateRegistered ?? this.dateRegistered,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, model: $model, dateRegistered: $dateRegistered, status: $status)';
  }
}
