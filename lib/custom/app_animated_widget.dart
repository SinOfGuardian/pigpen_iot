import 'package:flutter/material.dart';

class HorizontalProgressBar extends StatelessWidget {
  final double? data;
  final double height;
  final double maxWidth;
  final double min, max;
  final Color? lineColor;
  const HorizontalProgressBar({
    super.key,
    required this.min,
    required this.max,
    required this.maxWidth,
    required this.data,
    this.height = 4,
    this.lineColor,
  });

  double _newWidth(double? newValue) {
    const double minWidth = 1;
    if (newValue == null) return minWidth;
    if (newValue <= minWidth) return minWidth;
    if (newValue >= maxWidth) return maxWidth;

    double percentageOfData = (newValue - min) / (max - min);
    return maxWidth * percentageOfData;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          height: height,
          width: maxWidth,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.all(Radius.circular(height / 2)),
          ),
        ),
        AnimatedContainer(
          height: height,
          width: _newWidth(data),
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 1000),
          decoration: BoxDecoration(
            color: lineColor ?? colorScheme.onSurface,
            borderRadius: BorderRadius.all(
              Radius.circular(height / 2),
            ),
          ),
        ),
      ],
    );
  }
}
