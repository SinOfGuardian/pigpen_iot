import 'package:flutter/material.dart';

class LoaderDialog extends StatefulWidget {
  final Future<String?> Function({
    required Function(String message) onLog,
    required Function(double progress) onProgress,
  }) onConfirm;

  const LoaderDialog({super.key, required this.onConfirm});

  @override
  State<LoaderDialog> createState() => _LoaderDialogState();
}

class _LoaderDialogState extends State<LoaderDialog> {
  String status = "Preparing...";
  double progress = 0;
  bool isLoading = true;
  bool hasFailed = false;
  String? result;

  Future<void> _start() async {
    setState(() {
      progress = 0;
      status = "Starting...";
      isLoading = true;
      hasFailed = false;
    });

    result = await widget.onConfirm(
      onLog: (msg) => setState(() => status = msg),
      onProgress: (p) => setState(() => progress = p),
    );

    if (result == null) {
      setState(() {
        hasFailed = true;
        isLoading = false;
        status = "Failed. Try again?";
      });
    } else {
      if (mounted) Navigator.of(context).pop(result);
    }
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Processing Video"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) const CircularProgressIndicator(),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: isLoading && progress > 0 ? progress / 60 : null,
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Text(status, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        if (hasFailed)
          TextButton(
            onPressed: _start,
            child: const Text("Retry"),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
