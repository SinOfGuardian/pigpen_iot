// ignore_for_file: file_names

import 'package:flutter/material.dart';

class HyperLinkText extends StatelessWidget {
  const HyperLinkText(
      {required this.text,
      required this.hyperlink,
      required this.onPressed,
      super.key});

  final String text, hyperlink;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: textTheme.labelLarge),
          GestureDetector(
            onTap: onPressed,
            child: Text(
              hyperlink,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
