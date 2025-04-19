// camera_stream_widget.dart
import 'dart:async';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:pigpen_iot/apps/home/userdevices/dashboard/mjpeg_recorder_service.dart';

final _cameraPlayingProvider = StateProvider<bool>((ref) => true);
final _cameraBlurredProvider = StateProvider<bool>((ref) => false);
final _latencyProvider = StateProvider<int>((ref) => 0);
final _isRecordingProvider = StateProvider<bool>((ref) => false);
final _recordingTimeProvider = StateProvider<Duration>((ref) => Duration.zero);
final _streamErrorProvider = StateProvider<bool>((ref) => false);
final _streamUrlProvider = FutureProvider<String>((ref) async {
  final snapshot = await FirebaseDatabase.instance
      .ref('/contents/devices/pigpeniot-38eba81f8a3c/streamUrl')
      .get();
  return snapshot.value as String;
});

class CameraStreamWidget extends ConsumerStatefulWidget {
  final double height;
  final BoxFit fit;

  const CameraStreamWidget(
      {super.key,
      this.height = 250.0,
      this.fit = BoxFit.cover,
      required String streamUrl});

  @override
  ConsumerState<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends ConsumerState<CameraStreamWidget> {
  bool _showControls = true;
  late Timer _latencyTimer;
  late Stopwatch _pingStopwatch;
  late Timer? _recordingTimer;
  late MJPEGRecorderService? recorder;
  int _failedAttempts = 0;
  final int _maxFailures = 3;

  @override
  void initState() {
    super.initState();
    _startRecordingTimer();
  }

  void _startLatencyCheck(String url) {
    _pingStopwatch = Stopwatch();
    _latencyTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        _pingStopwatch.reset();
        _pingStopwatch.start();
        await NetworkAssetBundle(Uri.parse(url)).load("");
        _pingStopwatch.stop();
        ref.read(_latencyProvider.notifier).state =
            _pingStopwatch.elapsedMilliseconds;
        ref.read(_streamErrorProvider.notifier).state = false;
        _failedAttempts = 0;
      } catch (_) {
        _failedAttempts++;
        if (_failedAttempts >= _maxFailures) {
          ref.read(_streamErrorProvider.notifier).state = true;
        }
      }
    });
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final isRecording = ref.read(_isRecordingProvider);
      if (isRecording) {
        ref.read(_recordingTimeProvider.notifier).state +=
            const Duration(seconds: 1);
        recorder?.recordSnapshot();
      }
    });
  }

  @override
  void dispose() {
    _latencyTimer.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(_cameraPlayingProvider);
    final isBlurred = ref.watch(_cameraBlurredProvider);
    final latency = ref.watch(_latencyProvider);
    final asyncStreamUrl = ref.watch(_streamUrlProvider);

    return asyncStreamUrl.when(
      data: (url) {
        recorder ??= MJPEGRecorderService(streamUrl: url);
        _startLatencyCheck(url);

        return Column(
          children: [
            GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: InteractiveViewer(
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 1,
                      maxScale: 4,
                      child: isPlaying && !ref.watch(_streamErrorProvider)
                          ? MJPEGStreamScreen(
                              streamUrl: url,
                              width: double.infinity,
                              height: widget.height,
                              fit: widget.fit,
                              showLiveIcon: true,
                            )
                          : Container(
                              height: widget.height,
                              color: Colors.black,
                              child: const Center(
                                  child: Icon(Icons.wifi_off,
                                      color: Colors.white)),
                            ),
                    ),
                  ),
                  if (isBlurred)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(color: Colors.black.withOpacity(0.1)),
                      ),
                    ),
                  if (_showControls)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      left: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow),
                            color: Colors.white,
                            onPressed: () {
                              ref.read(_cameraPlayingProvider.notifier).state =
                                  !isPlaying;
                            },
                          ),
                          IconButton(
                            icon: Icon(ref.watch(_isRecordingProvider)
                                ? Icons.stop
                                : Icons.fiber_manual_record),
                            color: ref.watch(_isRecordingProvider)
                                ? Colors.red
                                : Colors.white,
                            onPressed: () async {
                              final isRecording =
                                  ref.read(_isRecordingProvider);
                              ref.read(_isRecordingProvider.notifier).state =
                                  !isRecording;
                              if (isRecording) {
                                await recorder?.stopRecording();
                              } else {
                                await recorder?.startRecording();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                                isBlurred ? Icons.blur_off : Icons.blur_on),
                            color: Colors.white,
                            onPressed: () {
                              ref.read(_cameraBlurredProvider.notifier).state =
                                  !isBlurred;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera),
                            color: Colors.white,
                            onPressed: () async {
                              final url = await recorder?.takeSnapshot();
                              if (url != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Snapshot saved to Firebase')));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.fullscreen),
                            color: Colors.white,
                            onPressed: () => _openFullscreen(context, url),
                          ),
                        ],
                      ),
                    ),
                  if (ref.watch(_isRecordingProvider))
                    Positioned(
                      top: 10,
                      right: 20,
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.red, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            _formatDuration(ref.watch(_recordingTimeProvider)),
                            style: const TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        latency == -1 ? "No Signal" : "$latency ms",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  void _openFullscreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: MJPEGStreamScreen(
                streamUrl: url,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                showLiveIcon: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
