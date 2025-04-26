// logs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logs_provider.dart';
import 'logs_model.dart';

class LogsHistoryScreen extends ConsumerStatefulWidget {
  const LogsHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LogsHistoryScreen> createState() => _LogsHistoryScreenState();
}

class _LogsHistoryScreenState extends ConsumerState<LogsHistoryScreen> {
  String deviceId = 'pigpeniot-38eba81f8a3c';
  DateTime selectedDateTime = DateTime.now();

  Future<void> _refreshLogs() async {
    ref.invalidate(logsStreamProvider(_currentParams));
  }

  LogQueryParams get _currentParams => LogQueryParams(
        deviceId: deviceId,
        year: selectedDateTime.year,
        month: selectedDateTime.month,
        day: selectedDateTime.day,
        hour: selectedDateTime.hour,
        minute: selectedDateTime.minute,
      );

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        _refreshLogs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsStreamProvider(_currentParams));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _pickDateTime,
            icon: const Icon(Icons.date_range),
            label: const Text('Pick Date & Time'),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshLogs,
            child: logsAsync.when(
              data: (logs) => logs.isEmpty
                  ? const Center(child: Text('No logs found.'))
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(log.time,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text('Temp: ${log.temp.toStringAsFixed(1)}°C'),
                              Text('Humid: ${log.humid.toStringAsFixed(1)}%'),
                              Text('Heat: ${log.heat.toStringAsFixed(1)}°C'),
                              Text('Gas: ${log.gas}'),
                            ],
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ],
    );
  }
}
