import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

@immutable
class Log {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color colorDark;
  const Log({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.colorDark,
  });
}

const scheduleLog = Log(
  title: 'Scheduled',
  description: 'This schedule is in queue.',
  color: Color.fromARGB(255, 241, 246, 249),
  colorDark: Color.fromARGB(255, 25, 35, 36),
  icon: EvaIcons.calendarOutline,
);
const succeededLog = Log(
  title: 'Succeeded',
  description: 'This schedule has watered successfully.',
  color: Color.fromARGB(255, 243, 250, 242),
  colorDark: Color.fromARGB(255, 30, 37, 29),
  icon: EvaIcons.checkmarkCircle,
);
const failedLog = Log(
  title: 'Failed',
  description: 'This schedule has failed to water.',
  color: Color.fromARGB(255, 253, 239, 235),
  colorDark: Color.fromARGB(255, 37, 29, 25),
  icon: EvaIcons.alertTriangleOutline,
);
const deletedLog = Log(
  title: 'Deleted',
  description: 'This schedule has been deleted by the user.',
  color: Color.fromARGB(255, 251, 240, 240),
  colorDark: Color.fromARGB(255, 37, 26, 26),
  icon: EvaIcons.trash2Outline,
);
