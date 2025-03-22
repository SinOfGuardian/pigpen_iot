import 'package:flutter/material.dart';

enum StaticShimmerShape { roundedRectangle, circular }

class StaticShimmer extends StatelessWidget {
  const StaticShimmer({
    super.key,
    this.height = double.infinity,
    this.width = double.infinity,
    this.widthFactor,
    this.shape,
  });

  const StaticShimmer.roundedRectangle({
    super.key,
    this.height = double.infinity,
    this.width = double.infinity,
    this.widthFactor,
  }) : shape = StaticShimmerShape.roundedRectangle;

  const StaticShimmer.circular({
    super.key,
    this.height = double.infinity,
    this.width = double.infinity,
    this.widthFactor,
  }) : shape = StaticShimmerShape.circular;

  final double height;
  final double width;
  final double? widthFactor;
  final StaticShimmerShape? shape;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: SizedBox(
        height: height,
        width: width,
        child: shape == null || shape == StaticShimmerShape.roundedRectangle
            ? DecoratedBox(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
              ))
            : CircleAvatar(backgroundColor: color),
      ),
    );
  }
}
