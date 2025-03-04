import 'package:flutter/material.dart';

class FormTitle extends StatelessWidget {
  final TextAlign? textAlign;
  final String title;
  final int? maxLines;
  final EdgeInsets padding;
  final Color? color;

  const FormTitle(
    this.title, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.color,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: padding,
      child: Text(
        title,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        textAlign: textAlign,
        style: textTheme.headlineMedium?.copyWith(color: color),
      ),
    );
  }
}

class AppText extends StatelessWidget {
  final String data;
  final int? maxLines;
  final TextAlign? textAlign;
  final double? fontSize;
  final TextOverflow? overflow;
  const AppText(
    this.data, {
    this.maxLines,
    this.textAlign,
    this.fontSize,
    this.overflow,
    super.key,
  });

  const AppText.description16(
    this.data, {
    this.maxLines = 5,
    this.textAlign = TextAlign.left,
    this.fontSize = 16,
    super.key,
    this.overflow = TextOverflow.ellipsis,
  });

  const AppText.description14(
    this.data, {
    this.maxLines = 5,
    this.textAlign = TextAlign.left,
    this.fontSize = 14,
    super.key,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(fontSize: fontSize),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? margin;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final Color? iconColor;
  final MainAxisAlignment alignment;
  final double? width;
  const SectionLabel(
    this.title, {
    this.trailingIcon,
    this.leadingIcon,
    this.iconColor,
    this.width = double.infinity,
    this.alignment = MainAxisAlignment.start,
    this.margin =
        const EdgeInsets.only(top: 10, bottom: 15, left: 20, right: 20),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Container(
      margin: margin,
      width: width,
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 18, color: iconColor ?? Colors.grey),
            const SizedBox(width: 5),
          ],
          Text(title, style: labelStyle),
          if (trailingIcon != null) ...[
            const SizedBox(width: 5),
            Icon(trailingIcon, size: 18, color: iconColor ?? Colors.grey),
          ],
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? margin;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final Color? iconColor;
  final MainAxisAlignment alignment;
  final double? width;
  const SectionTitle(
    this.title, {
    this.trailingIcon,
    this.leadingIcon,
    this.iconColor,
    this.width = double.infinity,
    this.alignment = MainAxisAlignment.start,
    this.margin =
        const EdgeInsets.only(top: 10, bottom: 15, left: 20, right: 20),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium;
    return Container(
      margin: margin,
      width: width,
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 18, color: iconColor ?? Colors.grey),
            const SizedBox(width: 5),
          ],
          Text(title, style: labelStyle),
          if (trailingIcon != null) ...[
            const SizedBox(width: 5),
            Icon(trailingIcon, size: 18, color: iconColor ?? Colors.grey),
          ],
        ],
      ),
    );
  }
}
