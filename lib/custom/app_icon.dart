import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 20,
    this.color,
    this.weight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: Text(
          String.fromCharCode(icon.codePoint),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            color: color,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            fontWeight: weight,
            height: 1,
          ),
        ),
      ),
    );
  }
}
