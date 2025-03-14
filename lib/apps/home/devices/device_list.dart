import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_icon.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';

// Provider for search query
final _searchQueryProvider = StateProvider.autoDispose<String?>((ref) => null);

class DeviceList extends ConsumerWidget {
  const DeviceList({super.key});

  void addThingsTapped(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.push('/home/add-device');
  }

  Widget _addDeviceButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonTextStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary);

    return Container(
      height: 50,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        border: Border.all(color: colorScheme.surfaceContainer, width: 2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => addThingsTapped(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(Icons.add, size: 20, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text('Add a device', style: buttonTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: AppTextField(
        controller:
            TextEditingController(), // You can use a provider for this if needed
        errorText: null,
        labelText: 'Search Device',
        textInputAction: TextInputAction.search,
        prefixIconData: Icons.search_rounded,
        suffixIconData: Icons.close_outlined,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        onChanged: (newQuery) {
          ref.read(_searchQueryProvider.notifier).state = newQuery;
        },
        onSuffixIconTapped: () {
          ref.read(_searchQueryProvider.notifier).state = null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(_searchQueryProvider);

    // Example list of devices (replace with your actual data source)
    final List<UserDevice> devices = [
      UserDevice(deviceId: '1', deviceName: 'Device A'),
      UserDevice(deviceId: '2', deviceName: 'Device B'),
      UserDevice(deviceId: '3', deviceName: 'Device C'),
    ];

    // Filter devices based on search query
    final filteredDevices = searchQuery == null || searchQuery.isEmpty
        ? devices
        : devices.where((device) {
            return device.deviceName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                device.deviceId
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
          }).toList();

    return AppContainer(
      margin: null,
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          const SectionTitle('Devices'),
          _addDeviceButton(context),
          _searchBar(ref), // Add the search bar
          const SizedBox(height: 20),
          if (filteredDevices.isEmpty)
            const Center(
              child: Text('No devices found.'),
            )
          else
            Column(
              children: [
                for (final device in filteredDevices)
                  ListTile(
                    title: Text(device.deviceName),
                    subtitle: Text(device.deviceId),
                    onTap: () {
                      // Handle device tap (e.g., navigate to device details)
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// Example UserDevice model (replace with your actual model)
class UserDevice {
  final String deviceId;
  final String deviceName;

  UserDevice({required this.deviceId, required this.deviceName});
}
