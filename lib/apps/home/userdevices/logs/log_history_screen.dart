import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class LogsHistoryScreen extends ConsumerWidget {
  final String deviceId;
  const LogsHistoryScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final yearField = 'year_${selectedDate.year}';
    final monthField = 'month_${selectedDate.month.toString().padLeft(2, '0')}';
    final dayField = 'day_${selectedDate.day.toString().padLeft(2, '0')}';

    final documentRef =
        FirebaseFirestore.instance.collection('Logs').doc(deviceId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: documentRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No logs available.'));
          }

          final fullData = snapshot.data!.data() as Map<String, dynamic>;
          if (!fullData.containsKey(yearField) ||
              !(fullData[yearField] as Map).containsKey(monthField) ||
              !(fullData[yearField][monthField] as Map).containsKey(dayField)) {
            return const Center(child: Text('No logs for this date.'));
          }

          final dayData =
              fullData[yearField][monthField][dayField] as Map<String, dynamic>;

          List<MapEntry<String, dynamic>> hourEntries = dayData.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)); // Sort hours ascending

          List<Map<String, dynamic>> logs = [];

          for (var hourEntry in hourEntries) {
            final hourData = hourEntry.value as Map<String, dynamic>;
            final hour = hourEntry.key;

            hourData.forEach((minuteKey, readingData) {
              logs.add({
                'hour': hour,
                'minute': minuteKey,
                'data': readingData,
              });
            });
          }

          if (logs.isEmpty) {
            return const Center(child: Text('No logs for selected day.'));
          }

          logs.sort((a, b) {
            int hourA = int.parse(a['hour'].split('_')[1]);
            int minuteA = int.parse(a['minute'].split('_')[1]);
            int hourB = int.parse(b['hour'].split('_')[1]);
            int minuteB = int.parse(b['minute'].split('_')[1]);
            return (hourA * 60 + minuteA).compareTo(hourB * 60 + minuteB);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final log = logs[index];
              final data = log['data'] as Map<String, dynamic>;

              final timeString =
                  "${log['hour'].split('_')[1]}:${log['minute'].split('_')[1]}";

              return ListTile(
                title: Text(
                    "Temp: ${data['temperature']}°C | Humidity: ${data['humidity']}%"),
                subtitle: Text(
                    "Heat Index: ${data['heat_index']}°C | Gas: ${data['gas_detection']}"),
                trailing:
                    Text(timeString, style: const TextStyle(fontSize: 12)),
              );
            },
          );
        },
      ),
    );
  }
}
