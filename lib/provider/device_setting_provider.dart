import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localDrinkerDurationProvider =
    StateNotifierProvider<DurationNotifier, int>(
  (ref) => DurationNotifier('manual_drinker_duration'),
);

final localSprinklerDurationProvider =
    StateNotifierProvider<DurationNotifier, int>(
  (ref) => DurationNotifier('manual_sprinkler_duration'),
);

class DurationNotifier extends StateNotifier<int> {
  final String key;
  DurationNotifier(this.key) : super(5) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(key) ?? 5;
  }

  Future<void> set(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    state = value;
  }
}
