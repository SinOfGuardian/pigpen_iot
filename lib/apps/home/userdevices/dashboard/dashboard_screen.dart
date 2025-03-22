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
import 'package:pigpen_iot/modules/responsive.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';

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
              TextButton(
                onPressed: () {},
                child: Text(
                  'Update Details',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    decoration: TextDecoration.underline, // Add underline
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => notifier.state = !isFavorited, // Toggle favorite state.
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
    return deviceProvider.when(
      data: (device) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Two columns for Temperature and Humidity
            Row(
              children: [
                Expanded(
                  child:
                      _DataField(sensor: tempSensor, data: device.temperature),
                ),
                const SizedBox(width: 10), // Add spacing between columns
                Expanded(
                  child: _DataField(sensor: humidSensor, data: device.humidity),
                ),
              ],
            ),
            const SizedBox(height: 5), // Add spacing between rows
            // Second Row: Two columns for Soil Moisture and an empty space
            Row(
              children: [
                Expanded(
                  child:
                      _DataField(sensor: gasSensor, data: device.gasDetection),
                ),
                const SizedBox(width: 16), // Add spacing between columns
                Expanded(
                  child:
                      _DataField(sensor: waterSensor, data: device.waterLevel),
                ),
              ],
            ),
            const SizedBox(height: 16), // Add spacing between rows
            // Third Row: Full width for Next Watering
            _DataField(
              sensor: nextWatering,
              data: null,
              stringData: nextSchedule?.toString() ?? 'No schedule',
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
    return ShaddowedContainer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deviceName(context, 'Device Name', ref),
            Expanded(
              child: _dataSection(context, ref),
            ),
            // _description(context, 'description'),
            // _characteristicSection(context),
          ],
        ),
      ),
    );
  }
}

class _DataField extends StatelessWidget {
  final int? data;
  final Sensor sensor;
  final String? stringData;
  const _DataField({required this.data, this.stringData, required this.sensor});

  // Helper function for gas level declaration
  String _getGasLevelDeclaration(int? ppm) {
    if (ppm == null) return '';
    if (ppm <= 10) return ' - Low';
    if (ppm <= 25) return ' - Moderate';
    if (ppm <= 50) return ' - High';
    return ' - Very High';
  }

  // Helper function for temperature declaration
  String _getTemperatureDeclaration(int? temp) {
    if (temp == null) return '';
    if (temp <= 10) return ' - Cold';
    if (temp <= 25) return ' - Comfortable';
    if (temp <= 35) return ' - Warm';
    return ' - Hot';
  }

  // Helper function for humidity declaration
  String _getHumidityDeclaration(int? humidity) {
    if (humidity == null) return '';
    if (humidity <= 30) return ' - Dry';
    if (humidity <= 60) return ' - Comfortable';
    return ' - Humid';
  }

  // Helper function for water level declaration
  String _getWaterLevelDeclaration(int? waterLevel) {
    if (waterLevel == null) return '';
    if (waterLevel <= 20) return ' - Low';
    if (waterLevel <= 50) return ' - Moderate';
    if (waterLevel <= 80) return ' - High';
    return ' - Very High';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const double maxWidth = 150;
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
                            : sensor == waterSensor
                                ? _getWaterLevelDeclaration(data)
                                : ''),
            style: textTheme.labelLarge,
          ),
          Text(
            (data ?? stringData ?? '').toString() + sensor.suffix,
            style: textTheme.headlineSmall?.copyWith(color: sensor.lineColor),
          ),
          data == null
              ? const SizedBox()
              : HorizontalProgressBar(
                  data: data?.toDouble(),
                  maxWidth: maxWidth,
                  min: sensor.min,
                  max: sensor.max,
                  lineColor: sensor.lineColor,
                ),
        ],
      ),
    );
  }
}

final favoriteProvider = StateProvider<bool>((ref) => false);
