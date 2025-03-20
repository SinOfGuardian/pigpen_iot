import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kDoneIntro = 'intro';

@immutable
class SharedPrefs {
  const SharedPrefs();

  static late SharedPreferences prefs;
  static Future<void> init() async =>
      prefs = await SharedPreferences.getInstance();
  static void clearPrefs() => prefs.clear();

  // Write
  Future<bool> writeString(String key, String value) =>
      prefs.setString(key, value);
  Future<bool> writeBool(String key, bool value) => prefs.setBool(key, value);
  Future<bool> writeInt(String key, int value) => prefs.setInt(key, value);
  Future<bool> writeStringList(String key, List<String> list) =>
      prefs.setStringList(key, list);
  Future<bool> remove(String key) => prefs.remove(key);

  // Read
  Set<String> getKeys() => prefs.getKeys();
  int? readInt(String key) => prefs.getInt(key);
  bool? readBool(String key) => prefs.getBool(key);
  double? readDouble(String key) => prefs.getDouble(key);
  String? readString(String key) => prefs.getString(key);
  List<dynamic>? readStringList(String key) => prefs.getStringList(key);
}
