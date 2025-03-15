import 'package:flutter/material.dart';

@immutable
class Animal {
  final String name;
  final String graphicUrl;
  final String description;

  const Animal({
    required this.name,
    required this.graphicUrl,
    required this.description,
  });

  factory Animal.fromJson(Map<Object?, Object?> json) {
    return Animal(
      name: json['animal name'] as String? ?? 'Unknown',
      graphicUrl: json['url'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal name': name,
      'url': graphicUrl,
      'description': description,
    };
  }

  Animal copyWith({
    String? name,
    String? graphicUrl,
    String? description,
  }) {
    return Animal(
      name: name ?? this.name,
      graphicUrl: graphicUrl ?? this.graphicUrl,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Animal('
        'animal name: $name, '
        'url: $graphicUrl, '
        'description: $description'
        ')';
  }
}
