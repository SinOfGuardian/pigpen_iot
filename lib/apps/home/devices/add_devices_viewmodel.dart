import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/provider/newdevice_provider.dart';

import 'package:pigpen_iot/services/internet_connection.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_devices_viewmodel.g.dart';

@riverpod
class PageData extends _$PageData with InternetConnection {
  // FutureOr<
  //   ({
  //     List<Plant> plants,
  //     List<Device> devices,
  //     List<UserDevice> userDevices,
  //   })> build() async {
  // const timeLimit = Duration(seconds: 5);
  // final plants = await ref.watch(plantsProvider.future).timeout(timeLimit);
  // final devices = await ref.watch(devicesProvider.future).timeout(timeLimit);
  // final userDevices =
  //     await ref.watch(userDevicesProvider.future).timeout(timeLimit);
  // return (plants: plants, devices: devices, userDevices: userDevices);
  //}

  bool isFieldsNotEmpty() {
    final newDevice = ref.read(newDeviceDataProvider);
    bool isNotEmpty = true;
    if (newDevice.deviceId.isEmpty) {
      isNotEmpty = false;
      ref.read(deviceIdErrorProvider.notifier).emptyField();
    }
    if (newDevice.deviceName.isEmpty) {
      isNotEmpty = false;
      ref.read(nameErrorProvider.notifier).emptyField();
    }
    if (newDevice.graphicName.isEmpty) {
      isNotEmpty = false;
      ref.read(graphicNameErrorProvider.notifier).emptyField();
    }
    return isNotEmpty;
  }

  // bool isDeviceDeployed({required List<Device> devices}) {
  //   final deviceId = ref
  //       .read(newDeviceDataProvider.select((newDevice) => newDevice.deviceId));
  //   for (final device in devices) {
  //     if (device.id == deviceId) return true;
  //   }
  //   ref.read(deviceIdErrorProvider.notifier).invalidId();
  //   return false;
  // }

  bool isDeviceNotDuplicate({required List<UserDevice> userDevices}) {
    if (userDevices.isEmpty) return true;
    final deviceId = ref
        .read(newDeviceDataProvider.select((newDevice) => newDevice.deviceId));
    for (final userDevice in userDevices) {
      if (userDevice.deviceId == deviceId) {
        ref.read(deviceIdErrorProvider.notifier).alreadyHave();
        return false;
      }
    }
    return true;
  }

  @override
  FutureOr<
      ({
        List<dynamic> devices,
        List<dynamic> plants,
        List<UserDevice> userDevices
      })> build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  // Future<void> submitDeviceToDatabase(NewDevice newDevice) async {
  //   final userDevice = UserDevice.fromNewDevice(newDevice);
  //   await ref
  //       .read(userDevicesProvider.notifier)
  //       .addDeviceToCurrentUser(userDevice);
  //   await ref.read(activeUserProvider.notifier).incrementDevice();
  //   await Future.delayed(const Duration(seconds: 1));
  // }
}

@riverpod
class DeviceIdError extends _$DeviceIdError {
  @override
  String? build() => null;
  void clearError() => state = null;
  void emptyField() => state = 'Device ID is required';
  void invalidId() => state = 'Invalid Device ID';
  void alreadyHave() => state = 'Device is already added';
}

@riverpod
class NameError extends _$NameError {
  @override
  String? build() => null;
  void clearError() => state = null;
  void emptyField() => state = 'Empty Name is not allowed';
}

@riverpod
class GraphicNameError extends _$GraphicNameError {
  @override
  String? build() => null;
  void clearError() => state = null;
  void emptyField() => state = 'Please choose a graphic';
}

@riverpod
class DeviceIdController extends _$DeviceIdController {
  @override
  Raw<TextEditingController> build() => TextEditingController();
  void clear() => state.clear();
}

@riverpod
class NameController extends _$NameController {
  @override
  Raw<TextEditingController> build() => TextEditingController();
  void setText(String text) => state.text = text;
  void clear() => state.clear();
}

@riverpod
class GraphicNameController extends _$GraphicNameController {
  @override
  Raw<TextEditingController> build() => TextEditingController();
  void setText(String text) => state.text = text;
  void clear() => state.clear();
}
