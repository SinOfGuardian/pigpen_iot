import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';

class ScheduledWateringPage extends ConsumerWidget {
  final Widget schedulesList;
  const ScheduledWateringPage({super.key, required this.schedulesList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final thing = ref.watch(activeDeviceProvider);

    return Scaffold(
      appBar: TitledAppBar(
        title: 'Scheduled Watering',
        leadingIcon: EvaIcons.arrowBackOutline,
        trailingIcon: EvaIcons.questionMark,
        trailingAction: () {},
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FormTitle(thing?.deviceName ?? 'Name not available', maxLines: 2),
              Expanded(child: schedulesList),
            ],
          ),
        ),
      ),
    );
  }
}
