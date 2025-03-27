import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_icon.dart';

class ProfileBadge extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int? things;
  const ProfileBadge({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 20),
    this.things,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: colorScheme.surface);

    Color color = colorScheme.primary;

    if (things == null || things! <= 1) {
      color = colorScheme.primary;
    } else if (things! > 1 && things! <= 3) {
      color = colorScheme.tertiary;
    } else if (things! > 3) {
      color = Colors.deepPurpleAccent;
    }

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(EvaIcons.awardOutline,
                  color: colorScheme.surface, size: 16),
              Text('PigPen User', style: style),
            ],
          ),
        ),
      ),
    );
  }
}
