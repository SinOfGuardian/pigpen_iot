import 'package:flutter/material.dart';

Future<TimeOfDay?> pickTime(BuildContext context, DateTime initialDate) =>
    showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: initialDate.hour, minute: initialDate.minute));

Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) =>
    showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 20));
