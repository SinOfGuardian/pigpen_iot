import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_cachednetworkimage.dart';
import 'package:pigpen_iot/modules/string_compliments.dart';

Future<void> showAddedDeviceDialog(BuildContext context,
    {required String deviceId, required String graphicUrl}) async {
  final colorScheme = Theme.of(context).colorScheme;
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      title: Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            maxHeight: 180,
            maxWidth: 180,
            child: Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      colorScheme.surfaceContainer, BlendMode.srcIn),
                  child: AppCachedNetworkImage(graphicUrl, memCacheHeight: 360),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: AppCachedNetworkImage(graphicUrl, memCacheHeight: 360),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: colorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      content: const _AddedDeviceDialog(),
      actions: <Widget>[
        AppFilledButton.big(
          icon: Icons.check_rounded,
          text: 'Done',
          onPressed: () => context.pop(),
        ),
      ],
    ),
  );
}

class _AddedDeviceDialog extends StatelessWidget {
  const _AddedDeviceDialog();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final greetings = Compliments();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greetings.getGreeting(),
          style: textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          greetings.getLine(),
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
