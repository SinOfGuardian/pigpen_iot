import 'dart:async';
import 'dart:ui';
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

class CameraStreamWidget extends ConsumerStatefulWidget {
  final String streamUrl;
  final double height;
  final BoxFit fit;

  const CameraStreamWidget({
    super.key,
    required this.streamUrl,
    this.height = 250.0,
    this.fit = BoxFit.cover,
  });

  @override
  ConsumerState<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends ConsumerState<CameraStreamWidget> {
  bool _showControls = true;
  late Timer _latencyTimer;
  late Stopwatch _pingStopwatch;

  late Timer? _recordingTimer;
  int _failedAttempts = 0;
  final int _maxFailures = 3;

  late MJPEGRecorderService recorder;

  @override
  void initState() {
    super.initState();
    _startLatencyCheck();
    _startRecordingTimer();

    // Setup latency timer (ping every 5s)
    _pingStopwatch = Stopwatch();
    _latencyTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        _pingStopwatch.reset();
        _pingStopwatch.start();
        await NetworkAssetBundle(Uri.parse(widget.streamUrl)).load("");
        _pingStopwatch.stop();
        ref.read(_latencyProvider.notifier).state =
            _pingStopwatch.elapsedMilliseconds;
      } catch (_) {
        ref.read(_latencyProvider.notifier).state = -1;
      }
    });
  }

  void _startLatencyCheck() {
    _pingStopwatch = Stopwatch();
    _latencyTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        _pingStopwatch.reset();
        _pingStopwatch.start();
        await NetworkAssetBundle(Uri.parse(widget.streamUrl)).load("");
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
      } else {
        ref.read(_recordingTimeProvider.notifier).state = Duration.zero;
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

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              if (ref.watch(_isRecordingProvider))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatDuration(ref.watch(_recordingTimeProvider)),
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),

              // 🔍 Zoom & Pan
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 1,
                  maxScale: 4,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isPlaying && !ref.watch(_streamErrorProvider)
                        ? MJPEGStreamScreen(
                            streamUrl: widget.streamUrl,
                            width: double.infinity,
                            height: widget.height,
                            fit: widget.fit,
                            showLiveIcon: true,
                          )
                        : Container(
                            height: widget.height,
                            width: double.infinity,
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi_off,
                                    color: Colors.white, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  ref.watch(_streamErrorProvider)
                                      ? 'Connection Lost. Reconnecting...'
                                      : 'Camera Paused',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),

              // 🌫️ Blur Effect
              if (isBlurred)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                ),

              // 🕹️ Custom Overlay Controls
              if (_showControls)
                Positioned(
                  bottom: 10,
                  right: 10,
                  left: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
                        onPressed: () {
                          final recording = ref.read(_isRecordingProvider);
                          ref.read(_isRecordingProvider.notifier).state =
                              !recording;
                          if (!recording) {
                            // Start
                            ref.read(_recordingTimeProvider.notifier).state =
                                Duration.zero;
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(isBlurred ? Icons.blur_off : Icons.blur_on),
                        color: Colors.white,
                        onPressed: () {
                          ref.read(_cameraBlurredProvider.notifier).state =
                              !isBlurred;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        color: Colors.white,
                        onPressed: () => _openFullscreen(context),
                      ),
                    ],
                  ),
                ),

              // ⏱️ Latency Display
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    latency == -1 ? "No Signal" : "${latency}ms",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: MJPEGStreamScreen(
                streamUrl: widget.streamUrl,
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
