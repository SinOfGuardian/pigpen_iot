import 'package:flutter/material.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/modules/dateformats.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';

/// Implementation of `SchedulePreviewer` shown as dialog.
Future<T?> showSchedulePreviewer<T>(context,
    {required DateTime dateTime, required Log log}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SchedulePreviewer(
        log: log,
        dateTime: dateTime,
      );
    },
  );
}

class SchedulePreviewer extends StatelessWidget {
  /// Must be implemented inside a `shownDialog()`, or you can just call
  /// `showSchedulePreviewer()`
  ///
  /// ```dart
  /// showSchedulePreviewer(context, dateTime: dateTime, log: log);
  /// ````
  ///
  /// Implementations:
  /// ```dart
  /// return showDialog(
  ///   context: context,
  ///   builder: (context) {
  ///     return SchedulePreviewer(
  ///       log: log,
  ///       dateTime: dateTime,
  ///     );
  ///   },
  /// );
  /// ```
  const SchedulePreviewer({
    super.key,
    required this.log,
    required this.dateTime,
  });
  final DateTime dateTime;
  final Log log;

  Widget _title() {
    return Row(
      children: [
        SectionLabel(
          log.title.toCapitalizeFirst(),
          margin: null,
          width: null,
        ),
      ],
    );
  }

  Widget _messageContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(log.description),
    );
  }

  Widget _sched(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dateFormatter = AppDateFormat();

    final dateValue = dateFormatter.monthDayYear(dateTime);
    final timeValue = dateFormatter.timeShort(dateTime);
    final dayValue = dateFormatter.dayFull(dateTime);

    const dayTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    const timeTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    const dateTextStyle = TextStyle(fontSize: 12, color: Colors.grey);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDarkMode ? log.colorDark : log.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(dayValue, style: dayTextStyle),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(timeValue, style: timeTextStyle),
            const SizedBox(height: 3),
            Text(dateValue, style: dateTextStyle),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(),
            _messageContent(),
            _sched(context),
          ],
        ),
      ),
    );
  }
}
