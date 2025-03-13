import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/custom/app_icon.dart';
import 'package:pigpen_iot/provider/user_provider.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';

class TitledAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final void Function()? leadingAction;
  final void Function()? trailingAction;
  final Alignment alignment;

  const TitledAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingAction,
    this.trailingAction,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          leadingIcon != null ? 10 : 60,
          0,
          trailingIcon != null ? 10 : 60,
          0,
        ),
        height: preferredSize.height,
        child: Row(
          children: <Widget>[
            if (leadingIcon != null)
              IconButton(
                icon: AppIcon(leadingIcon!),
                onPressed: leadingAction ?? () => Navigator.pop(context),
                highlightColor: colorScheme.primary.withOpacity(0.2),
              ),
            Expanded(
              child: Center(
                  child: Text(title?.toTitleCase() ?? '', style: titleStyle)),
            ),
            if (trailingIcon != null)
              IconButton(
                icon: AppIcon(trailingIcon!),
                onPressed: trailingAction,
                highlightColor: colorScheme.primary.withOpacity(0.2),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class TitledAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final void Function()? leadingAction;
  final void Function()? trailingAction;
  final Alignment alignment;

  const TitledAppBar2({
    super.key,
    this.title,
    this.leadingIcon = EvaIcons.chevronLeftOutline,
    this.trailingIcon,
    this.leadingAction,
    this.trailingAction,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.headlineMedium;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // padding: EdgeInsets.only(
        //   left: leadingIcon != null ? 10 : 60,
        //   top: 0,
        //   right: trailingIcon != null ? 10 : 60,
        //   bottom: 0,
        // ),
        height: preferredSize.height,
        child: Row(
          children: <Widget>[
            if (leadingIcon != null)
              IconButton(
                icon: AppIcon(leadingIcon!, size: 26),
                onPressed: leadingAction ?? () => Navigator.pop(context),
                highlightColor: colorScheme.primary.withOpacity(0.15),
              ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title?.toTitleCase() ?? '', style: titleStyle)),
            if (trailingIcon != null)
              IconButton(
                icon: AppIcon(trailingIcon!, size: 26),
                onPressed: trailingAction,
                highlightColor: colorScheme.primary.withOpacity(0.2),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
  });

  Widget _greet(String greet, TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      greet.toTitleCase(),
      style: textTheme.headlineMedium,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _firstname(String? firstname, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return firstname == null
        ? Container(
            height: 35,
            width: 180,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : Text(
            'Hi, ' + firstname.toTitleCase(),
            style: textTheme.bodyLarge?.copyWith(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: preferredSize.height,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final firstname =
                      ref.watch(activeUserProvider).asData?.value.firstname;
                  final greet = ref.watch(_greetingProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _firstname(firstname, context),
                      _greet(greet, textTheme, colorScheme),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: null,
              // (){
              //   // Navigate to the NotificationPractice screen
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const NotificationPractice(),
              //     ),
              //   );
              // },
              highlightColor: colorScheme.primary.withOpacity(0.6),
            ),
            Padding(
              padding: const EdgeInsets.only(left: .05),
              child: Image.asset(
                'assets/images/logo50x50.png',
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 30);
}

class PlantAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final void Function()? leadingAction;
  final void Function()? trailingAction;
  final IconData plantIcon;

  const PlantAppBar({
    super.key,
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingAction,
    this.trailingAction,
    this.plantIcon = Icons.local_florist,
    // Default plant icon
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle =
        textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: preferredSize.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (leadingIcon != null)
              IconButton(
                icon: Icon(leadingIcon),
                onPressed: leadingAction ?? () => Navigator.pop(context),
                color: colorScheme.onSurface,
                highlightColor: colorScheme.primary.withOpacity(0.6),
              ),
            Text(
              title,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8), // Spacing between title and icon
            Icon(
              plantIcon,
              color: colorScheme.primary,
              size: 24, // Adjust size as needed
            ),
            const Spacer(), // Push trailing icon to the right
            if (trailingIcon != null)
              IconButton(
                icon: Icon(trailingIcon),
                onPressed: trailingAction,
                color: colorScheme.onSurface,
                highlightColor: colorScheme.primary.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

final _greetingProvider =
    StateNotifierProvider<_GreetingNotifier, String>((ref) {
  return _GreetingNotifier();
});

class _GreetingNotifier extends StateNotifier<String> {
  Timer? timer;

  _GreetingNotifier() : super(greeting(DateTime.now())) {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final newGreet = greeting(DateTime.now());
      if (state != newGreet) state = newGreet;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  static String greeting(DateTime dateTime) {
    int hour = dateTime.hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
