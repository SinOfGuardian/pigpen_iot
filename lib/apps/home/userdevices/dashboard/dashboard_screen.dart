import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/custom/app_container.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.secondaryContainer,
      child: Column(
        children: [
          const Expanded(flex: 9, child: UpperSection()),
          //const Expanded(flex: 10, child: BottomSection()),
          Container(height: 50, color: colorScheme.surface),
        ],
      ),
    );
  }
}

class UpperSection extends ConsumerWidget {
  const UpperSection({super.key});

  // Widget _dataSection(BuildContext context, WidgetRef ref) {
  //   final deviceId = ref
  //       .watch(activeDeviceProvider.select((thing) => thing?.deviceId ?? '?'));
  //   final nextSchedule = ref
  //       .watch(schedulesProvider(deviceId))
  //       .asData
  //       ?.value
  //       .firstOrNull
  //       ?.dateTime;

  //   final deviceProvider = ref.watch(deviceStreamProvider);
  //   return SizedBox(
  //     height: 290,
  //     child: deviceProvider.when(
  //       data: (device) {
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             _DataField(sensor: tempSensor, data: device.temperature),
  //             _DataField(sensor: humidSensor, data: device.humidity),
  //             _DataField(sensor: soilSensor, data: device.soilMoisture),
  //             _DataField(
  //               sensor: nextWatering,
  //               data: null,
  //               stringData: nextSchedule?.toString() ?? 'No schedule',
  //             ),
  //           ],
  //         );
  //       },
  //       loading: () => const AppCircularProgressIndicator(),
  //       error: (e, st) => AppErrorWidget(e as Exception, st, this),
  //     ),
  //   );
  // }

  // Widget _graphic(BuildContext context, WidgetRef ref) {
  //   final screenHeight = MediaQuery.of(context).size.height;
  //   final thing = ref.watch(activeDeviceProvider)!;
  //   return OverflowBox(
  //     alignment: Alignment.center,
  //     maxHeight: screenHeight * 0.36,
  //     maxWidth: screenHeight * 0.36,
  //     child: Hero(
  //         tag: thing.deviceId, child: AppCachedNetworkImage(thing.graphicUrl)),
  //   );
  // }

  Widget _camera(BuildContext context, WidgetRef ref) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text('Camera Section'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(child: _camera(context, ref)),
            //Expanded(child: _graphic(context, ref)),
          ],
        ),
      ),
    );
  }
}

class BottomSection extends ConsumerWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShaddowedContainer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: const Text('Activity'),
                    subtitle: const Text('Time'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
