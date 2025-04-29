import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_table_provider.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
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
  final humidMinCtrl = TextEditingController();
  final humidMaxCtrl = TextEditingController();
  final heatMinCtrl = TextEditingController();
  final heatMaxCtrl = TextEditingController();

  @override
  void dispose() {
    tempMinCtrl.dispose();
    tempMaxCtrl.dispose();
    humidMinCtrl.dispose();
    humidMaxCtrl.dispose();
    heatMinCtrl.dispose();
    heatMaxCtrl.dispose();
    gasMinCtrl.dispose();
    gasMaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = ref.watch(selectedLogDateProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _DatePicker(currentDate: currentDate, ref: ref),
            _FilterSection(
              tempMinCtrl: tempMinCtrl,
              tempMaxCtrl: tempMaxCtrl,
              gasMinCtrl: gasMinCtrl,
              gasMaxCtrl: gasMaxCtrl,
              humidMinCtrl: humidMinCtrl,
              humidMaxCtrl: humidMaxCtrl,
              heatMinCtrl: heatMinCtrl,
              heatMaxCtrl: heatMaxCtrl,
              ref: ref,
            ),
            Expanded(child: _LogTable(ref: ref)),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime currentDate;
  final WidgetRef ref;

  const _DatePicker({required this.currentDate, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 8),
          Text(
            DateFormat.yMMMMd().format(currentDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_calendar),
            label: const Text("Pick Date"),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              print('Selected Date: $currentDate');
              print('Picked Date: $picked');
              if (picked != null) {
                ref.read(selectedLogDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final TextEditingController tempMinCtrl;
  final TextEditingController tempMaxCtrl;
  final TextEditingController gasMinCtrl;
  final TextEditingController gasMaxCtrl;
  final TextEditingController humidMinCtrl;
  final TextEditingController humidMaxCtrl;
  final TextEditingController heatMinCtrl;
  final TextEditingController heatMaxCtrl;
  final WidgetRef ref;

  const _FilterSection({
    required this.tempMinCtrl,
    required this.tempMaxCtrl,
    required this.gasMinCtrl,
    required this.gasMaxCtrl,
    required this.humidMinCtrl,
    required this.humidMaxCtrl,
    required this.heatMinCtrl,
    required this.heatMaxCtrl,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final selectedHour = ref.watch(selectedHourProvider);
    final selectedMinute = ref.watch(selectedMinuteProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: .2),
          ExpansionTile(
            title: const Text("Advanced Filters"),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          FilterChip(
                            label: const Text("Show Temp"),
                            selected: ref.watch(showTempColumnProvider),
                            onSelected: (val) => ref
                                .read(showTempColumnProvider.notifier)
                                .state = val,
                          ),
                          FilterChip(
                            label: const Text("Show Humidity"),
                            selected: ref.watch(showHumidityColumnProvider),
                            onSelected: (val) => ref
                                .read(showHumidityColumnProvider.notifier)
                                .state = val,
                          ),
                          FilterChip(
                            label: const Text("Show Heat Index"),
                            selected: ref.watch(showHeatIndexColumnProvider),
                            onSelected: (val) => ref
                                .read(showHeatIndexColumnProvider.notifier)
                                .state = val,
                          ),
                          FilterChip(
                            label: const Text("Show Gas"),
                            selected: ref.watch(showGasColumnProvider),
                            onSelected: (val) => ref
                                .read(showGasColumnProvider.notifier)
                                .state = val,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: .10),
                    _RangeFilter(
                      label: "Temperature Range (°C)",
                      minCtrl: tempMinCtrl,
                      maxCtrl: tempMaxCtrl,
                      rangeProvider: tempRangeProvider,
                      ref: ref,
                    ),
                    _RangeFilter(
                      label: "Humidity Range (%)",
                      minCtrl: humidMinCtrl,
                      maxCtrl: humidMaxCtrl,
                      rangeProvider: humidRangeProvider,
                      ref: ref,
                    ),
                    _RangeFilter(
                      label: "Heat Index Range (°C)",
                      minCtrl: heatMinCtrl,
                      maxCtrl: heatMaxCtrl,
                      rangeProvider: heatindexRangeProvider,
                      ref: ref,
                    ),
                    _RangeFilter(
                      label: "Gas Detection Range (ppm)",
                      minCtrl: gasMinCtrl,
                      maxCtrl: gasMaxCtrl,
                      rangeProvider: gasRangeProvider,
                      ref: ref,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeFilter extends StatelessWidget {
  final String label;
  final TextEditingController minCtrl;
  final TextEditingController maxCtrl;
  final StateProvider<Tuple2<double?, double?>> rangeProvider;
  final WidgetRef ref;

  const _RangeFilter({
    required this.label,
    required this.minCtrl,
    required this.maxCtrl,
    required this.rangeProvider,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Row(
            children: [
              Flexible(
                child: AppTextField(
                  labelText: "Min",
                  controller: minCtrl,
                  keyboardType: TextInputType.number,
                  errorText: null,
                  textInputAction: TextInputAction.next,
                  onChanged: (val) {
                    final range = ref.read(rangeProvider);
                    ref.read(rangeProvider.notifier).state = Tuple2(
                      double.tryParse(val),
                      range.item2,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: AppTextField(
                  labelText: "Max",
                  controller: maxCtrl,
                  errorText: null,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final range = ref.read(rangeProvider);
                    ref.read(rangeProvider.notifier).state = Tuple2(
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
    );
  }
}

class _LogTable extends StatelessWidget {
  final WidgetRef ref;

  const _LogTable({required this.ref});

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsByDateProvider);
    final showTemp = ref.watch(showTempColumnProvider);
    final showHumid = ref.watch(showHumidityColumnProvider);
    final showHeat = ref.watch(showHeatIndexColumnProvider);
    final showGas = ref.watch(showGasColumnProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (logs) {
        if (logs.isEmpty) return const Center(child: Text("No logs found."));
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: [
                const DataColumn(label: Text("Time")),
                if (showTemp) const DataColumn(label: Text("Temp (°C)")),
                if (showHumid) const DataColumn(label: Text("Humidity (%)")),
                if (showHeat) const DataColumn(label: Text("Heat Index (°C)")),
                if (showGas) const DataColumn(label: Text("Gas (ppm)")),
              ],
              rows: logs
                  .map((log) => DataRow(cells: [
                        DataCell(Text(log.time)),
                        if (showTemp)
                          DataCell(Text(log.temperature.toString())),
                        if (showHumid) DataCell(Text(log.humidity.toString())),
                        if (showHeat) DataCell(Text(log.heatIndex.toString())),
                        if (showGas)
                          DataCell(Text(log.gasDetection.toStringAsFixed(2))),
                      ]))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
