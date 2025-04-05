import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/custom/app_menu_tile.dart';
import 'package:pigpen_iot/models/user_model.dart';
import 'package:pigpen_iot/services/internet_connection.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pigpen_iot/custom/app_container.dart';
import 'package:pigpen_iot/custom/app_icon.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';
import 'package:pigpen_iot/custom/ui_avatar_icon.dart';
import 'package:pigpen_iot/custom/ui_static_shimmer.dart';
import 'package:pigpen_iot/provider/user_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TitledAppBar2(title: 'Menu', leadingIcon: null),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileOption(),
            _Option(),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends ConsumerWidget {
  const _ProfileOption();

  void _onTapped(BuildContext context) {
    context.push('/home/profile');
  }

  Widget _shimmer(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return AppContainer(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaticShimmer.roundedRectangle(height: 20, width: 0.6),
                SizedBox(height: 5),
                StaticShimmer.roundedRectangle(height: 15, width: 0.45),
              ],
            ),
          ),
          const AppIcon(Icons.chevron_right_rounded, size: 26),
        ],
      ),
    );
  }

  Widget _contents(BuildContext context, PigpenUser user) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final title = textTheme.titleMedium;
    final label = textTheme.labelLarge?.copyWith(height: 1.6);

    return AppContainer(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTapped(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                AvatarIcon.small(
                    firstname: user.firstname, lastname: user.lastname),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.firstname} ${user.lastname}',
                          style: title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      Text('View your profile',
                          style: label,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: AppIcon(
                    EvaIcons.chevronRightOutline,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(activeUserProvider);
    return userProvider.when(
      data: (user) => _contents(context, user),
      loading: () => _shimmer(context),
      error: (e, st) => Text(e.toString()),
    );
  }
}

class _Option extends StatelessWidget with InternetConnection {
  const _Option();

  Future<void> _shareApp(BuildContext context) async {
    // Show loader while preparing the share content
    await showLoader(
      context,
      process: _performShare(context),
    );
  }

  Future<void> _performShare(BuildContext context) async {
    try {
      // Customize this message with your app's details
      const String appName = 'Pigpen IoT';
      const String appDescription =
          'The best IoT solution for pigpen monitoring and management';
      const String appStoreLink =
          'https://apps.apple.com/us/app/your-app-id'; // Replace with your iOS app link
      const String playStoreLink =
          'https://play.google.com/store/apps/details?id=your.package.name'; // Replace with your Android app link

      const String shareText = '''
Check out $appName - $appDescription

Download now:
iOS: $appStoreLink
Android: $playStoreLink

#PigpenIoT #SmartFarming #LivestockMonitoring
''';

      // Small delay to ensure loader is visible
      await Future.delayed(const Duration(milliseconds: 300));

      await Share.share(
        shareText,
        subject: 'Check out $appName',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share app')),
        );
      }
    }
  }

  Widget _tile(String title, IconData icon, void Function()? callback) {
    return SettingTile(title: title, leadingIcon: icon, callback: callback);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(children: [
      AppContainer(
        color:
            isDark ? colorScheme.surfaceContainer : colorScheme.surfaceBright,
        padding: EdgeInsets.zero,
        child: Column(children: [
          _tile('Manage devices', EvaIcons.edit2Outline, () {}),
          _tile('Settings', EvaIcons.settingsOutline, () {}),
          _tile('Theme', EvaIcons.moonOutline,
              () => context.push('/app/theme-settings')),
          _tile('Manual', EvaIcons.bookOutline, () {}),
          _tile('Share App', EvaIcons.shareOutline, () => _shareApp(context)),
          _tile('Data Privacy', EvaIcons.lockOutline, () {}),
          _tile('Feedback', EvaIcons.messageSquareOutline,
              () => context.push('/app/feedback')),
          _tile(
              'About', EvaIcons.infoOutline, () => context.push('/app/about')),
          // _tile(
          //     'Log out', EvaIcons.logOutOutline, () => logoutAction(context)),
        ]),
      ),
      const AppContainer(
        padding: EdgeInsets.zero,
        child: Column(children: []),
      ),
    ]);
  }
}
