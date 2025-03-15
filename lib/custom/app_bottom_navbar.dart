import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ionicons/ionicons.dart';

class BottomGNavBar extends StatelessWidget {
  final Function(int) onTabChange;
  final int index;
  final String role;

  const BottomGNavBar(
      {super.key,
      required this.onTabChange,
      required this.index,
      required this.role});

  List<GButton> getNavButtons() {
    if (role == 'admin') {
      // Admin-specific buttons

      return const [
        GButton(icon: EvaIcons.homeOutline, iconSize: 20, text: 'Home'),
        GButton(icon: EvaIcons.hardDriveOutline, iconSize: 20, text: 'Device'),
        GButton(icon: EvaIcons.peopleOutline, iconSize: 20, text: 'User'),
        GButton(icon: Ionicons.leaf_outline, iconSize: 20, text: 'Plant'),
        GButton(icon: EvaIcons.menu2Outline, iconSize: 20, text: 'Menu'),
      ];
    } else {
      // User-specific buttons
      return const [
        GButton(icon: EvaIcons.homeOutline, iconSize: 20, text: 'Home'),
        GButton(icon: EvaIcons.shoppingCartOutline, iconSize: 20, text: 'Shop'),
        GButton(
            icon: EvaIcons.inboxOutline, iconSize: 20, text: 'Notification'),
        GButton(icon: EvaIcons.menu2Outline, iconSize: 20, text: 'Menu'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final titleStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: colorScheme.primary);

    const adminPadding = EdgeInsets.symmetric(vertical: 5, horizontal: 15);
    const userPadding =
        EdgeInsets.symmetric(vertical: 5, horizontal: 30); // horizontal: 50

    return Container(
      padding: role == 'admin' ? adminPadding : userPadding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        // border: Border(top: BorderSide(color: colorScheme.surfaceContainer, width: 1)),
      ),
      child: GNav(
        selectedIndex: index,
        haptic: false,
        gap: 8,
        iconSize: 20,
        tabs: getNavButtons(),
        onTabChange: onTabChange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: colorScheme.scrim,
        activeColor: colorScheme.primary,
        rippleColor: colorScheme.primary.withOpacity(0.2),
        textStyle: titleStyle,
        // tabBackgroundColor: colorScheme.surfaceContainer,
      ),
    );
  }
}

class PlantNavBar extends StatelessWidget {
  final int currentIndex;
  final PageController controller;
  final String role;
  const PlantNavBar(
      {super.key,
      required this.currentIndex,
      required this.controller,
      required this.role});

  List<NavigationDestination> buttons(context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final Color iconColor = colorScheme.outline;
    final Color selectedColor = colorScheme.primary;

    return [
      NavigationDestination(
        icon: Icon(FontAwesomeIcons.seedling, size: 18, color: iconColor),
        selectedIcon:
            Icon(FontAwesomeIcons.seedling, size: 18, color: selectedColor),
        label: 'Plant',
      ),
      NavigationDestination(
        icon: Icon(FontAwesomeIcons.chartLine, size: 18, color: iconColor),
        selectedIcon:
            Icon(FontAwesomeIcons.chartLine, size: 18, color: selectedColor),
        label: 'Monitoring',
      ),
      NavigationDestination(
        icon: Icon(FontAwesomeIcons.calendarDay, size: 18, color: iconColor),
        selectedIcon:
            Icon(FontAwesomeIcons.calendarDay, size: 18, color: selectedColor),
        label: 'Schedules',
      ),
      NavigationDestination(
        icon:
            Icon(FontAwesomeIcons.clockRotateLeft, size: 18, color: iconColor),
        selectedIcon: Icon(FontAwesomeIcons.clockRotateLeft,
            size: 18, color: selectedColor),
        label: 'Logs',
      ),
      if (role != 'user')
        NavigationDestination(
          icon: Icon(FontAwesomeIcons.poop, size: 18, color: iconColor),
          selectedIcon:
              Icon(FontAwesomeIcons.poop, size: 18, color: selectedColor),
          label: 'Final',
        ),
    ];
  }

  void animateToPage(int index) {
    controller.animateToPage(
      index,
      duration: const Duration(seconds: 2),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 90),
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        child: NavigationBar(
          height: 50,
          destinations: buttons(context),
          selectedIndex: currentIndex,
          // indicatorColor:
          //     isDarkTheme ? colorScheme.primary : colorScheme.onSurface,
          indicatorColor: Colors.transparent,
          backgroundColor: colorScheme.secondaryContainer,
          surfaceTintColor: Colors.transparent,
          animationDuration: const Duration(seconds: 2),
          onDestinationSelected: (index) => animateToPage(index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      ),
    );
  }
}
