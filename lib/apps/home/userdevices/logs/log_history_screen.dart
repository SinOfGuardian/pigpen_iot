import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class LogsHistoryScreen extends ConsumerWidget {
  final String deviceId;

  const LogsHistoryScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final datePath = DateFormat('yyyy-MM-dd').format(selectedDate);
    final databaseRef =
        FirebaseDatabase.instance.ref('logs/$deviceId/$datePath').orderByKey();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<DatabaseEvent>(
          stream: databaseRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return const Center(child: Text("No logs available."));
            }

            final rawData =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final logs = rawData.entries.toList()
              ..sort(
                  (a, b) => a.key.compareTo(b.key)); // Sort by time ascending

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(selectedDateProvider);
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final logTime = logs[index].key;
                  final data = logs[index].value as Map<dynamic, dynamic>;

                  return ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time,
                            size: 20, color: Colors.blueGrey),
                        Text(
                          logTime.toString().substring(0, 5),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    title: Text(
                        "Temp: ${data['temperature']}°C | Humidity: ${data['humidity']}%"),
                    subtitle: Text(
                        "Heat Index: ${data['heatIndex']}°C | Gas: ${data['gasDetection']}"),
                    trailing: Text(
                      logTime.toString().replaceAll(':', ':'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
