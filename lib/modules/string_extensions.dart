// import 'package:plantito_iot/classes/string_extensions.dart';
extension StringExtension on String {
  String toCapitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((str) => str.toCapitalizeFirst()).join(' ');
  }
}
