import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/apps/home/devices/device_list.dart';
import 'package:pigpen_iot/apps/home/userdevices/logs/log_operation.dart';
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
import 'package:pigpen_iot/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

const _pageTitle = 'Schedule';
const _pageDescription =
    'Scheduling is totally optional—it just sends you a reminder when it’s time to wash or feeding the pigs, since that part isn’t automated.';
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

  // Generate 3 schedules for the selected date and time
  // List<Schedule> generateDailySchedules(DateTime selectedDateTime) {
  //   final schedules = <Schedule>[];
  //   const interval = Duration(hours: 6); // 6 hours apart

  //   for (int i = 0; i < 3; i++) {
  //     final scheduleTime = selectedDateTime.add(interval * i);
  //     schedules.add(
  //       Schedule(
  //         key: '${deviceId}_${scheduleTime.toIso8601String()}', // Unique key
  //         dateTime: scheduleTime,
  //       ),
  //     );
  //   }

  //   return schedules;
  // }

  // // Validate the 3 schedules
  // bool validateSchedules(List<Schedule> schedules) {
  //   final now = DateTime.now();

  //   // Check if any schedule is in the past
  //   for (final schedule in schedules) {
  //     if (schedule.dateTime.isBefore(now)) {
  //       return false; // Schedule is in the past
  //     }
  //   }

  //   // Check if schedules are at least 1 hour apart
  //   for (int i = 1; i < schedules.length; i++) {
  //     final previousTime = schedules[i - 1].dateTime;
  //     final currentTime = schedules[i].dateTime;
  //     if (currentTime.difference(previousTime) < const Duration(hours: 1)) {
  //       return false; // Schedules are too close
  //     }
  //   }

  //   return true;
  // }

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
    final category = ref.read(categoryProvider);
    final scheduleKey = dateTimePicked
        .toIso8601String()
        .replaceAll(":", "-")
        .replaceAll(".", "-");

    // Log the deviceId
    debugPrint('Device ID: $deviceId');

    // Generate 3 schedules
    // final schedules = generateDailySchedules(dateTimePicked);

    // Validate the schedules
    // if (!validateSchedules(schedules)) {
    //   return false;
    // }

    // Save all schedules
    // for (final schedule in schedules) {
    await database.uploadSchedule(deviceId, dateTimePicked, category,
        key: scheduleKey);

    // Schedule notification (adjust title/body based on category)
    final bodyText = category == 'shower'
        ? 'Time to wash the pigs!'
        : 'Time to feed the pigs!';

    // Convert DateTime to TZDateTime (local time zone)
    final tzScheduledDate = tz.TZDateTime.from(dateTimePicked, tz.local);
    debugPrint('Original DateTime: ${dateTimePicked.toIso8601String()}');
    debugPrint('Converted TZDateTime: $tzScheduledDate');

    // Get the current time in the local time zone
    final now = tz.TZDateTime.now(tz.local);
    debugPrint('Current Time: $now');

    // Calculate the difference between the scheduled time and current time
    final durationUntilScheduled = tzScheduledDate.difference(now);
    debugPrint('Duration Until Scheduled: $durationUntilScheduled');

    // Subtract 1 second from the duration
    final adjustedDuration =
        durationUntilScheduled - const Duration(seconds: 1);
    debugPrint('Adjusted Duration (minus 1 second): $adjustedDuration');

    // Schedule a notification using the adjusted duration
    final notificationTime = now.add(adjustedDuration);
    debugPrint('Scheduled Notification Time: $notificationTime');

    await NotificationService.scheduleLocalNotification(
      title: 'Pig $category Reminder',
      body:
          '$bodyText Scheduled at ${DateFormat('hh:mm a').format(dateTimePicked)}',
      scheduledTime: notificationTime,
      payload: '$deviceId|$scheduleKey|$category',
    );

    debugPrint('Scheduled notification at: $notificationTime');
    //  }
    return true;
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

  void onPressedCreateBtn(BuildContext context) async {
    if (!isFieldsNotEmpty()) return;
    if (!isDateAndTimeNotElapsed()) return;

    try {
      final isNotDuplicate =
          await showLoader(context, process: isScheduleNotDuplicate(deviceId));
      if (isNotDuplicate == null || !isNotDuplicate) {
        HapticFeedback.heavyImpact();
        return;
      }
      resetProviders();
      await submitSchedule();
      if (!context.mounted) return;
      context.showSnackBar(Compliments().getGreeting(),
          theme: SnackbarTheme.success);
    } catch (e) {
      if (!context.mounted) return;
      context.showSnackBar('Failed to schedule notifications: $e',
          theme: SnackbarTheme.error);
    }
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
        categoryDropdown(ref),
        createButton(context, ref),
      ],
    );
  }

  Widget floatingWindowAndroid(BuildContext context) {
    return Column(
      children: [
        const SectionTitle('Create schedule', margin: null),
        Row(
          children: [
            Expanded(flex: 3, child: dateField(context, ref)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: timeField(context, ref)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: categoryDropdown(ref)),
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

  Widget categoryDropdown(WidgetRef ref) {
    return AppDropdownField<String>(
      labelText: 'Select Category',
      value: ref.watch(categoryProvider),
      items: const [
        DropdownMenuItem(value: 'shower', child: Text('Shower')),
        DropdownMenuItem(value: 'feeding', child: Text('Feeding')),
      ],
      onChanged: (val) {
        if (val != null) {
          ref.read(categoryProvider.notifier).state = val;
        }
      },
      prefixIconData: Icons.category,
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
        ? floatingWindowAndroid(context)
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
      //This code is to remove the schedule
      // final firstSched = schedules.first;
      // if (firstSched.dateTime
      //     .add(const Duration(minutes: 1))
      //     .isBefore(DateTime.now())) {
      //   removeDueSchedule(firstSched.key);
      // }
      final firstSched = schedules.first;
      if (firstSched.dateTime
          .add(const Duration(minutes: 1))
          .isBefore(DateTime.now())) {
        // _moveToLogsAndRemove(firstSched);
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
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
    context.push('/home/user-device/scheduled-watering', extra: child);
  }

  @override
  Widget build(BuildContext context) => _ScheduledSectionView(this);

  Future<void> _moveToLogsAndRemove(Schedule schedule) async {
    final database = ScheduleOperations();
    final logger = LogOperations();

    await logger.addToLogs(
      deviceId: deviceId,
      scheduleKey: schedule.key,
      category: schedule.category,
      dateTime: schedule.dateTime,
      status: 'timeout', // auto timeout
    );

    await database.deleteSchedule(deviceId, schedule.key);

    if (!mounted) return;
    context.showSnackBar(
      'Moved to logs as timeout',
      theme: SnackbarTheme.success,
    );
  }
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
                  category: schedule.category,
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
  final String category;
  final DateTime dateTime;
  const _SingleScheduleView({
    required this.deviceGraphic,
    required this.dateTime,
    required this.databaseKey,
    required this.deviceId,
    required this.category,
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

    // final dateValue = dateFormatter.dayRepresentation(dateTime);
    // final timeValue = dateFormatter.timeShort(dateTime);
    final isSchedisToday = dateFormatter.isToday(dateTime);
    final isSchedisDue = dateTime.isBefore(DateTime.now());
    // final subtitleText = isSchedisToday
    //     ? 'Today - ${dateFormatter.timeShort(dateTime)}'
    //     : dateFormatter.format(dateTime); // fallback
    final titleText = category.toTitleCase(); // Shower or Feeding

    return Material(
      child: ListTile(
        dense: true,
        onTap: () => onTappedSchedule(context, dateTime),
        title: Text(
          titleText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          AppDateFormat().formattedScheduleLabel(dateTime),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSchedisToday ? FontWeight.w500 : FontWeight.normal,
            color: isSchedisToday
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
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

final categoryProvider = StateProvider<String>((ref) => 'shower');
