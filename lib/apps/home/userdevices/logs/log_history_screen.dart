import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

final logsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final database = FirebaseDatabase.instance.ref();
  final snapshot = await database
      .child(
          'realtime/logs/pigpeniot-38eba81f8a3c/year_2025/month_04/day_26/hour_17/minute_22')
      .get();

  if (snapshot.exists) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    final logs = data.values.map((e) => e.toString()).toList();
    logs.sort(); // Optional: sort if needed
    return logs;
  } else {
    return [];
  }
});

class LogsHistoryScreen extends ConsumerWidget {
  const LogsHistoryScreen({Key? key}) : super(key: key);

  Future<void> _refreshLogs(WidgetRef ref) async {
    ref.invalidate(logsProvider); // Only invalidate, don't await future
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsProvider);

    return RefreshIndicator(
      onRefresh: () => _refreshLogs(ref),
      child: logsAsync.when(
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('No logs found.'))
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.article),
                    title: Text(logs[index]),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
