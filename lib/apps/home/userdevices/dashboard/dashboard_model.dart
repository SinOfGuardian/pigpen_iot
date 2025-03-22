import 'package:flutter/material.dart';

@immutable
class Characteristics {
  final String? maintenance, aveHeight, origin, lastWatered;

  const Characteristics({
    required this.maintenance,
    required this.aveHeight,
    required this.origin,
    required this.lastWatered,
  });
}

@immutable
class DashboardBottomData {
  final String? name;
  final String? description;
  final Map<Object?, Object> characteristics;
  final bool? liked;

  const DashboardBottomData({
    required this.name,
    required this.description,
    required this.characteristics,
    required this.liked,
  });
}
