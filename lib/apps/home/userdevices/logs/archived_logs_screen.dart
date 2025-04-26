import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ArchivedLogsScreen extends StatefulWidget {
  final String deviceId;
  final DateTime selectedDate;

  const ArchivedLogsScreen({
    super.key,
    required this.deviceId,
    required this.selectedDate,
  });

  @override
  State<ArchivedLogsScreen> createState() => _ArchivedLogsScreenState();
}

class _ArchivedLogsScreenState extends State<ArchivedLogsScreen> {
  Map<String, dynamic>? logsData;
  bool isLoading = true;
  bool hasError = false;

  Future<void> loadJson() async {
    try {
      final year = widget.selectedDate.year;
      final month = DateFormat('MMMM').format(widget.selectedDate); // April
      final weekNumber = weekOfYear(widget.selectedDate);
      final day = DateFormat('dd').format(widget.selectedDate); // 26

      // 🔥 Build the Storage download URL (adjust for your storage rules)
      final path =
          'logs/${widget.deviceId}/$year/$month/week$weekNumber/$day.json';
      final encodedPath = Uri.encodeFull(path);

      // NOTE: Replace 'your-project-id' with your actual Firebase project ID
      final downloadUrl =
          'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/$encodedPath?alt=media';

      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        logsData = json.decode(response.body);
        setState(() {
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading JSON: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError || logsData == null) {
      return const Center(child: Text("Failed to load archived logs."));
    }

    final dayKey = logsData!.keys.first;
    final logMap = logsData![dayKey] as Map<String, dynamic>;

    final sortedKeys = logMap.keys.toList()..sort();

    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: sortedKeys.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final time = sortedKeys[index];
            final entry = logMap[time] as Map<String, dynamic>;

            return ListTile(
              title: Text(
                  "Temp: ${entry['temperature']}°C | Humidity: ${entry['humidity']}%"),
              subtitle: Text(
                  "Heat Index: ${entry['heatIndex']}°C | Gas: ${entry['gasDetection']}"),
              trailing: Text(
                time,
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }

  int weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(firstDayOfYear).inDays;
    return ((daysPassed + firstDayOfYear.weekday) / 7).ceil();
  }
}
