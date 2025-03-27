import 'package:flutter/material.dart';

const double _kProfileSmall = 60.0;
const double _kProfileBig = 90.0;

class AvatarIcon extends StatelessWidget {
  final String firstname;
  final String lastname;
  final double _size;

  const AvatarIcon({
    super.key,
    required this.firstname,
    required this.lastname,
    double size = _kProfileSmall,
  }) : _size = size;

  const AvatarIcon.small({
    super.key,
    required this.firstname,
    required this.lastname,
  }) : _size = _kProfileSmall;

  const AvatarIcon.big({
    super.key,
    required this.firstname,
    required this.lastname,
  }) : _size = _kProfileBig;

  String _getInitials() {
    if (firstname.isEmpty || lastname.isEmpty) return '';
    return '${firstname.trim()[0]}${lastname.trim()[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    TextStyle? style = null;
    if (_size == _kProfileSmall) {
      style = textTheme.headlineLarge?.copyWith(color: colorScheme.primary);
    } else if (_size == _kProfileBig) {
      style = textTheme.displayLarge?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      );
    }

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(_getInitials(), style: style),
    );
  }
}
