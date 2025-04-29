import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_table_provider.dart';

class LogTableScreen extends ConsumerWidget {
  const LogTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedLogDateProvider);
    final logsAsync = ref.watch(logsByDateProvider);
    final selectedHour = ref.watch(selectedHourProvider);
    final selectedMinute = ref.watch(selectedMinuteProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // DATE PICKER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMMd().format(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text("Pick Date"),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        ref.read(selectedLogDateProvider.notifier).state =
                            picked;
                      }
                    },
                  ),
                ],
              ),
            ),

            // FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text("Hour:"),
                  const SizedBox(width: 8),
                  DropdownButton<String?>(
                    value: selectedHour,
                    hint: const Text("All"),
                    items: List.generate(
                            24, (i) => "hour_${i.toString().padLeft(2, '0')}")
                        .map((hour) {
                      return DropdownMenuItem(
                        value: hour,
                        child: Text(hour.replaceAll("hour_", "")),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        ref.read(selectedHourProvider.notifier).state = val,
                  ),
                  const SizedBox(width: 16),
                  const Text("Minute:"),
                  const SizedBox(width: 8),
                  DropdownButton<String?>(
                    value: selectedMinute,
                    hint: const Text("All"),
                    items: List.generate(
                            60, (i) => "minute_${i.toString().padLeft(2, '0')}")
                        .map((minute) {
                      return DropdownMenuItem(
                        value: minute,
                        child: Text(minute.replaceAll("minute_", "")),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        ref.read(selectedMinuteProvider.notifier).state = val,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: "Clear Filters",
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      ref.read(selectedHourProvider.notifier).state = null;
                      ref.read(selectedMinuteProvider.notifier).state = null;
                    },
                  ),
                ],
              ),
            ),

            // LOGS TABLE
            Expanded(
              child: logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (logs) {
                  if (logs.isEmpty)
                    return const Center(child: Text("No logs found."));
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Time")),
                        DataColumn(label: Text("Temp (°C)")),
                        DataColumn(label: Text("Humidity (%)")),
                        DataColumn(label: Text("Heat Index (°C)")),
                        DataColumn(label: Text("Gas (ppm)")),
                      ],
                      rows: logs
                          .map(
                            (log) => DataRow(
                              cells: [
                                DataCell(Text(log.time)),
                                DataCell(Text(log.temperature.toString())),
                                DataCell(Text(log.humidity.toString())),
                                DataCell(Text(log.heatIndex.toString())),
                                DataCell(
                                    Text(log.gasDetection.toStringAsFixed(2))),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
