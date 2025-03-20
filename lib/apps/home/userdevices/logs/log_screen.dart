import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:pigpen_iot/custom/app_header.dart';
import 'package:pigpen_iot/custom/app_schedule_previewer_dialog.dart';
import 'package:pigpen_iot/modules/dateformats.dart';

/// This is a temporary data of List<DateTime>, an actual must be from database
List<DateTime> _generateRandomDateTimes() {
  List<DateTime> dateTimes = [];
  final random = Random();
  final length = random.nextInt(8) + 2;
  for (int i = 0; i < length; i++) {
    int days = random.nextInt(365);
    int hours = random.nextInt(24);
    int min = random.nextInt(60);
    dateTimes.add(
        DateTime.now().add(Duration(days: days, hours: hours, minutes: min)));
  }
  return dateTimes;
}

const _pageTitle = 'Logs';
const _pageDescription =
    'Logs is read only, here you can watch schedules that had succeeded, '
    'failed, or gets deleted.';

/// Logs Page
class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  Widget _header() {
    return Consumer(
      builder: (context, ref, child) {
        final url = ref
            .watch(activeDeviceProvider.select((thing) => thing!.graphicUrl));
        return Header.titleWithDeviceGraphic(
          title: _pageTitle,
          description: _pageDescription,
          graphicUrl: url,
        );
      },
    );
  }

  Widget _body() {
    return Expanded(
        child: Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _LogsBuilder(
                  log: scheduleLog,
                  data: _generateRandomDateTimes(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LogsBuilder(
                  log: succeededLog,
                  data: _generateRandomDateTimes(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _LogsBuilder(
                  log: failedLog,
                  data: _generateRandomDateTimes(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LogsBuilder(
                  log: deletedLog,
                  data: _generateRandomDateTimes(),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            _body(),
          ],
        ),
      ),
    );
  }
}

class _LogsBuilder extends StatelessWidget {
  final Log log;
  final List<DateTime> data;
  const _LogsBuilder({required this.data, required this.log});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Row(
            children: [
              Icon(log.icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(log.title, style: textTheme.titleMedium),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => _SingleLog(
              dateTime: data[index],
              log: log,
            ),
          ),
        ),
      ],
    );
  }
}

class _SingleLog extends StatelessWidget {
  final Log log;
  final DateTime dateTime;
  const _SingleLog({required this.dateTime, required this.log});

  void _onTappedLog(BuildContext context) {
    showSchedulePreviewer(context, dateTime: dateTime, log: log);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dateFormatter = AppDateFormat();

    final dateValue = dateFormatter.monthDayYear(dateTime);
    final timeValue = dateFormatter.timeShort(dateTime);
    final dayValue = dateFormatter.dayFull(dateTime).substring(0, 2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        child: ListTile(
          dense: true,
          onTap: () => _onTappedLog(context),
          title: Text(
            timeValue,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            dateValue,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          leading: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDarkMode ? log.colorDark : log.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(dayValue, style: const TextStyle(fontSize: 16)),
          ),
          visualDensity: VisualDensity.compact,
          // tileColor: color.withOpacity(0.03),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
