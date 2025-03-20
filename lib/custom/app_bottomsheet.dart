import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_text.dart';


Future<T?> titledBottomNotesSheet<T>({
  required BuildContext context,
  required String title,
  required String message,
  MainAxisAlignment titleAlign = MainAxisAlignment.start,
  TextAlign messageAlign = TextAlign.start,
  Alignment buttonAlignment = Alignment.center,
  String buttonText = 'Okay',
  IconData? icon,
  bool showDragHandle = true,
  Color? iconColor,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: showDragHandle,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: SectionLabel(title,
                  leadingIcon: icon,
                  alignment: titleAlign,
                  iconColor: iconColor,
                  margin: const EdgeInsets.only(bottom: 10)),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                message,
                textAlign: messageAlign,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: buttonAlignment,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(buttonText),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}
