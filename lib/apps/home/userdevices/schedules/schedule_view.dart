import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/logs_model.dart';
import 'package:pigpen_iot/apps/home/userdevices/schedules/schedule_model.dart';
import 'package:pigpen_iot/apps/home/userdevices/schedules/schedule_viewmodel.dart';
import 'package:pigpen_iot/custom/app_bottomsheet.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_cachednetworkimage.dart';
import 'package:pigpen_iot/custom/app_datetime_dialog.dart';
import 'package:pigpen_iot/custom/app_error_handling.dart';
import 'package:pigpen_iot/custom/app_header.dart';
import 'package:pigpen_iot/custom/app_loader.dart';
import 'package:pigpen_iot/custom/app_schedule_previewer_dialog.dart';
import 'package:pigpen_iot/custom/app_text.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/extensions/app_snackbar.dart';
import 'package:pigpen_iot/modules/database.dart';
import 'package:pigpen_iot/modules/dateformats.dart';
import 'package:pigpen_iot/modules/responsive.dart';
import 'package:pigpen_iot/modules/sharedprefs.dart';
import 'package:pigpen_iot/modules/string_compliments.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';
import 'package:pigpen_iot/modules/widgetview.dart';
import 'package:pigpen_iot/router.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

const _pageTitle = 'Schedule';
const _pageDescription =
    'Scheduling is optional, the watering is fully automated and handles by the device.';
const String _confirDeletemMessage =
    'Are you sure you want to delete this schedule?';

/// Schedules Page
class SchedulerPage extends StatelessWidget {
  const SchedulerPage({super.key});

  Widget _header() {
    return Consumer(
      builder: (context, ref, child) {
        final url = ref
            .watch(activeDeviceProvider.select((thing) => thing!.graphicUrl));
        return Header.titleWithDeviceGraphic(
          title: _pageTitle,
          description: _pageDescription,
          graphicUrl: url,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _header(),
              const _CreateSection(),
              const _ScheduledSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Create schedule section
class _CreateSection extends ConsumerStatefulWidget {
  const _CreateSection();
  @override
  ConsumerState<_CreateSection> createState() => _CreateSectionState();
}

class _CreateSectionState extends ConsumerState<_CreateSection> {
  String get deviceId =>
      ref.watch(activeDeviceProvider.select((thing) => thing!.deviceId));

  final dateInfoMessage = 'Choose date that has not been elapsed';
  final timeInfoMessage = 'Choose time that has not been elapsed';

  bool isFieldsNotEmpty() {
    final date = ref.read(dateController.notifier);
    final time = ref.read(timeController.notifier);
    final dateError = ref.read(dateErrorProvider.notifier);
    final timeError = ref.read(timeErrorProvider.notifier);

    bool isNotEmpty = true;
    if (date.state.text.isEmpty) {
      isNotEmpty = false;
      dateError.state = 'Date cannot be empty';
    }
    if (time.state.text.isEmpty) {
      isNotEmpty = false;
      timeError.state = 'Time cannot be empty';
    }
    return isNotEmpty;
  }

  bool isDateAndTimeNotElapsed() {
    final dateTime = ref.read(dateTimeProvider.notifier).state;
    final dateError = ref.read(dateErrorProvider.notifier);
    final timeError = ref.read(timeErrorProvider.notifier);

    final now = DateTime.now();
    final dayNow = DateTime(now.year, now.month, now.day);
    final sched = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (sched.isBefore(dayNow)) {
      dateError.state = 'Cannot schedule elapsed date';
      return false;
    }

    if (dateTime.isBefore(now)) {
      timeError.state = 'Cannot schedule elapsed time';
      return false;
    }
    return true;
  }

  bool isSchedHourAheadThanNow() {
    final dateTime = ref.read(dateTimeProvider.notifier).state;
    final timeError = ref.read(timeErrorProvider.notifier);

    final now = DateTime.now();
    final sched = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
    final hourAhead = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + 1,
      now.minute,
    );

    if (sched.isBefore(hourAhead)) {
      timeError.state = 'Time must be an hour ahead';
      return false;
    }
    return true;
  }

  Future<bool> isScheduleNotDuplicate(String deviceId) async {
    final dateError = ref.read(dateErrorProvider.notifier);
    final timeError = ref.read(timeErrorProvider.notifier);
    final dateTimePicked = ref.read(dateTimeProvider.notifier).state;
    final schedules = await ref.read(schedulesProvider(deviceId).future);

    for (var schedule in schedules) {
      final scheduleDate = schedule.dateTime;
      final isDateEqual = scheduleDate.year == dateTimePicked.year &&
          scheduleDate.month == dateTimePicked.month &&
          scheduleDate.day == dateTimePicked.day;
      final isTimeEqual = scheduleDate.hour == dateTimePicked.hour &&
          scheduleDate.minute == dateTimePicked.minute;
      if (isDateEqual && isTimeEqual) {
        dateError.state = 'The schedule is already exists in queue';
        timeError.state = 'The schedule is already exists in queue';
        return false;
      }
    }
    return true;
  }

  Future<bool> submitSchedule() async {
    final database = ScheduleOperations();
    final dateTimePicked = ref.read(dateTimeProvider.notifier).state;
    await database.uploadSchedule(deviceId, dateTimePicked);
    return Future.value(true);
  }

  void resetProviders() {
    ref.read(dateController.notifier).state.clear();
    ref.read(timeController.notifier).state.clear();
    ref.read(dateErrorProvider.notifier).state = null;
    ref.read(timeErrorProvider.notifier).state = null;
  }

  Future<void> onTappedChooseDate() async {
    const prefs = SharedPrefs();
    if (!(prefs.readBool('TUTORIAL-DATEFIELD') ?? false)) {
      await titledBottomNotesSheet(
        context: context,
        message: dateInfoMessage,
        title: 'Note',
      );
      prefs.writeBool('TUTORIAL-DATEFIELD', true);
      return;
    }

    final selectedDateTime = ref.read(dateTimeProvider.notifier);
    final DateTime initialDate =
        ref.read(dateController.notifier).state.text.isEmpty
            ? DateTime.now()
            : selectedDateTime.state;

    return pickDate(context, initialDate).then((DateTime? result) {
      if (result == null) return;

      final newDateTime = DateTime(
        result.year,
        result.month,
        result.day,
        selectedDateTime.state.hour,
        selectedDateTime.state.minute,
      );

      selectedDateTime.state = newDateTime;
      ref.read(dateErrorProvider.notifier).state = null;
      final dateValue = AppDateFormat('MMM dd yyyy | EEEE').format(newDateTime);
      ref.read(dateController.notifier).state.text = dateValue;
    });
  }

  Future<void> onTappedChooseTime() async {
    const prefs = SharedPrefs();
    if (!(prefs.readBool('TUTORIAL-TIMEFIELD') ?? false)) {
      await titledBottomNotesSheet(
        context: context,
        message: timeInfoMessage,
        title: 'Note',
      );
      prefs.writeBool('TUTORIAL-TIMEFIELD', true);
      return;
    }

    final selectedDateTime = ref.read(dateTimeProvider.notifier);
    final DateTime initialDate =
        ref.read(timeController.notifier).state.text.isEmpty
            ? DateTime.now()
            : selectedDateTime.state;

    return pickTime(context, initialDate).then((result) {
      if (result == null) return;

      final newDateTime = DateTime(
        selectedDateTime.state.year,
        selectedDateTime.state.month,
        selectedDateTime.state.day,
        result.hour,
        result.minute,
      );

      selectedDateTime.state = newDateTime;
      ref.read(timeErrorProvider.notifier).state = null;
      final timeValue = AppDateFormat('hh:mm a').format(newDateTime);
      ref.read(timeController.notifier).state.text = timeValue;
    });
  }

  void onPressedCreateBtn(BuildContext context) {
    if (!isFieldsNotEmpty()) return;
    if (!isDateAndTimeNotElapsed()) return;
    //if (!isSchedHourAheadThanNow()) return;

    showLoader(context, process: isScheduleNotDuplicate(deviceId))
        .then((isNotDuplicate) {
      if (isNotDuplicate == null || !isNotDuplicate) {
        HapticFeedback.heavyImpact();
        return Future.value(false);
      }
      resetProviders();
      return submitSchedule();
    }).then((result) {
      if (!context.mounted) return;
      context.showSnackBar(Compliments().getGreeting(),
          theme: SnackbarTheme.success);
    });
  }

  @override
  Widget build(BuildContext context) => _CreateSectionView(this, ref);
}

class _CreateSectionView
    extends ConStflView<_CreateSection, _CreateSectionState> {
  _CreateSectionView(super.state, super.ref) : super(key: ObjectKey(state));

  Widget normalScreenAndroid(BuildContext context) {
    return Column(
      children: [
        const SectionTitle('Create schedule', margin: null),
        dateField(context, ref),
        timeField(context, ref),
        createButton(context, ref),
      ],
    );
  }

  Widget flaotingWindowAndroid(BuildContext context) {
    return Column(
      children: [
        const SectionTitle('Create schedule', margin: null),
        Row(
          children: [
            Expanded(flex: 3, child: dateField(context, ref)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: timeField(context, ref)),
          ],
        ),
        createButton(context, ref),
      ],
    );
  }

  Widget titleLabel(String title) {
    return SectionLabel(title,
        margin: const EdgeInsets.symmetric(horizontal: 5));
  }

  Widget dateField(BuildContext context, WidgetRef ref) {
    return AppTextField(
      controller: ref.watch(dateController),
      errorText: ref.watch(dateErrorProvider),
      labelText: 'Choose Date',
      textInputAction: TextInputAction.none,
      keyboardType: TextInputType.none,
      readOnly: true,
      prefixIconData: EvaIcons.calendarOutline,
      suffixIconData: EvaIcons.chevronDownOutline,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      onChanged: (text) => ref.read(dateErrorProvider.notifier).state = null,
      onTapped: state.onTappedChooseDate,
      onSuffixIconTapped: state.onTappedChooseDate,
    );
  }

  Widget timeField(BuildContext context, WidgetRef ref) {
    return AppTextField(
      controller: ref.watch(timeController),
      errorText: ref.watch(timeErrorProvider),
      labelText: 'Choose Time',
      textInputAction: TextInputAction.none,
      keyboardType: TextInputType.none,
      readOnly: true,
      prefixIconData: EvaIcons.clockOutline,
      suffixIconData: EvaIcons.chevronDownOutline,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      onChanged: (text) => ref.read(timeErrorProvider.notifier).state = null,
      onTapped: state.onTappedChooseTime,
      onSuffixIconTapped: state.onTappedChooseTime,
    );
  }

  Widget createButton(BuildContext context, WidgetRef ref) {
    return AppFilledButton.small(
      onPressed: () => state.onPressedCreateBtn(context),
      text: 'Create',
      icon: Icons.add,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      alignment: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAppInFloatingWindow(context)
        ? flaotingWindowAndroid(context)
        : normalScreenAndroid(context);
  }
}

/// Scheduled watering section
class _ScheduledSection extends ConsumerStatefulWidget {
  const _ScheduledSection();
  @override
  ConsumerState<_ScheduledSection> createState() => _ScheduledSectionState();
}

class _ScheduledSectionState extends ConsumerState<_ScheduledSection> {
  String get deviceId =>
      ref.watch(activeDeviceProvider.select((thing) => thing?.deviceId ?? '?'));
  String get deviceName => ref
      .watch(activeDeviceProvider.select((thing) => thing?.deviceName ?? '?'));
  String get graphicUrl => ref
      .watch(activeDeviceProvider.select((thing) => thing?.graphicUrl ?? '?'));

  late final Timer _timer;
  int lastSchedulesLength = 3;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final schedules = ref.read(schedulesProvider(deviceId)).asData?.value;
      if (schedules == null || schedules.isEmpty) return;
      final firstSched = schedules.first;
      if (firstSched.dateTime
          .add(const Duration(minutes: 1))
          .isBefore(DateTime.now())) {
        removeDueSchedule(firstSched.key);
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void removeDueSchedule(String databaseKey) {
    doInBackground(
      context: context,
      process: () async {
        final database = ScheduleOperations();
        await database.deleteSchedule(deviceId, databaseKey).then((_) {
          if (!mounted) return;
          context.showSnackBar(
            'Due schedule has been removed',
            theme: SnackbarTheme.success,
          );
        });
      },
      // callBack: () {},
    );
  }

  void onTappedViewAll(Widget child, BuildContext context) {
    if (lastSchedulesLength == 0) return;
    context.push('/app/plant/scheduled-watering', extra: child);
  }

  @override
  Widget build(BuildContext context) => _ScheduledSectionView(this);
}

class _ScheduledSectionView
    extends StflView<_ScheduledSection, _ScheduledSectionState> {
  _ScheduledSectionView(super.state) : super(key: ObjectKey(state));

  Widget _shimmerSchedules(Color color) {
    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    );

    final shimmer = Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 100, decoration: decoration),
                const SizedBox(height: 6),
                Container(height: 14, width: 70, decoration: decoration),
              ],
            ),
          ),
          Container(height: 25, width: 25, decoration: decoration),
          const SizedBox(width: 9),
        ],
      ),
    );

    int shimmerCount = state.lastSchedulesLength;
    if (shimmerCount < 1) {
      shimmerCount = 1;
    } else if (shimmerCount > 10) {
      shimmerCount = 10;
    }

    return ListView.builder(
      itemCount: shimmerCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => shimmer,
    );
  }

  Widget _emptySchedule() {
    const color = Colors.grey;
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hourglass_disabled_rounded, size: 20, color: color),
        SizedBox(width: 10),
        Text('No schedules for now', style: TextStyle(color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final schedulesListView = Consumer(
      child: AppCachedNetworkImage(state.graphicUrl),
      builder: (context, ref, child) {
        final provider = ref.watch(schedulesProvider(state.deviceId));
        return provider.when(
          data: (List<Schedule> schedules) {
            state.lastSchedulesLength = schedules.length;
            if (schedules.isEmpty) return _emptySchedule();

            return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return _SingleScheduleView(
                  deviceGraphic: child,
                  databaseKey: schedule.key,
                  dateTime: schedule.dateTime,
                  deviceId: state.deviceId,
                );
              },
            );
          },
          loading: () => _shimmerSchedules(colorScheme.surfaceContainerHighest),
          error: (e, st) => AppErrorWidget(e as Exception, st, this),
        );
      },
    );

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle('Scheduled', margin: null)),
              GestureDetector(
                onTap: () => state.onTappedViewAll(schedulesListView, context),
                child: const Text('View all >'),
              ),
            ],
          ),
          Expanded(child: schedulesListView),
        ],
      ),
    );
  }
}

/// Single schedule as stateless widget listTile for better performance
class _SingleScheduleView extends StatelessWidget with InternetConnection {
  final String deviceId;
  final Widget? deviceGraphic;
  final String databaseKey;
  final DateTime dateTime;
  const _SingleScheduleView({
    required this.deviceGraphic,
    required this.dateTime,
    required this.databaseKey,
    required this.deviceId,
  });

  void onTappedSchedule(BuildContext context, DateTime dateTime) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    final dateFormat = AppDateFormat();

    final log = Log(
      title: 'Schedule',
      description: 'Water in ${dateFormat.relativeDuration(dateTime)}',
      icon: Icons.hourglass_top_rounded,
      color: color,
      colorDark: color,
    );

    showSchedulePreviewer(context, dateTime: dateTime, log: log);
  }

  void onDismissSchedule(BuildContext context,
      {required String deviceId, required String databaseKey}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (await isConnected(true, context) && !context.mounted) return;
    doInBackground(
      context: context,
      process: () {
        final database = ScheduleOperations();
        database.deleteSchedule(deviceId, databaseKey);
      },
    ).then((_) {
      if (!context.mounted) return;
      context.showSnackBar('Schedule has been removed',
          theme: SnackbarTheme.success);
    });
    // showLoader(
    //   context,
    //   process: () async {
    //     final database = ScheduleOperations();
    //     await database.deleteSchedule(deviceId, databaseKey).then((_) {
    //       if (!context.mounted) return;
    //       context.showSnackBar('Schedule has been removed', theme: SnackbarTheme.success);
    //     });
    //   },
    // ).then((_) {
    //   // if (!context.mounted) return;
    //   // context.showSnackBar('Schedule has been removed', theme: SnackbarTheme.error);
    //   print('Schedule has been removed');
    // });
  }

  Widget _deleteBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Icon(Icons.delete, color: colorScheme.error),
    );
  }

  Widget _listTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = AppDateFormat();

    final dateValue = dateFormatter.dayRepresentation(dateTime);
    final timeValue = dateFormatter.timeShort(dateTime);
    final isSchedisToday = dateFormatter.isToday(dateTime);
    final isSchedisDue = dateTime.isBefore(DateTime.now());

    return Material(
      child: ListTile(
        dense: true,
        onTap: () => onTappedSchedule(context, dateTime),
        title: Text(
          timeValue,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateValue.toCapitalizeFirst(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSchedisToday ? FontWeight.w500 : FontWeight.normal,
            color: isSchedisToday ? colorScheme.primary : Colors.grey,
          ),
        ),
        leading: SizedBox(
          width: 40,
          height: double.infinity,
          child: OverflowBox(
            maxHeight: 65,
            alignment: Alignment.bottomCenter,
            child: deviceGraphic,
          ),
        ),
        trailing: Icon(
          isSchedisToday
              ? Icons.water_drop
              : isSchedisDue
                  ? Icons.hourglass_bottom_rounded
                  : Icons.hourglass_top_rounded,
          color: isSchedisToday ? colorScheme.primary : null,
        ),
        enabled: !isSchedisDue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
          key: Key(databaseKey),
          direction: DismissDirection.endToStart,
          background: _deleteBackground(context),
          onDismissed: (direction) => onDismissSchedule(context,
              deviceId: deviceId, databaseKey: databaseKey),
          confirmDismiss: (direction) => showExitDialog(context,
              title: 'delete', message: _confirDeletemMessage),
          child: _listTile(context)),
    );
  }
}
