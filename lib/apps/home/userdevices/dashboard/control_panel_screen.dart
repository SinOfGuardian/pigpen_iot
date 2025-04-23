import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/provider/device_parameters_provider.dart';
import 'package:pigpen_iot/provider/device_setting_provider.dart';

class ControlPanelScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const ControlPanelScreen({super.key, required this.deviceId});

  @override
  ConsumerState<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends ConsumerState<ControlPanelScreen> {
  bool isEditMode = false;

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
  Widget build(BuildContext context) {
    final deviceId = widget.deviceId;
    final firebaseService = DeviceFirebase();
    final drinkerDuration = ref.watch(localDrinkerDurationProvider);
    final sprinklerDuration = ref.watch(localSprinklerDurationProvider);
    final drinkerNotifier = ref.read(localDrinkerDurationProvider.notifier);
    final sprinklerNotifier = ref.read(localSprinklerDurationProvider.notifier);
    final parametersAsync = ref.watch(parameterStreamProvider(deviceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Device Control Panel')),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(parameterStreamProvider(deviceId)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 🔧 Hardware Mode Switch
            StreamBuilder<String>(
              stream: firebaseService.getModeStream(deviceId),
              builder: (context, snapshot) {
                final mode = snapshot.data ?? 'production';
                final isDemo = mode == 'demo';

                return ListTile(
                  title: const Text("Hardware Mode"),
                  subtitle: Text(isDemo ? "Demo Mode" : "Production Mode"),
                  trailing: Switch(
                    value: isDemo,
                    onChanged: (value) async {
                      final newMode = value ? 'demo' : 'production';
                      final confirmed = await _confirmAction(
                        context,
                        "Switch Mode",
                        "Are you sure you want to switch to $newMode mode?",
                      );
                      if (confirmed) {
                        await firebaseService.setMode(deviceId, newMode);
                        setState(() {}); // Refresh UI
                      }
                    },
                  ),
                );
              },
            ),

            const Divider(),

            // 🔧 Manual durations
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
            const Divider(),
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

            const Divider(height: 40),

            // ⚙️ Trigger Parameters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Trigger Parameters",
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  icon: Icon(isEditMode ? Icons.lock_open : Icons.lock_outline),
                  label: Text(isEditMode ? "Editing" : "Edit"),
                  onPressed: () {
                    setState(() => isEditMode = !isEditMode);
                  },
                ),
              ],
            ),

            parametersAsync.when(
              data: (params) => Column(
                children: [
                  _buildParamEditor("Heat Index", "heatindex_trigger_value",
                      params, isEditMode, 20, 100),
                  _buildParamEditor("Temperature", "temp_trigger_value", params,
                      isEditMode, 10, 50),
                  _buildParamEditor("PPM Min", "ppm_trigger_min_value", params,
                      isEditMode, 0, 50),
                  _buildParamEditor("PPM Max", "ppm_trigger_max_value", params,
                      isEditMode, 10, 100),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text("Error loading parameters: $e"),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Reset to Default"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final confirmed = await _confirmAction(
                  context,
                  "Reset Parameters",
                  "Are you sure you want to reset all parameters to default values?",
                );
                if (confirmed) {
                  await DeviceFirebase()
                      .resetParametersToDefault(widget.deviceId);
                  ref.invalidate(parameterStreamProvider(widget.deviceId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Parameters reset to default")),
                  );
                }
              },
            ),

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
    );
  }

  Widget _buildParamEditor(
    String label,
    String key,
    Map<String, dynamic> params,
    bool editable,
    num min,
    num max,
  ) {
    final controller =
        TextEditingController(text: params[key]?.toString() ?? '');
    final currentValue = params[key]?.toString() ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text("$label ($currentValue)")),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              enabled: editable,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) async {
                final parsed = num.tryParse(val);
                if (parsed == null || parsed < min || parsed > max) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Invalid input. $label must be between $min and $max.")),
                  );
                  return;
                }

                final confirmed = await _confirmAction(
                  context,
                  "Confirm Change",
                  "Are you sure you want to set $label to $parsed?",
                );
                if (!confirmed) return;

                await DeviceFirebase().updateParameter(
                  deviceId: widget.deviceId,
                  key: key,
                  value: parsed,
                );
                ref.invalidate(parameterStreamProvider(widget.deviceId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label updated to $parsed')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
