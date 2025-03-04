import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum TransitionType { horizontal, scaled }

class SwitchPageTransistion extends StatelessWidget {
  final bool isFirstPage;
  final Widget firstPage, secondPage;
  final int duration;
  final TransitionType transitionType;
  const SwitchPageTransistion(
      {super.key,
      required this.isFirstPage,
      required this.firstPage,
      required this.secondPage,
      this.transitionType = TransitionType.horizontal,
      this.duration = 1000});

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: Duration(milliseconds: duration),
      reverse: !isFirstPage,
      child: isFirstPage ? firstPage : secondPage,
      transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType == TransitionType.horizontal
            ? SharedAxisTransitionType.horizontal
            : SharedAxisTransitionType.scaled,
        child: child,
      ),
    );
  }
}

Page sharedAxisTransition({
  required GoRouterState state,
  required Widget child,
  int durationMillis = 600,
  TransitionType transitionType = TransitionType.scaled,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType == TransitionType.scaled
            ? SharedAxisTransitionType.scaled
            : SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

Page fadeThroughTransition({
  required GoRouterState state,
  required Widget child,
  int durationMillis = 600,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}

Page fadeScaleTransition({
  required GoRouterState state,
  required Widget child,
  int durationMillis = 600,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeScaleTransition(animation: animation, child: child);
    },
  );
}

Page slideTransition({
  required GoRouterState state,
  required Widget child,
  int durationMillis = 600,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

Page scaleTransition({
  required GoRouterState state,
  required Widget child,
  int durationMillis = 600,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(scale: animation, child: child);
    },
  );
}

Page fadeTransition({
  required GoRouterState state,
  required Widget child,
  int durationMillis = 600,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
