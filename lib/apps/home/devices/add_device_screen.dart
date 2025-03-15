import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pigpen_iot/apps/home/devices/add_devices_viewmodel.dart';
import 'package:pigpen_iot/custom/app_animal_picker_dialog.dart';

import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_circularprogressindicator.dart';
import 'package:pigpen_iot/custom/app_error_handling.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/app_text.dart';

import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/ui_added_device.dart';
import 'package:pigpen_iot/custom/ui_animal_preview.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';
import 'package:pigpen_iot/models/animal_model.dart';
import 'package:pigpen_iot/models/device_model.dart';
import 'package:pigpen_iot/models/userdevice_model.dart';
import 'package:pigpen_iot/provider/newdevice_provider.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class AddDeviceScreen extends ConsumerWidget with InternetConnection {
  const AddDeviceScreen({super.key});

  void addDeviceOnPressed(
    BuildContext context,
    WidgetRef ref, {
    required List<Device> devices,
    required List<UserDevice> userDevices,
  }) async {
    try {
      final check = ref.read(pageDataProvider.notifier);
      if (!check.isFieldsNotEmpty()) return;
      if (!check.isDeviceDeployed(devices: devices)) return;
      if (!check.isDeviceNotDuplicate(userDevices: userDevices)) return;

      final connectionStatus = await showLoader(
        context,
        process: isConnected(true, context),
      );

      if (connectionStatus == null || !connectionStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No internet connection')),
        );
        return;
      }

      final newDevice = ref.read(newDeviceDataProvider);
      await check.submitDeviceToDatabase(newDevice);

      if (!context.mounted) return;
      await showAddedDeviceDialog(
        context,
        graphicUrl: newDevice.graphicUrl,
        deviceId: newDevice.deviceId,
      );

      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add device: $e')),
        );
      }
    }
  }

  Widget _addDeviceButton(void Function()? onPressed) {
    return AppFilledButton.big(
      text: 'Add',
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      icon: EvaIcons.plus,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageData = ref.watch(pageDataProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: TitledAppBar2(
        title: 'Add Device',
        leadingAction: () => context.pop(),
        trailingIcon: EvaIcons.questionMark,
        trailingAction: () {},
      ),
      body: pageData.when(
        data: (pageDataValue) {
          void onPressed() => //();
              addDeviceOnPressed(context, ref,
                  devices: pageDataValue.devices,
                  userDevices: pageDataValue.userDevices);

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SectionLabel('Preview',
                        margin: const EdgeInsets.only(bottom: 15)),
                    const _PreviewSection(),
                    const SectionLabel('Device Details',
                        margin: const EdgeInsets.only(top: 10, bottom: 15)),
                    _FormSection(animalGraphics: pageDataValue.animals),
                    _addDeviceButton(onPressed),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const AppCircularProgressIndicator(),
        error: (e, st) {
          debugPrint('Error loading page data: $e');
          return AppErrorWidget(
              e is Exception ? e : Exception(e.toString()), st, this);
        },
      ),
    );
  }
}

class _PreviewSection extends ConsumerWidget {
  const _PreviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newDevice = ref.watch(newDeviceDataProvider);
    return AnimalPreview(device: UserDevice.fromNewDevice(newDevice));
  }
}

class _FormSection extends ConsumerWidget {
  const _FormSection({required this.animalGraphics});
  final List<Animal> animalGraphics;

  // Future<void> _scanQRCode(WidgetRef ref) async {
  //   try {
  //     final qrCode = await FlutterBarcodeScanner.scanBarcode(
  //       '#ff6666', // Scanner overlay color
  //       'Cancel', // Cancel button text
  //       true, // Show flashlight toggle
  //       ScanMode.QR, // Scan mode
  //     );
  //     if (qrCode != '-1') {
  //       // Set the scanned QR code as the Device ID
  //       ref.read(deviceIdControllerProvider).text = qrCode;
  //       ref.read(newDeviceDataProvider.notifier).setDeviceId(qrCode);
  //     }
  //   } catch (e) {
  //     // Handle exceptions during scanning
  //     debugPrint('Error scanning QR code: $e');
  //   }
  // }
  Future<void> chooseGraphicOnTap(
      BuildContext context, WidgetRef ref, List<Animal> animalGraphics) {
    return showAnimalChooser(context, availableGraphics: animalGraphics)
        .then<void>(
      (Animal? newAnimal) {
        if (newAnimal == null) return;
        final prevDevice = ref.read(newDeviceDataProvider);
        final prevName = prevDevice.deviceName;
        final prevGraphicName = prevDevice.graphicName;

        if (prevName.isEmpty || prevName == prevGraphicName) {
          ref.read(nameErrorProvider.notifier).clearError();
          ref.read(nameControllerProvider.notifier).setText(newAnimal.name);
          ref.read(newDeviceDataProvider.notifier).setName(newAnimal.name);
        }
        ref.read(graphicNameErrorProvider.notifier).clearError();
        ref
            .read(graphicNameControllerProvider.notifier)
            .setText(newAnimal.name);
        ref.read(newDeviceDataProvider.notifier).setSelectedAnimal(newAnimal);
      },
    );
  }

  Widget _titleLabel(String title, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleSmall = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: colorScheme.primary);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: titleSmall),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _titleLabel('Device ID*', context),
        AppTextField(
          controller: ref.watch(deviceIdControllerProvider),
          errorText: ref.watch(deviceIdErrorProvider),
          labelText: 'Scan QR Code to get device ID',
          //readOnly: true,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          suffixIconData: Ionicons.barcode_outline,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          onChanged: (newId) {
            ref.read(deviceIdErrorProvider.notifier).clearError();
            ref.read(newDeviceDataProvider.notifier).setDeviceId(newId);
          },
          onSuffixIconTapped: () => null, //_scanQRCode(ref),
        ),
        _titleLabel('Name*', context),
        AppTextField(
            controller: ref.watch(nameControllerProvider),
            errorText: ref.watch(nameErrorProvider),
            labelText: 'Name of the animal',
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            suffixIconData: Ionicons.close_outline,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            onChanged: (newName) {
              ref.read(nameErrorProvider.notifier).clearError();
              ref.read(newDeviceDataProvider.notifier).setName(newName);
            },
            onSuffixIconTapped: () {
              ref.read(nameControllerProvider.notifier).clear();
              ref.read(newDeviceDataProvider.notifier).setName('');
            }),
        _titleLabel('Animal*', context),
        AppTextField(
          controller: ref.watch(graphicNameControllerProvider),
          errorText: ref.watch(graphicNameErrorProvider),
          labelText: 'Choose Graphic',
          textInputAction: TextInputAction.none,
          keyboardType: TextInputType.none,
          readOnly: true,
          suffixIconData: Ionicons.chevron_down_outline,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          onChanged: (_) =>
              ref.read(graphicNameErrorProvider.notifier).clearError(),
          onTapped: () => chooseGraphicOnTap(context, ref, animalGraphics),
          onSuffixIconTapped: () =>
              chooseGraphicOnTap(context, ref, animalGraphics),
        ),
      ],
    );
  }
}
