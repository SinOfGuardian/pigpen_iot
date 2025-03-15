import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_error_handling.dart';
import 'package:pigpen_iot/custom/app_icon.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/ui_animal_preview.dart';
import 'package:pigpen_iot/models/userdevice_model.dart';
import 'package:pigpen_iot/provider/userdevices_provider.dart';

// Provider for search query
final _searchQuery = StateProvider.autoDispose<String?>((ref) => null);
final _searchController = Provider.autoDispose<TextEditingController>(
    (ref) => TextEditingController());
final _availableDevices = Provider.autoDispose
    .family<List<UserDevice>, List<UserDevice>>((ref, availableDevices) {
  final query = ref.watch(_searchQuery);
  if (query == null || query.isEmpty) return availableDevices;
  return availableDevices.where((device) {
    if (device.deviceId.toLowerCase().contains(query.toLowerCase()) ||
        device.deviceName.toLowerCase().contains(query.toLowerCase()))
      return true;
    else
      return false;
  }).toList();
});

class DeviceList extends ConsumerWidget {
  const DeviceList({super.key});

  void addDeviceTapped(BuildContext context) {
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
          onTap: () => addDeviceTapped(context),
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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: AppTextField(
        controller: ref.watch(_searchController),
        errorText: null,
        labelText: 'Search Device',
        textInputAction: TextInputAction.search,
        prefixIconData: Icons.search_rounded,
        suffixIconData: Icons.close_outlined,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        onChanged: (newId) {
          ref.read(_searchQuery.notifier).state = newId;
        },
        onSuffixIconTapped: () {
          ref.read(_searchQuery.notifier).state = null;
          ref.read(_searchController).clear();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamUserDevices = ref.watch(userDevicesProvider);
    return AppContainer(
      margin: null,
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          const SectionTitle('Devices'),
          _addDeviceButton(context),
          _searchBar(ref), // Add the search bar

          streamUserDevices.when(
            data: (userDevices) {
              final availableDevices =
                  ref.watch(_availableDevices(userDevices));
              int animationDelay = 0;
              // Check if there are no devices
              if (availableDevices.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'There are no devices.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 20),
                  for (final userDevice in availableDevices) ...[
                    Entry.all(
                      delay: Duration(milliseconds: animationDelay += 150),
                      child: AnimalPreview(
                        device: userDevice,
                        onTap: () =>
                            null, //plantOnTapped(ref, context, userDevice),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => Container(
              padding: const EdgeInsets.only(top: 20),
              constraints: const BoxConstraints(maxHeight: 160),
              alignment: Alignment.topCenter,
              child: AnimalPreview(device: UserDevice.empty()),
            ),
            error: (e, st) => AppErrorWidget(e as Exception, st, this),
          ),
        ],
      ),
    );
  }
}
