// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MonitoringLogsScreen extends ConsumerWidget {
  final String deviceId;
  const MonitoringLogsScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logRef = FirebaseFirestore.instance
        .collection('monitoring_logs')
        .doc(deviceId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(100);

    return Scaffold(
      appBar: AppBar(title: const Text("Monitoring History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: logRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No logs available."));
          }

          final logs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              final time = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedTime = time != null
                  ? DateFormat("MMM dd, yyyy • hh:mm a").format(time)
                  : 'No time';

              return ListTile(
                title: Text("Temp: ${data['temp']}°C | PPM: ${data['ppm']}"),
                subtitle: Text(
                    "Humidity: ${data['humid']}% | Heat: ${data['heatIndex']}°C"),
                trailing: Text(formattedTime),
              );
            },
          );
        },
      ),
    );
  }
}
