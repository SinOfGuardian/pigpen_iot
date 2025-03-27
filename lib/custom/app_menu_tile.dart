import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_icon.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? background;
  final VoidCallback? callback;
  final EdgeInsets? margin, padding;
  final IconData? trailingIcon, leadingIcon;
  final Widget? leadingWidget, trailingWidget;
  final Clip clipBehavior;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.background = Colors.transparent,
    this.callback,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    this.leadingWidget,
    this.trailingWidget,
    this.leadingIcon,
    this.trailingIcon = EvaIcons.chevronRight,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = textTheme.titleSmall;
    final subtitleStyle = textTheme.labelLarge?.copyWith(height: 1.6);

    return AppContainer(
      color: background,
      margin: margin,
      padding: EdgeInsets.zero,
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: callback,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Row(
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget!,
                ],
                if (leadingIcon != null) ...[
                  const SizedBox(width: 5),
                  AppIcon(leadingIcon!),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: titleStyle),
                      if (subtitle != null)
                        Text(subtitle!, style: subtitleStyle)
                    ],
                  ),
                ),
                if (trailingIcon != null) ...[
                  AppIcon(trailingIcon!, color: colorScheme.outline),
                  const SizedBox(width: 5),
                ],
                if (trailingWidget != null) ...[
                  trailingWidget!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
