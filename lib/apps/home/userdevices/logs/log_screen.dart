// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:pigpen_iot/custom/app_header.dart';
import 'package:pigpen_iot/custom/app_schedule_previewer_dialog.dart';
import 'package:pigpen_iot/modules/dateformats.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

const _pageTitle = 'Logs';
const _pageDescription =
    'Logs is read only, here you can watch schedules that had succeeded, '
    'failed, or gets deleted.';

final logsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
    (ref, deviceId) async {
  final snapshot =
      await FirebaseDatabase.instance.ref('/realtime/logs/$deviceId').get();

  final logs = <Map<String, dynamic>>[];

  if (snapshot.exists) {
    final raw = snapshot.value as Map;
    raw.forEach((key, value) {
      logs.add({
        'key': key,
        'dateTime': DateTime.parse(value['dateTime']),
        'status': value['status'],
        'category': value['category'],
      });
    });
  }

  return logs;
});

const timeoutLog = Log(
  title: 'Timeout',
  description: 'This schedule received no response.',
  icon: EvaIcons.clockOutline,
  color: Color.fromARGB(255, 255, 240, 228),
  colorDark: Color.fromARGB(255, 40, 30, 25),
);

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  Widget _header(WidgetRef ref) {
    final url =
        ref.watch(activeDeviceProvider.select((thing) => thing!.graphicUrl));
    return Header.titleWithDeviceGraphic(
      title: _pageTitle,
      description: _pageDescription,
      graphicUrl: url,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = ref
        .watch(activeDeviceProvider.select((thing) => thing?.deviceId ?? ''));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _header(ref),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(logsProvider(deviceId));
                },
                child: ref.watch(logsProvider(deviceId)).when(
                      data: (logs) => _buildLogsGrid(context, logs),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) =>
                          Center(child: Text('Error loading logs: $e')),
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLogsGrid(BuildContext context, List<Map<String, dynamic>> logs) {
    final grouped = {
      'scheduled': <Map<String, dynamic>>[],
      'success': <Map<String, dynamic>>[],
      'failed': <Map<String, dynamic>>[],
      'timeout': <Map<String, dynamic>>[],
    };

    for (var log in logs) {
      final status = log['status'];
      if (status == 'timeout') {
        grouped['failed']?.add(log); // Treat timeout as failed
      } else {
        grouped[status]?.add(log);
      }
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: _LogsBuilder(
                      log: scheduleLog, data: grouped['scheduled']!)),
              const SizedBox(width: 10),
              Expanded(
                  child: _LogsBuilder(
                      log: succeededLog, data: grouped['success']!)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child:
                      _LogsBuilder(log: failedLog, data: grouped['failed']!)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      _LogsBuilder(log: timeoutLog, data: grouped['timeout']!)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogsBuilder extends StatelessWidget {
  final Log log;
  final List<Map<String, dynamic>> data;
  const _LogsBuilder({required this.data, required this.log});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(log.icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(log.title, style: textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: data.isEmpty
              ? const Center(child: Text("No logs available."))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => _SingleLog(
                    log: log,
                    dateTime: data[index]['dateTime'],
                    category: data[index]['category'],
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
  final String category;
  const _SingleLog(
      {required this.dateTime, required this.log, required this.category});

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
            category.toTitleCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '($timeValue) - $dateValue',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
