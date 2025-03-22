import 'package:flutter/material.dart';
import 'package:pigpen_iot/modules/mycolors.dart';

@immutable
class DeviceData {
  final int temperature;
  final int humidity;
  final int gasDetection;
  final int waterLevel;

  const DeviceData({
    required this.temperature,
    required this.humidity,
    required this.gasDetection,
    required this.waterLevel,
  });

  factory DeviceData.fromJson(Map<Object?, Object?>? json) {
    if (json == null) {
      return const DeviceData(
          temperature: 30, humidity: 30, gasDetection: 30, waterLevel: 30);
    }
    return DeviceData(
      temperature: json['temperature'] as int? ?? 0,
      humidity: json['humidity'] as int? ?? 0,
      gasDetection: json['gas_detection'] as int? ?? 0,
      waterLevel: json['water_level'] as int? ?? 0,
    );
  }
}

@immutable
class Sensor {
  final String title, suffix;
  final double min, max;
  final Color lineColor;
  final String noteMessage;

  const Sensor({
    required this.title,
    required this.suffix,
    required this.lineColor,
    required this.min,
    required this.max,
    required this.noteMessage,
  });
}

const tempSensor = Sensor(
  title: 'temperature',
  suffix: '°C',
  min: 20,
  max: 60,
  lineColor: Colors.orange,
  noteMessage: 'The degree or intensity of heat measured outside of the device '
      'presented in celsius. This is significant for most of indoor plants, '
      'a minimal room temperature is recommended.',
);

const humidSensor = Sensor(
  title: 'humidity',
  suffix: '%',
  min: 0,
  max: 100,
  lineColor: Colors.blue,
  noteMessage: 'A quantity representing the amount of water vapor in the '
      'atmosphere or in a gas measured outside of the device. The measured '
      'humidity plays an important role for the device to calculate when '
      'it would water.',
);

const gasSensor = Sensor(
    title: 'Ammonia',
    suffix: ' ppm',
    min: 0,
    max: 60,
    lineColor: Colors.brown,
    noteMessage:
        'Device which detects the presence or concentration of gases in the atmosphere.'
    // 'soil particles, known as pore spaces. The higher the soil moisture, ',
    );

const waterSensor = Sensor(
  title: 'water level',
  suffix: '%',
  min: 0,
  max: 100,
  lineColor: Colors.purple,
  noteMessage: 'It works by sensing changes in conductivity or resistance '
      'when it comes into contact with water. ',
);

const nextWatering = Sensor(
  title: 'Next Bath Time',
  suffix: '',
  min: 0,
  max: 1,
  lineColor: PRIMARY_ACCENT_COLOR,
  noteMessage: 'next scheduled watering',
);

@immutable
class GraphData {
  final Sensor sensor;
  final int data, highest, lowest;
  final double minY, maxY;
  final List<int> arrayOfData;

  const GraphData({
    required this.sensor,
    required this.data,
    required this.highest,
    required this.lowest,
    required this.minY,
    required this.maxY,
    required this.arrayOfData,
  });

  GraphData copyWith({
    Sensor? sensor,
    int? data,
    int? highest,
    int? lowest,
    double? minY,
    double? maxY,
    List<int>? arrayOfData,
  }) {
    return GraphData(
      arrayOfData: arrayOfData ?? this.arrayOfData,
      sensor: sensor ?? this.sensor,
      data: data ?? this.data,
      highest: highest ?? this.highest,
      lowest: lowest ?? this.lowest,
      maxY: maxY ?? this.maxY,
      minY: minY ?? this.minY,
    );
  }
}
