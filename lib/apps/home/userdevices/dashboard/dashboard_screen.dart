import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/apps/home/userdevices/monitoring/monitoring_model.dart';
import 'package:pigpen_iot/apps/home/userdevices/monitoring/monitoring_viewmodel.dart';
import 'package:pigpen_iot/apps/home/userdevices/schedules/schedule_viewmodel.dart';
import 'package:pigpen_iot/custom/app_animated_widget.dart';
import 'package:pigpen_iot/custom/app_circularprogressindicator.dart';
import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_error_handling.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/modules/responsive.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';
import 'package:pigpen_iot/services/notification_service.dart';
import 'package:intl/intl.dart'; // Ensure this is at the top

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.secondaryContainer,
      child: Column(
        children: [
          const Expanded(flex: 7, child: UpperSection()),
          const Expanded(flex: 10, child: BottomSection()),
          Container(height: 50, color: colorScheme.surface),
        ],
      ),
    );
  }
}

class UpperSection extends ConsumerWidget {
  const UpperSection({super.key});

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
      height: 200,
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

  Widget _deviceName(BuildContext context, String? deviceName, WidgetRef ref) {
    final isFavorited = ref.watch(favoriteProvider);
    final notifier = ref.read(favoriteProvider.notifier);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormTitle(
                (deviceName ?? 'Name not available').toTitleCase(),
                maxLines: isAppInFloatingWindow(context) ? 2 : 3,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => notifier.state = !isFavorited,
          child: Icon(
            isFavorited ? Ionicons.heart : Ionicons.heart_outline,
            size: 30,
            color: isFavorited ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _dataSection(BuildContext context, WidgetRef ref) {
    final deviceId = ref
        .watch(activeDeviceProvider.select((thing) => thing?.deviceId ?? '?'));
    final nextSchedule = ref
        .watch(schedulesProvider(deviceId))
        .asData
        ?.value
        .firstOrNull
        ?.dateTime;

    final deviceProvider = ref.watch(deviceStreamProvider);
    final firebaseService = DeviceFirebase();
    final drumManualProvider = StateProvider<bool>((ref) => false);
    final drinklerManualProvider = StateProvider<bool>((ref) => false);

    //bool isDrinklerManual = false;
    // bool isDrumManual = false;

    return deviceProvider.when(
      data: (device) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Heat Index + Gas
            Row(
              children: [
                Expanded(
                  child: _DataField(
                      sensor: heatIndexSensor, data: device.heatIndex),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DataField(
                      sensor: gasSensor, data: device.gasDetection.toDouble()),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Drum + Drinkler water levels
            Row(
              children: [
                Expanded(
                  child: _DataField(
                      sensor: drumwaterSensor, data: device.drumwaterLevel),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DataField(
                      sensor: drinklerwaterSensor,
                      data: device.drinklerwaterLevel),
                ),
              ],
            ),

            const SizedBox(height: 2),

            // 🔘 Manual Controls
            Row(
              children: [
                Text("Sprinkler Manual",
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Consumer(builder: (context, ref, _) {
                  final isDrumManual = ref.watch(drumManualProvider);
                  return Switch(
                    value: isDrumManual,
                    onChanged: (value) async {
                      final drumLevel =
                          ref.read(deviceStreamProvider).maybeWhen(
                                data: (device) => device.drumwaterLevel,
                                orElse: () => null,
                              );

                      if (value && drumLevel == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Drum is empty! Please refill before activating sprinkler.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      ref.read(drumManualProvider.notifier).state = value;
                      await firebaseService.setManualDuration(
                        deviceId: deviceId,
                        type: 'sprinkler',
                        duration: value ? 5 : 0,
                      );
                    },
                  );
                }),
              ],
            ),

            //  const SizedBox(height: 5),
            Row(
              children: [
                Text("Drinkler Manual",
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Consumer(builder: (context, ref, _) {
                  final isDrinklerManual = ref.watch(drinklerManualProvider);
                  return Switch(
                    value: isDrinklerManual,
                    onChanged: (value) async {
                      final drumLevel =
                          ref.read(deviceStreamProvider).maybeWhen(
                                data: (device) => device.drumwaterLevel,
                                orElse: () => null,
                              );

                      if (value && drumLevel == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Drum is empty! Please refill before activating drinkler.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      ref.read(drinklerManualProvider.notifier).state = value;
                      await firebaseService.setManualDuration(
                        deviceId: deviceId,
                        type: 'drinkler',
                        duration: value ? 5 : 0,
                      );
                    },
                  );
                }),
              ],
            ),

            // const SizedBox(height: 10),

            // 📅 Next Watering Time (moved here)
            Row(
              children: [
                Expanded(
                  child: _DataField(
                    sensor: nextWatering,
                    data: null,
                    stringData: nextSchedule != null
                        ? DateFormat('yyyy/MM/dd HH:mm').format(nextSchedule)
                        : 'No schedule',
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const AppCircularProgressIndicator(),
      error: (e, st) => AppErrorWidget(e as Exception, st, this),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDevice = ref.watch(activeDeviceProvider);
    return ShaddowedContainer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deviceName(context, userDevice?.deviceName, ref),
            Expanded(
              child: _dataSection(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDeviceDetailsSheet extends ConsumerStatefulWidget {
  final String? deviceName;
  const EditDeviceDetailsSheet({super.key, this.deviceName});

  @override
  ConsumerState<EditDeviceDetailsSheet> createState() =>
      _EditDeviceDetailsSheetState();
}

class _EditDeviceDetailsSheetState
    extends ConsumerState<EditDeviceDetailsSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.deviceName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveDeviceName() async {
    final newName = _controller.text.trim();
    final device = ref.read(activeDeviceProvider);

    if (device != null && newName.isNotEmpty) {
      // Update Firebase
      await DeviceFirebase().updateDeviceName(device.deviceId, newName);

      // Update local provider
      ref.read(activeDeviceProvider.notifier).state =
          device.copyWith(deviceName: newName);

      Navigator.of(context).pop(); // Close sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Edit Device Name',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveDeviceName,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DataField extends StatelessWidget {
  final num? data;
  final Sensor sensor;
  final String? stringData;
  const _DataField({required this.data, this.stringData, required this.sensor});

  // Helper functions for status declarations
  String _getGasLevelDeclaration(num? ppm) {
    if (ppm == null) return '';
    if (ppm <= 10) return ' - Low';
    if (ppm <= 25) return ' - Moderate';
    if (ppm <= 50) return ' - High';
    return ' - Very High';
  }

  String _getTemperatureDeclaration(num? temp) {
    if (temp == null) return '';
    if (temp <= 10) return ' - Cold';
    if (temp <= 25) return ' - Comfortable';
    if (temp <= 35) return ' - Warm';
    return ' - Hot';
  }

  String _getHumidityDeclaration(num? humidity) {
    if (humidity == null) return '';
    if (humidity <= 30) return ' - Dry';
    if (humidity <= 60) return ' - Comfortable';
    return ' - Humid';
  }

  String _getHeatIndexStatus(num? heatIndex) {
    if (heatIndex == null) return '';
    if (heatIndex < 25) return ' - Safe';
    if (heatIndex < 28) return ' - Warning';
    if (heatIndex < 32) return ' - Danger';
    return ' - Emergency';
  }

  // String _getDrumWaterLevelDeclaration(num? waterLevel) {
  //   if (waterLevel == null) return '- Unknown';
  //   return waterLevel == 1 ? ' - Water Drum Present' : ' - Empty';
  // }

  // String _getDrinklerWaterLevelDeclaration(num? waterLevel) {
  //   if (waterLevel == null) return '- Unknown';
  //   return waterLevel == 1 ? ' - Water Drinkler Present' : ' - Empty';
  // }

  // Improved notification logic
  void _checkAndTriggerNotification(BuildContext context, WidgetRef ref) {
    if (data == null) return;

    final notificationState = ref.read(notificationStateProvider);
    final sensorKey = sensor.title;
    bool shouldNotify = false;
    String notificationTitle = '';
    String notificationBody = '';

    switch (sensor) {
      case gasSensor:
        if (data! > 50) {
          notificationTitle = '⚠️ High Ammonia Level!';
          notificationBody =
              'Ammonia level is very high (${data!.toStringAsFixed(1)} ppm).';
          shouldNotify = true;
        }
        break;

      case heatIndexSensor:
        if (data! >= 32) {
          notificationTitle = '🚨 Heat Emergency!';
          notificationBody =
              'Heat index is dangerously high (${data!.toStringAsFixed(1)}°C).';
          shouldNotify = true;
        } else if (data! >= 28 && !(notificationState[sensorKey] ?? false)) {
          notificationTitle = '⚠️ Heat Warning!';
          notificationBody =
              'Heat index is high (${data!.toStringAsFixed(1)}°C).';
          shouldNotify = true;
        }
        break;

      case drumwaterSensor:
        if (data == 0) {
          notificationTitle = '🚰 Drum Water Empty';
          notificationBody = 'Drum water level is low. Please refill the drum.';
          shouldNotify = true;
        }
        break;

      case drinklerwaterSensor:
        final drumLevel = ref.watch(deviceStreamProvider).maybeWhen(
            data: (device) => device.drumwaterLevel, orElse: () => null);

        if (data == 0) {
          if (drumLevel == 1) {
            notificationTitle = '💧 Drink Water Auto Refill';
            notificationBody =
                'Drink water level is low. Activating automatic refill from drum.';
          } else {
            notificationTitle = '❗ Refill Drum First';
            notificationBody =
                'Drink water is low, but drum is also empty. Please refill drum before auto refill.';
          }
          shouldNotify = true;
        }
        break;

      case tempSensor:
        if (data! > 35) {
          notificationTitle = '🌡️ High Temperature!';
          notificationBody =
              'Temperature is very high (${data!.toStringAsFixed(1)}°C).';
          shouldNotify = true;
        }
        break;

      case humidSensor:
        if (data! > 60) {
          notificationTitle = '💧 High Humidity!';
          notificationBody =
              'Humidity is very high (${data!.toStringAsFixed(1)}%).';
          shouldNotify = true;
        }
        break;
    }

    // Only notify if we haven't already notified for this state
    if (shouldNotify && !(notificationState[sensorKey] ?? false)) {
      NotificationService.scheduleLocalNotification(
        title: notificationTitle,
        body: notificationBody,
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
        payload: sensorKey,
      );
      ref.read(notificationStateProvider.notifier).state = {
        ...notificationState,
        sensorKey: true,
      };
    } else if (!shouldNotify && notificationState[sensorKey] == true) {
      // Reset notification state when values return to normal
      ref.read(notificationStateProvider.notifier).state = {
        ...notificationState,
        sensorKey: false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const double maxWidth = 150;

    return Consumer(
      builder: (context, ref, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndTriggerNotification(context, ref);
        });

        final isWaterSensor =
            sensor == drumwaterSensor || sensor == drinklerwaterSensor;
        final showValue = !isWaterSensor;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sensor.title.toCapitalizeFirst() +
                    (sensor == gasSensor
                        ? _getGasLevelDeclaration(data)
                        : sensor == tempSensor
                            ? _getTemperatureDeclaration(data)
                            : sensor == humidSensor
                                ? _getHumidityDeclaration(data)
                                : sensor == heatIndexSensor
                                    ? _getHeatIndexStatus(data?.toInt())
                                    : ''),
                style: textTheme.labelLarge,
              ),
              if (showValue)
                Text(
                  (data?.toStringAsFixed(sensor == gasSensor ? 1 : 0) ??
                          stringData ??
                          '') +
                      sensor.suffix,
                  style: textTheme.headlineSmall
                      ?.copyWith(color: sensor.lineColor),
                ),
              if (isWaterSensor)
                Row(
                  children: [
                    Icon(
                      Ionicons.water_outline,
                      color: data == 1 ? Colors.blue : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data == 1 ? 'Water is here 🐳' : 'Time to refill 🔄',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: data == 1 ? Colors.blue : Colors.red,
                      ),
                    ),
                  ],
                )
              else if (data != null)
                HorizontalProgressBar(
                  data: data?.toDouble(),
                  maxWidth: maxWidth,
                  min: sensor.min,
                  max: sensor.max,
                  lineColor: sensor.lineColor,
                ),
            ],
          ),
        );
      },
    );
  }
}

final favoriteProvider = StateProvider<bool>((ref) => false);
final notificationStateProvider = StateProvider<Map<String, bool>>((ref) => {});
