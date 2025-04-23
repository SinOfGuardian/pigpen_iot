// control_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/provider/device_setting_provider.dart';
import 'package:pigpen_iot/provider/device_parameters_provider.dart';

class ControlPanelScreen extends ConsumerWidget {
  final String deviceId;
  const ControlPanelScreen({super.key, required this.deviceId});

  Future<bool> _confirmAction(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context, false)),
              ElevatedButton(
                  child: const Text("Confirm"),
                  onPressed: () => Navigator.pop(context, true)),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseService = DeviceFirebase();
    final drinkerDuration = ref.watch(localDrinkerDurationProvider);
    final sprinklerDuration = ref.watch(localSprinklerDurationProvider);
    final drinkerNotifier = ref.read(localDrinkerDurationProvider.notifier);
    final sprinklerNotifier = ref.read(localSprinklerDurationProvider.notifier);
    final parametersAsync = ref.watch(parameterStreamProvider(deviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Control Panel'),
      ),
      body: parametersAsync.when(
        data: (params) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(parameterStreamProvider(deviceId)),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text("Sprinkler Duration (manual)",
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                min: 1,
                max: 180,
                divisions: 179,
                label: "$sprinklerDuration sec",
                value: sprinklerDuration.toDouble(),
                onChanged: (val) {
                  sprinklerNotifier.set(val.round());
                  ref.invalidate(parameterStreamProvider(deviceId));
                },
              ),
              const Divider(height: 30),
              Text("Drinker Duration (manual)",
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                min: 1,
                max: 180,
                divisions: 179,
                label: "$drinkerDuration sec",
                value: drinkerDuration.toDouble(),
                onChanged: (val) {
                  drinkerNotifier.set(val.round());
                  ref.invalidate(parameterStreamProvider(deviceId));
                },
              ),
              const Divider(height: 30),
              Text("Trigger Parameters",
                  style: Theme.of(context).textTheme.titleLarge),
              _buildParamEditor(context, ref, "Heat Index Trigger",
                  "heatindex_trigger_value", params, firebaseService),
              _buildParamEditor(context, ref, "Temp Trigger",
                  "temp_trigger_value", params, firebaseService),
              _buildParamEditor(context, ref, "PPM Trigger Min",
                  "ppm_trigger_min_value", params, firebaseService),
              _buildParamEditor(context, ref, "PPM Trigger Max",
                  "ppm_trigger_max_value", params, firebaseService),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text("Restart ESP32"),
                onPressed: () async {
                  final confirmed = await _confirmAction(
                    context,
                    "Restart ESP32",
                    "This will restart your ESP32 device. Proceed?",
                  );
                  if (confirmed) {
                    await firebaseService.restartESP32(deviceId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ESP Restart command sent")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading parameters: $e")),
      ),
    );
  }

  Widget _buildParamEditor(BuildContext context, WidgetRef ref, String label,
      String key, Map<String, dynamic> params, DeviceFirebase firebaseService) {
    final controller =
        TextEditingController(text: params[key]?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  isDense: true, border: OutlineInputBorder()),
              onSubmitted: (val) async {
                final numValue = num.tryParse(val);
                if (numValue != null) {
                  await firebaseService.updateParameter(
                    deviceId: deviceId,
                    key: key,
                    value: numValue,
                  );
                  ref.invalidate(parameterStreamProvider(deviceId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label updated to $numValue')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
