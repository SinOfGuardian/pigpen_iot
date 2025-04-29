import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:pigpen_iot/apps/home/userdevices/dashboard/camera_storage_screen.dart';
import 'package:pigpen_iot/apps/home/userdevices/dashboard/snapshot_service.dart';
import 'package:pigpen_iot/provider/device_parameters_provider.dart';

final _cameraPlayingProvider = StateProvider<bool>((ref) => true);
final _cameraBlurredProvider = StateProvider<bool>((ref) => false);
final _latencyProvider = StateProvider<int>((ref) => 0);
final _streamErrorProvider = StateProvider<bool>((ref) => false);

class CameraStreamWidget extends ConsumerStatefulWidget {
  final String deviceId; // Pass only deviceId now

  const CameraStreamWidget({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends ConsumerState<CameraStreamWidget> {
  bool _showControls = true;
  bool _isUploading = false;
  bool _showFlash = false;
  Timer? _latencyTimer;
  late Stopwatch _pingStopwatch;
  int _failedAttempts = 0;
  final int _maxFailures = 3;

  String? _streamUrl;
  String? _snapshotUrl;

  @override
  void dispose() {
    _latencyTimer?.cancel();
    super.dispose();
  }

  void _startLatencyCheck(String url) {
    _latencyTimer?.cancel();
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

  Future<void> _refreshStream() async {
    if (_streamUrl != null) {
      _startLatencyCheck(_streamUrl!);
    }
    ref.read(_streamErrorProvider.notifier).state = false;
    ref.read(_cameraPlayingProvider.notifier).state = true;
    ref.read(_cameraBlurredProvider.notifier).state = false;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _takeSnapshot() async {
    if (_snapshotUrl == null) return;

    setState(() {
      _isUploading = true;
      _showFlash = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _showFlash = false);
    });

    try {
      await SnapshotService.takeSnapshotAndUpload(
        snapshotUrl: _snapshotUrl!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Snapshot uploaded to Firebase')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Snapshot failed: $e')),
        );
      }
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ipAsync = ref.watch(deviceIpStreamProvider(widget.deviceId));

    return ipAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading IP: $e')),
      data: (cameraIP) {
        _streamUrl = '$cameraIP/stream';
        _snapshotUrl = '$cameraIP/jpg';

        final isPlaying = ref.watch(_cameraPlayingProvider);
        final isBlurred = ref.watch(_cameraBlurredProvider);
        final latency = ref.watch(_latencyProvider);

        _startLatencyCheck(_streamUrl!);
        debugPrint('Stream URL: $_streamUrl');
        return RefreshIndicator(
          onRefresh: _refreshStream,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
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
                                  streamUrl: _streamUrl!,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  showLiveIcon: true,
                                )
                              : Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.wifi_off,
                                      color: Colors.white, size: 40),
                                ),
                        ),
                      ),
                      if (_showFlash)
                        Positioned.fill(
                          child:
                              Container(color: Colors.white.withOpacity(0.5)),
                        ),
                      if (isBlurred)
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child:
                                Container(color: Colors.black.withOpacity(0.1)),
                          ),
                        ),
                      if (_showControls)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow),
                                color: Colors.white,
                                onPressed: () => ref
                                    .read(_cameraPlayingProvider.notifier)
                                    .state = !isPlaying,
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                color: Colors.white,
                                onPressed: _isUploading ? null : _takeSnapshot,
                              ),
                              IconButton(
                                icon: Icon(
                                    isBlurred ? Icons.blur_off : Icons.blur_on),
                                color: Colors.white,
                                onPressed: () => ref
                                    .read(_cameraBlurredProvider.notifier)
                                    .state = !isBlurred,
                              ),
                              IconButton(
                                icon: const Icon(Icons.folder_open_outlined),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CameraStorageScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.fullscreen),
                                color: Colors.white,
                                onPressed: () =>
                                    _openFullscreen(context, _streamUrl!),
                              ),
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            latency == -1 ? "No Signal" : "$latency ms",
                            style: const TextStyle(
                                color: Color.fromARGB(216, 255, 255, 255),
                                fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 400), // padding for pull-to-refresh
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _openFullscreen(BuildContext context, String streamUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: MJPEGStreamScreen(
                streamUrl: streamUrl,
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
}
