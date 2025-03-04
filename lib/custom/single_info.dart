import 'package:flutter/material.dart';

class SingleInfo extends StatelessWidget {
  final String text;
  final String label;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  const SingleInfo({
    super.key,
    required this.text,
    required this.label,
    this.padding,
    this.margin = const EdgeInsets.only(top: 0, bottom: 20),
  });

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dataStyle = textTheme.bodyLarge;
    final labelStyle = textTheme.labelLarge;

    return Container(
      alignment: Alignment.centerLeft,
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: dataStyle),
          const SizedBox(height: 5),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }
}

class DoubleInfo extends StatelessWidget {
  final String label1, label2, info1, info2;
  final int flex1, flex2;
  const DoubleInfo({
    super.key,
    required this.label1,
    required this.label2,
    required this.info1,
    required this.info2,
    this.flex1 = 1,
    this.flex2 = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: flex1, child: SingleInfo(text: info1, label: label1)),
        const SizedBox(width: 20),
        Expanded(flex: flex2, child: SingleInfo(text: info2, label: label2)),
      ],
    );
  }
}
