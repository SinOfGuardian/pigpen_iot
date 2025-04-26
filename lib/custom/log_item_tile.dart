import 'package:flutter/material.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';

class LogItemTile extends StatelessWidget {
  final LogModel log;

  const LogItemTile({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(log.fileName),
      subtitle: Text('${log.date.toLocal()}'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(log.fileName),
            content: SingleChildScrollView(
              child: Text(log.data.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
