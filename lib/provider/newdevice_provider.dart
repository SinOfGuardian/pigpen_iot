import 'package:pigpen_iot/models/animal_model.dart';
import 'package:pigpen_iot/models/newdevice_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'newdevice_provider.g.dart';

@riverpod
class NewDeviceData extends _$NewDeviceData {
  @override
  NewDevice build() => NewDevice.empty();

  void clearDeviceId() => state = state.copyWith(deviceId: '');
  void setDeviceId(String deviceId) =>
      state = state.copyWith(deviceId: deviceId);
  void setName(String deviceName) =>
      state = state.copyWith(deviceName: deviceName);
  void setDeviceCount(int newCount) =>
      state = state.copyWith(deviceCount: newCount);
  void setSelectedAnimal(Animal newAnimal) => state = state.copyWith(
      graphicName: newAnimal.name, graphicUrl: newAnimal.graphicUrl);
}
