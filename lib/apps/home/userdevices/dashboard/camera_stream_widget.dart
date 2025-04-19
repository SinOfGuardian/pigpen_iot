import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

class CameraStreamWidget extends StatelessWidget {
  final String streamUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CameraStreamWidget({
    super.key,
    required this.streamUrl,
    this.width = 300.0,
    this.height = 200.0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return MJPEGStreamScreen(
      streamUrl: streamUrl,
      width: width,
      height: height,
      fit: fit,
      showLiveIcon: true,
    );
  }
}
