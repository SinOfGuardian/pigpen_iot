import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pigpen_iot/apps/home/devices/add_devices_viewmodel.dart';

import 'package:pigpen_iot/custom/app_button.dart';

import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/ui_appbar%20copy.dart';
import 'package:pigpen_iot/provider/newdevice_provider.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

class AddDeviceScreen extends ConsumerWidget with InternetConnection {
  const AddDeviceScreen({super.key});

  // void addDeviceOnPressed(
  //   BuildContext context,
  //   WidgetRef ref, {
  //   required List<Device> devices,
  //   required List<UserDevice> userDevices,
  // }) {
  //   final check = ref.read(pageDataProvider.notifier);
  //   if (!check.isFieldsNotEmpty()) return;
  //   if (!check.isDeviceDeployed(devices: devices)) return;
  //   if (!check.isDeviceNotDuplicate(userDevices: userDevices)) return;

  //   showLoader(
  //     context,
  //     process: isConnected(true, context),
  //   ).then((isConnected) {
  //     if (isConnected == null || !isConnected) return;
  //     final newDevice = ref.read(newDeviceDataProvider);
  //     check.submitDeviceToDatabase(newDevice).then((_) {
  //       if (!context.mounted) return;
  //       showAddedDeviceDialog(
  //         context,
  //         graphicUrl: newDevice.graphicUrl,
  //         deviceId: newDevice.deviceId,
  //       ).then((_) => {if (context.mounted) context.pop()});
  //     });
  //   });
  // }

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
    // final pageData = ref.watch(pageDataProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: TitledAppBar2(
        title: 'Add Device',
        leadingAction: () => context.pop(),
        trailingIcon: EvaIcons.questionMark,
        trailingAction: () {},
      ),
      // body: pageData.when(
      //   data: (pageDataValue) {
      // void onPressed() => null(); //addDeviceOnPressed(context, ref,
      // devices: pageDataValue.devices,
      // userDevices: pageDataValue.userDevices);

      //         return SafeArea(
      //           child: SingleChildScrollView(
      //             child: Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 20),
      //               child: Column(
      //                 children: [
      //                   const SectionLabel('Preview',
      //                       margin: const EdgeInsets.only(bottom: 15)),
      //                   const _PreviewSection(),
      //                   const SectionLabel('Device Details',
      //                       margin: const EdgeInsets.only(top: 10, bottom: 15)),
      //                   _FormSection(plantGraphics: pageDataValue.plants),
      //                   _addDeviceButton(onPressed),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         );
      //       },
      //       loading: () => const AppCircularProgressIndicator(),
      //       error: (e, st) => AppErrorWidget(e as Exception, st, this),
      //     ),
    );
    // }
  }

// class _PreviewSection extends ConsumerWidget {
//   const _PreviewSection();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final newDevice = ref.watch(newDeviceDataProvider);
//     return PlantPreview(device: UserDevice.fromNewDevice(newDevice));
//   }
// }
}

class _FormSection extends ConsumerWidget {
  //const _FormSection({required this.plantGraphics});
  //final List<Plant> plantGraphics;

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
          readOnly: true,
          textInputAction: TextInputAction.none,
          keyboardType: TextInputType.none,
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
            labelText: 'Name of the plant',
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
        _titleLabel('Plant*', context),
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
              null, //chooseGraphicOnTap(context, ref, plantGraphics),
          onTapped: () =>
              null, //chooseGraphicOnTap(context, ref, plantGraphics),
          onSuffixIconTapped: () => null,
          //     chooseGraphicOnTap(context, ref, plantGraphics),
        ),
      ],
    );
  }
}
