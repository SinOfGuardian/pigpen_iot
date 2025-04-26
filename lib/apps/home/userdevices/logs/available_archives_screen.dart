import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'archived_logs_screen.dart';

class AvailableArchivesScreen extends StatefulWidget {
  final String deviceId;
  const AvailableArchivesScreen({super.key, required this.deviceId});

  @override
  State<AvailableArchivesScreen> createState() =>
      _AvailableArchivesScreenState();
}

class _AvailableArchivesScreenState extends State<AvailableArchivesScreen> {
  List<Map<String, dynamic>> archiveFiles = [];
  bool isLoading = true;
  bool hasError = false;

  // 🔥 YOUR Firebase Storage bucket name (example: pigpen-iot.appspot.com)
  final String storageBucket = 'pigpen-db.firebasestorage.app';

  Future<void> loadAvailableArchives() async {
    try {
      // Firebase Storage REST API to list objects
      final url =
          'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o?prefix=logs/${Uri.encodeComponent(widget.deviceId)}/&delimiter=/';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        setState(() {
          archiveFiles = items
              .map<Map<String, dynamic>>((item) => {
                    'name': item['name'],
                    'downloadTokens': item['downloadTokens'],
                  })
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading archive files: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadAvailableArchives();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (hasError) {
      return const Scaffold(
        body: Center(child: Text("Failed to load archive files.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Available Archives')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: archiveFiles.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final file = archiveFiles[index];
          final fileName = file['name'] as String;
          final displayName = fileName.split('/').last.replaceAll('.json', '');

          return ListTile(
            title: Text(displayName),
            leading: const Icon(Icons.insert_drive_file),
            onTap: () {
              final downloadUrl =
                  'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o/${Uri.encodeFull(file['name'])}?alt=media&token=${file['downloadTokens']}';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArchivedLogsScreenFromUrl(url: downloadUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 👇 We create a version of ArchivedLogsScreen that accepts a direct URL
class ArchivedLogsScreenFromUrl extends StatefulWidget {
  final String url;
  const ArchivedLogsScreenFromUrl({super.key, required this.url});

  @override
  State<ArchivedLogsScreenFromUrl> createState() =>
      _ArchivedLogsScreenFromUrlState();
}

class _ArchivedLogsScreenFromUrlState extends State<ArchivedLogsScreenFromUrl> {
  Map<String, dynamic>? logsData;
  bool isLoading = true;
  bool hasError = false;

  Future<void> loadJson() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (hasError || logsData == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load archived logs.")),
      );
    }

    final dayKey = logsData!.keys.first;
    final logMap = logsData![dayKey] as Map<String, dynamic>;
    final sortedKeys = logMap.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Archived Logs')),
      body: ListView.separated(
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
                "Heat: ${entry['heatIndex']}°C | Gas: ${entry['gasDetection']}"),
            trailing: Text(time, style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }
}
