import 'package:flutter/material.dart';

const int kNormalScreenHeight = 800;
const int kNormalScreenWidth = 400;

const int kFloatingScreenHeight = 650;
const int kFloatingScreenWidth = 350;

// const int kSmallScreenHeight = 600;
// const int kSmallScreenWidth = 300;

// const int kTinyScreenHeight = 500;
// const int kTinyScreenWidth = 250;

bool isAppInFloatingWindow(BuildContext context) {
  return MediaQuery.of(context).size.height <= kFloatingScreenHeight;
}
