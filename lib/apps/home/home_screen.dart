import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final List<Widget> children = [
    const DeviceList(),
    // const ThingsSection(),
    // const TipsAndGuidsSection(),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: const HomeAppBar(),
      // backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: RefreshIndicator(
            displacement: 10,
            onRefresh: () async =>
                (), //ref.invalidate(userDevicesStreamProvider),
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  DeviceList(),
                  // SizedBox(height: 10),
                  // DeviceList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
