import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/userdevices/dashboard/dashboard_screen.dart';
// import 'package:pigpen_iot/apps/home/userdevices/logs/archived_logs_screen.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/log_table_screen.dart';

import 'package:pigpen_iot/apps/home/userdevices/monitoring/monitoring_screen.dart';
import 'package:pigpen_iot/apps/home/userdevices/schedules/schedule_view.dart';
import 'package:pigpen_iot/custom/app_bottom_navbar.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';
import 'package:pigpen_iot/provider/user_provider.dart';

class UserDevicePageView extends ConsumerStatefulWidget {
  const UserDevicePageView({super.key});
  @override
  ConsumerState<UserDevicePageView> createState() => _UserDevicePageViewState();
}

class _UserDevicePageViewState extends ConsumerState<UserDevicePageView> {
  final _controller = PageController(initialPage: 0);
  int _pageIndex = 0;

  final List<Widget> pages = [
    const DashboardScreen(),
    const MonitoringScreen(),
    const SchedulerPage(),
    const LogTableScreen()
    // const FinalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(activeUserProvider).asData?.value.role;
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint('Animal page build');
    return Scaffold(
      backgroundColor: _pageIndex == 0 ? colorScheme.secondaryContainer : null,
      extendBody: true,
      // extendBodyBehindAppBar: true,
      appBar: TitledAppBar(
        leadingIcon: EvaIcons.arrowBackOutline,
        trailingIcon: EvaIcons.questionMark,
        trailingAction: () {},
      ),
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) => setState(() => _pageIndex = index),
        children: pages,
      ),
      bottomNavigationBar: AnimalNavBar(
          controller: _controller,
          currentIndex: _pageIndex,
          role: role ?? 'user'),
    );
  }
}
