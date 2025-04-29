import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_table_provider.dart';
import 'package:tuple/tuple.dart';

class LogTableScreen extends ConsumerStatefulWidget {
  const LogTableScreen({super.key});

  @override
  ConsumerState<LogTableScreen> createState() => _LogTableScreenState();
}

class _LogTableScreenState extends ConsumerState<LogTableScreen> {
  final tempMinCtrl = TextEditingController();
  final tempMaxCtrl = TextEditingController();
  final gasMinCtrl = TextEditingController();
  final gasMaxCtrl = TextEditingController();

  @override
  void dispose() {
    tempMinCtrl.dispose();
    tempMaxCtrl.dispose();
    gasMinCtrl.dispose();
    gasMaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            // FILTER DROPDOWNS
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
                      ref.read(tempRangeProvider.notifier).state =
                          const Tuple2(null, null);
                      ref.read(gasRangeProvider.notifier).state =
                          const Tuple2(null, null);
                      tempMinCtrl.clear();
                      tempMaxCtrl.clear();
                      gasMinCtrl.clear();
                      gasMaxCtrl.clear();
                    },
                  ),
                ],
              ),
            ),

            // RANGE FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Temperature Range (°C)"),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: tempMinCtrl,
                          decoration:
                              const InputDecoration(hintText: "Min Temp"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final range = ref.read(tempRangeProvider);
                            ref.read(tempRangeProvider.notifier).state = Tuple2(
                              double.tryParse(val),
                              range.item2,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextField(
                          controller: tempMaxCtrl,
                          decoration:
                              const InputDecoration(hintText: "Max Temp"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final range = ref.read(tempRangeProvider);
                            ref.read(tempRangeProvider.notifier).state = Tuple2(
                              range.item1,
                              double.tryParse(val),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("Gas Detection Range (ppm)"),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: gasMinCtrl,
                          decoration:
                              const InputDecoration(hintText: "Min Gas"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final range = ref.read(gasRangeProvider);
                            ref.read(gasRangeProvider.notifier).state = Tuple2(
                              double.tryParse(val),
                              range.item2,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextField(
                          controller: gasMaxCtrl,
                          decoration:
                              const InputDecoration(hintText: "Max Gas"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final range = ref.read(gasRangeProvider);
                            ref.read(gasRangeProvider.notifier).state = Tuple2(
                              range.item1,
                              double.tryParse(val),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TABLE
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
