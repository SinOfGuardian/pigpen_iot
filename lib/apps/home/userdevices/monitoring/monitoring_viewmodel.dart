import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/apps/home/userdevices/monitoring/monitoring_model.dart';
import 'package:pigpen_iot/models/generics.dart';
import 'package:pigpen_iot/modules/database.dart';

final deviceStreamProvider = StreamProvider.autoDispose<DeviceData>((ref) {
  final deviceId =
      ref.watch(activeDeviceProvider.select((thing) => thing!.deviceId));
  final database = DeviceFirebase();
  return database.deviceStream(deviceId);
});

final graphDataProvider = StateNotifierProvider.family
    .autoDispose<GraphNotifier, GraphData, Sensor>((ref, sensor) {
  return GraphNotifier(sensor: sensor);
});

class GraphNotifier extends StateNotifier<GraphData> {
  final Sensor sensor;
  GraphNotifier({required this.sensor})
      : super(GraphData(
          data: sensor == gasSensor ? 0.0 : 0,
          sensor: sensor,
          minY: sensor.min,
          maxY: sensor.max,
          arrayOfData: const [],
          lowest: sensor == gasSensor ? 0.0 : 0, // Handle both types
          highest: sensor == gasSensor ? 0.0 : 0, // Handle both types
        ));

  final _stackOfData = GenericStack<num>();

  void update(num newValue) {
    final oldData = state.arrayOfData.toList();
    final newData = _getArrayOfData(newValue);
    if (listEquals(oldData, newData) && oldData.length == 21) return;

    state = state.copyWith(
      data: newValue,
      arrayOfData: newData,
      highest: _getHighest(),
      lowest: _getLowest(),
      minY: _getMinY(newValue),
      maxY: _getMaxY(newValue),
    );
  }

  double _getMinY(num data) {
    final lowest = _stackOfData.peekLowest?.toDouble();
    if (lowest == null) return sensor.min;

    final newData = data.toDouble();
    if (lowest <= sensor.min) {
      return ((lowest - 10) / 10).round() * 10;
    } else if (newData >= sensor.max) {
      return ((lowest - 50) / 10).round() * 10;
    }
    if (newData > sensor.min && newData < sensor.max) {
      return sensor.min;
    }
    return -1;
  }

  double _getMaxY(num data) {
    final highest = _stackOfData.peekHighest?.toDouble();
    if (highest == null) return sensor.max;

    final newData = data.toDouble();
    if (highest >= sensor.max) {
      return ((highest + 10) / 10).round() * 10;
    } else if (newData <= sensor.min) {
      return ((highest + 50) / 10).round() * 10;
    }
    if (newData < sensor.max && newData > sensor.min) {
      return sensor.max;
    }
    return 1;
  }

  num _getHighest() {
    final highest = _stackOfData.peekHighest;
    if (highest == null) return 0;
    return highest;
  }

  num _getLowest() {
    final lowest = _stackOfData.peekLowest;
    if (lowest == null) return 0;
    return lowest;
  }

  List<num> _getArrayOfData(num data) {
    if (_stackOfData.length == 21) _stackOfData.pop();
    _stackOfData.push(data);
    return _stackOfData.getList;
  }
}

// In your viewmodel, consider adding this to prevent unnecessary rebuilds
@override
bool updateShouldNotify(GraphData old, GraphData newData) {
  return !listEquals(old.arrayOfData, newData.arrayOfData) ||
      old.data != newData.data ||
      old.highest != newData.highest ||
      old.lowest != newData.lowest;
}
