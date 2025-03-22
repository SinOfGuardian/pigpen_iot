import 'package:flutter/material.dart';
import 'package:pigpen_iot/modules/sharedprefs.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_page_viewmodel.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeModifier.getThemeMode;

  void reset(Brightness brightness) {
    final mode =
        brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
    update(mode);
  }

  void update(ThemeMode mode) async {
    const theme = ThemeModifier();
    await theme.writeThemeMode(mode);
    state = ThemeModifier.getThemeMode;
  }
}

@immutable
class ThemeModifier {
  const ThemeModifier();
  static const themeModeKey = 'theme_mode';

  static ThemeMode get getThemeMode {
    final themeMode = {
      false: ThemeMode.light,
      true: ThemeMode.dark,
      null: ThemeMode.system,
    };
    const prefs = SharedPrefs();
    return themeMode[prefs.readBool(themeModeKey)]!;
  }

  Future<bool> writeThemeMode(ThemeMode mode) {
    final themeMode = {
      ThemeMode.light: false,
      ThemeMode.dark: true,
      ThemeMode.system: null,
    }[mode];
    if (themeMode == null) return clearThemeMode();
    const prefs = SharedPrefs();
    return prefs.writeBool(themeModeKey, themeMode);
  }

  Future<bool> clearThemeMode() {
    const prefs = SharedPrefs();
    return prefs.remove(themeModeKey);
  }
}
