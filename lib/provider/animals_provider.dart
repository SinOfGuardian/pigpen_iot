import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pigpen_iot/models/animal_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animals_provider.g.dart';

@riverpod
class Animals extends _$Animals {
  @override
  FutureOr<List<Animal>> build() async {
    const path = 'contents/farm/animal/';
    final snapshot =
        await FirebaseDatabase.instance.ref(path).orderByKey().get();
    final json = snapshot.value as Map<Object?, Object?>?;
    if (json == null) return [];

    debugPrint('Firebase data: $json'); // Print the raw data from Firebase

    List<Animal> animals = [];
    json.forEach((key, value) {
      if (value != null) {
        debugPrint('Parsing animal: $value'); // Print each animal data
        final animal = Animal.fromJson(value as Map<Object?, Object?>);
        animals.add(animal);
      }
    });
    return animals;
  }
}
