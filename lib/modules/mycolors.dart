// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = [.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

// @Custom Colors
const Color ACCENT_COLOR = Color.fromARGB(255, 174, 234, 183);
const Color SECONDARY_COLOR = Color.fromARGB(255, 182, 182, 182);

const Color TITLETEXT_COLOR = Color.fromARGB(255, 50, 50, 50);
const Color TITLETEXT_COLOR2 = Color.fromARGB(255, 90, 90, 90);
const Color SUBTITLETEXT_COLOR = Color.fromARGB(255, 145, 145, 145);

// const Color TITLETEXT_COLOR = Color.fromARGB(255, 34, 37, 57);
// const Color TITLETEXT_COLOR = Color.fromARGB(255, 57, 68, 56);

const Color PRIMARY_1 = Color.fromARGB(255, 65, 204, 100);
const Color COLOR_1 = Color.fromARGB(255, 229, 244, 237);
const Color COLOR_2 = Color.fromARGB(255, 174, 234, 183);
const Color COLOR_3 = Color.fromARGB(255, 255, 187, 87);

// App
const Color ICON_COLOR = SECONDARY_COLOR;
const Color ICON_BG_COLOR_LIGHT = Color.fromARGB(255, 240, 240, 240);
const Color ICON_BG_COLOR_DARK = Color.fromARGB(255, 204, 204, 204);

const Color BG_COLOR1 = Color.fromARGB(255, 211, 242, 223);

// const Color PRIMARY_ACCENT_COLOR = Color.fromARGB(255, 26, 96, 72);
const Color PRIMARY_ACCENT_COLOR = Color.fromARGB(255, 1, 167, 85); //26, 96, 72
// const Color SECONDARY_ACCENT_COLOR = Color.fromARGB(255, 217, 179, 116);
// const Color SECONDARY_ACCENT_COLOR = Color.fromARGB(255, 255, 227, 208);
const Color SECONDARY_ACCENT_COLOR = TITLETEXT_COLOR;
// const Color ACCENT_BG_BOLOR = Color.fromARGB(255, 230, 237, 234);
const Color ACCENT_BG_BOLOR = ICON_BG_COLOR_LIGHT;

const Color LINK_COLOR = Colors.blueAccent;
const Color LABEL_COLOR = Colors.grey;

// Bottom Navigation Bar
// const Color activeBottomColor = Color.fromARGB(255, 91, 194, 134);
const Color ACTIVE_TAB_ICON_COLOR = PRIMARY_ACCENT_COLOR;
const Color ACTIVE_TAB_BACKGROUND_COLOR = ICON_BG_COLOR_LIGHT;
const Color TAB_ICON_COLOR = SECONDARY_COLOR;

// Thing Block Properties
// const Color THINGBLOCK_COLOR = Color.fromARGB(255, 229, 245, 237);
const Color THINGBLOCK_COLOR = APP_BGCOLOR;
// const Color THINGBLOCK_COLOR = Color.fromARGB(255, 96, 137, 111);
Color SPLASHEFFECT_COLOR = Colors.white.withOpacity(0.1);
const Color THINGBLOCKSHADOW_COLOR = Color.fromRGBO(0, 0, 0, 0.14);

// Chart Colors
// const Color tempChartColor = Colors.orange;
// const Color humidChartColor = Colors.blue;
// const Color soilChartColor = Colors.brown;

// Plant Page Color
const Color TABPAGE_BGCOLOR = Color.fromARGB(255, 251, 251, 251); //35, 235, 235
// Color.fromARGB(255, 173, 173, 173);
const Color APP_BGCOLOR = Color.fromARGB(255, 251, 251, 251);

const Color BOX_SHADOR_COLOR = Color.fromARGB(50, 0, 0, 0);

// const Color TEMP_COLOR1 = Colors.amber;
// const Color TEMP_COLOR2 = Color.fromARGB(255, 250, 207, 142);

// const Color HUMID_COLOR1 = Color.fromARGB(255, 7, 156, 255);
// const Color HUMID_COLOR2 = Color.fromARGB(255, 250, 207, 142);

// const Color SOIL_COLOR1 = Color.fromARGB(255, 160, 116, 35);
// const Color SOIL_COLOR2 = Color.fromARGB(255, 156, 124, 74);

const Color TEMP_COLOR1 = PRIMARY_ACCENT_COLOR;
const Color TEMP_COLOR2 = Color.fromARGB(255, 230, 237, 234);

const Color HUMID_COLOR1 = PRIMARY_ACCENT_COLOR;
const Color HUMID_COLOR2 = Color.fromARGB(255, 230, 237, 234);

const Color SOIL_COLOR1 = PRIMARY_ACCENT_COLOR;
const Color SOIL_COLOR2 = Color.fromARGB(255, 230, 237, 234);

// ---------------------------------
const Color SHIMMER_COLOR = ICON_BG_COLOR_LIGHT;
const Color CIRCLE_LOADING_COLOR = Color.fromARGB(255, 50, 50, 50);

const Color INPUTFIELD_OUTLINE = Color.fromARGB(255, 219, 219, 219);
const Color PASSWORDFELD_EYE_ENABLED = PRIMARY_ACCENT_COLOR;
Color PASSWORDFELD_EYE_DISABLED = PRIMARY_ACCENT_COLOR.withOpacity(0.3);

const Color BROWN = Color.fromARGB(255, 148, 121, 102);
