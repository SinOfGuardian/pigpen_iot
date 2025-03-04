import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;
  final double outlineWidth;
  final Clip clipBehavior;
  final BorderRadiusGeometry? borderRadius;

  const AppContainer({
    super.key,
    this.child,
    this.margin = const EdgeInsets.only(bottom: 20, left: 20, right: 20),
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
    this.width = double.infinity,
    this.boxShadow,
    this.height,
    this.color,
    this.outlineWidth = 0,
    this.clipBehavior = Clip.none,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
  });

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color ?? col.surface,
          border: outlineWidth != 0
              ? Border.all(
                  color: isDarkTheme ? Colors.black12 : col.surfaceContainer,
                  width: outlineWidth,
                )
              : null,
          boxShadow: isDarkTheme ? null : boxShadow),
      child: child,
    );
  }
}

class ShaddowedContainer extends StatelessWidget {
  final Widget? child;
  final double marginTop;
  const ShaddowedContainer({super.key, this.child, this.marginTop = 0});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(top: marginTop),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : Colors.black12,
              offset: const Offset(0, 5),
              blurRadius: 30,
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
