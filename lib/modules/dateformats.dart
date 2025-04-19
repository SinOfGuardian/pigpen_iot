import 'package:intl/intl.dart';

class AppDateFormat extends DateFormat {
  AppDateFormat([super.newPattern, super.locale]);

  String dayRepresentation(DateTime date) {
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAhead = today.add(const Duration(days: 7));

    if (day.isAtSameMomentAs(today)) return 'today';
    if (day.isAtSameMomentAs(tomorrow)) return 'tomorrow';
    if (day.isAtSameMomentAs(yesterday)) return 'tomorrow';
    if (day.isBefore(weekAhead)) return dayFull(date);
    if (date.isBefore(now)) return 'Missed ${monthDayYear(date)}';

    // Else, return just the date with no representation
    return monthDayYear(date);
  }

  /// Returns a formatted string representing the duration between the given
  /// `DateTime` object and the current time, including years, months, days,
  /// hours, and minutes.
  ///
  /// Outputs sample: "6 years 12 months 1 day 2 hours and 25 mins"
  String relativeDuration(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    final years = difference.inDays ~/ 365;
    final months = (difference.inDays - years * 365) ~/ 30;
    final days = difference.inDays - years * 365 - months * 30;
    final hours = difference.inHours - difference.inDays * 24;
    final minutes = difference.inMinutes - difference.inHours * 60;

    String result = '';
    if (years > 0) {
      result += '$years year';
      result += years > 1 ? 's ' : ' ';
    }
    if (months > 0) {
      result += '$months month';
      result += months > 1 ? 's ' : ' ';
    }
    if (days > 0) {
      result += '$days day';
      result += days > 1 ? 's ' : ' ';
    }
    if (hours > 0) {
      result += '$hours hour';
      result += hours > 1 ? 's ' : ' ';
    }
    if (minutes > 0) {
      result += result.isNotEmpty ? 'and ' : '';
      result += '$minutes min';
      result += minutes > 1 ? 's ' : '';
    }

    return result;
  }

  /// `true` if the given date evaluates to today's date.
  bool isToday(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays == 0 && now.day == date.day;
  }

  /// `true` if the given date evaluates to tomorrow.
  bool isTomorrow(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays == 1 && now.day + 1 == date.day;
  }

  /// `true` if the given date evaluates to yesterday.
  bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays == 1 && now.day - 1 == date.day;
  }

  /// Outputs sample: "9:30 PM"
  String timeShort(DateTime date) => DateFormat.jm().format(date);

  /// Outputs sample: "21:38" force 24 hour time
  String timeMilitary(DateTime date) => DateFormat.Hm().format(date);

  /// Outputs sample: "Tue"
  String dayAbbrev(DateTime date) => DateFormat.E().format(date);

  /// Outputs sample: "Tuesday"
  String dayFull(DateTime date) => DateFormat.EEEE().format(date);

  /// Outputs sample: "Jan"
  String monthAbbrev(DateTime date) => DateFormat.MMM().format(date);

  /// Outputs sample: "January"
  String monthFull(DateTime date) => DateFormat.MMMM().format(date);

  /// Outputs sample: "2022"
  String yearNumeric(DateTime date) => DateFormat.y().format(date);

  /// Outputs sample: "Jan 1, 2022"
  String monthDayYear(DateTime date) => DateFormat.yMMMd().format(date);

  /// Outputs sample: "7/10/2023"
  String monthDayYearNumeric(DateTime date) => DateFormat.yMd().format(date);

  /// Outputs sample: "January 1, 2022"
  String monthDayYearFull(DateTime date) => DateFormat.yMMMMd().format(date);

  /// Outputs sample: "Jan 1, 2022 at 9:30 PM"
  String monthDayYearTime(DateTime date) =>
      DateFormat.yMMMd().add_jm().format(date);

  String formattedScheduleLabel(DateTime date) {
    if (isToday(date)) {
      return 'Today - ${timeShort(date)}';
    }
    return DateFormat('MMM dd yyyy - hh:mm a').format(date);
  }
}
