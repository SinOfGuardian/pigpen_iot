import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/custom/app_cachednetworkimage.dart';
import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_icon.dart';
import 'package:pigpen_iot/custom/ui_static_shimmer.dart';
import 'package:pigpen_iot/models/userdevice_model.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';
import 'package:pigpen_iot/provider/devices_provider.dart';

class AnimalPreview extends ConsumerWidget {
  const AnimalPreview({
    super.key,
    required this.device,
    this.onTap,
  });
  final UserDevice device;
  final VoidCallback? onTap;

  Widget _name(TextTheme textTheme) {
    final title = textTheme.titleMedium;
    return Padding(
      padding: EdgeInsets.only(bottom: device.deviceName.isEmpty ? 10 : 1),
      child: device.deviceName.isEmpty
          ? const StaticShimmer.roundedRectangle(height: 20, widthFactor: 0.8)
          : Text(device.deviceName.toTitleCase(),
              style: title, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }

  Widget _device(WidgetRef ref, TextTheme textTheme, ColorScheme colorScheme) {
    if (device.deviceId.isEmpty) {
      const StaticShimmer.roundedRectangle(height: 20, widthFactor: 0.1);
    }
    final deviceModel =
        ref.read(devicesProvider.notifier).lookForDeviceModel(device.deviceId);
    final label =
        textTheme.labelLarge?.copyWith(height: 2, color: colorScheme.primary);
    return FutureBuilder(
      future: deviceModel,
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(snapshot.data!, style: label);
        }
        return const StaticShimmer.roundedRectangle(
            height: 20, widthFactor: 0.5);
      },
    );
  }

  Widget _image() {
    return OverflowBox(
        alignment: Alignment.bottomCenter,
        maxHeight: 100,
        maxWidth: 100,
        child: device.graphicUrl.isNotEmpty
            ? Hero(
                tag: device.deviceId,
                child: AppCachedNetworkImage(device.graphicUrl,
                    memCacheHeight: 200),
              )
            : null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    const padding = EdgeInsets.symmetric(vertical: 25, horizontal: 15);
    return Stack(
      children: [
        AppContainer(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          color: device.deviceId.isEmpty
              ? colorScheme.surfaceContainer
              : colorScheme.secondaryContainer,
          boxShadow: const [],
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: padding,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 60,
                      child: OverflowBox(
                        maxHeight: 160,
                        maxWidth: 160,
                        child: Blob.random(
                          size: 120,
                          edgesCount: 12,
                          styles: BlobStyles(
                            color: device.graphicUrl.isEmpty
                                ? colorScheme.outlineVariant
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _name(textTheme),
                          _device(ref, textTheme, colorScheme),
                        ],
                      ),
                    ),
                    AppIcon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: onTap == null
                          ? colorScheme.outlineVariant
                          : colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: padding.copyWith(left: padding.left + 20),
          width: 80,
          height: 60,
          child: _image(),
        ),
      ],
    );
  }
}
