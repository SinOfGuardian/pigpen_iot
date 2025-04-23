import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/provider/device_setting_provider.dart';

Future<void> showControlPanelModal(BuildContext context, String deviceId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ControlPanelModal(deviceId: deviceId),
  );
}

class ControlPanelModal extends ConsumerWidget {
  final String deviceId;
  const ControlPanelModal({super.key, required this.deviceId});

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
    final drinkerDuration = ref.watch(localDrinkerDurationProvider);
    final sprinklerDuration = ref.watch(localSprinklerDurationProvider);
    final drinkerNotifier = ref.read(localDrinkerDurationProvider.notifier);
    final sprinklerNotifier = ref.read(localSprinklerDurationProvider.notifier);

    final firebaseService = DeviceFirebase();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              StreamBuilder<String>(
                stream: firebaseService.getModeStream(deviceId),
                builder: (context, snapshot) {
                  final currentMode = snapshot.data ?? 'production';
                  final isDemo = currentMode == 'demo';

                  return ListTile(
                    title: const Text('Hardware Mode'),
                    subtitle: Text(isDemo
                        ? 'Demo Mode is active'
                        : 'Production Mode is active'),
                    trailing: Switch(
                      value: isDemo,
                      onChanged: (val) async {
                        final newMode = val ? 'demo' : 'production';
                        final confirmed = await _confirmAction(
                          context,
                          "Change Mode",
                          "Are you sure you want to switch to $newMode mode?",
                        );
                        if (confirmed) {
                          await firebaseService.setMode(deviceId, newMode);
                        }
                      },
                    ),
                  );
                },
              ),
              const Divider(height: 30),
              ListTile(
                title: const Text('ESP32 Command'),
                subtitle: const Text('Tap to restart ESP32 device'),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Restart"),
                  onPressed: () async {
                    final confirmed = await _confirmAction(
                      context,
                      "Restart ESP32",
                      "This will restart your ESP32 device. Proceed?",
                    );
                    if (confirmed) {
                      await firebaseService.restartESP32(deviceId);
                      Navigator.pop(context); // Dismiss modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("ESP Restart command sent")),
                      );
                    }
                  },
                ),
              ),
              const Divider(height: 30),
              Text("Sprinkler Duration (manual)",
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                min: 1,
                max: 60,
                divisions: 29,
                label: "$sprinklerDuration sec",
                value: sprinklerDuration.toDouble(),
                onChanged: (val) => sprinklerNotifier.set(val.round()),
              ),
              const Divider(height: 30),
              Text("Drinker Duration (manual)",
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                min: 1,
                max: 60,
                divisions: 29,
                label: "$drinkerDuration sec",
                value: drinkerDuration.toDouble(),
                onChanged: (val) => drinkerNotifier.set(val.round()),
              ),
            ],
          ),
        );
      },
    );
  }
}
