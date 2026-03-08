/// Helper functions for prayer time calculations and formatting.
///
/// This file contains utility functions used throughout the prayer timetable
/// library for time calculations, formatting, and various helper operations.
library;

/// Determines if a given date is during Daylight Saving Time (DST).
///
/// This function compares the timezone offset of the given date with
/// the timezone offset of June 1st of the same year. If they match,
/// the date is considered to be in DST.
///
/// [d] - The date to check for DST
/// Returns true if the date is during DST, false otherwise
bool isDSTCalc(DateTime d) =>
    DateTime(d.year, 6, 1).timeZoneOffset == d.timeZoneOffset;

/// Rounds a numeric value to 2 decimal places.
///
/// [value] - The numeric value to round
/// Returns the value rounded to 2 decimal places as a double
double round2Decimals(num value) => double.parse(value.toStringAsFixed(2));

/// Converts seconds since midnight to a DateTime object.
///
/// This function is useful for converting prayer times stored as seconds
/// since midnight into proper DateTime objects with DST adjustment.
///
/// [seconds] - Seconds since midnight (0-86399)
/// [date] - The base date to use
/// [offset] - Optional day offset to apply
/// Returns a DateTime object representing the time
DateTime secondsToDateTime(int seconds, DateTime date, {int offset = 0}) {
  int dstAdjust = isDSTCalc(date) ? 1 : 0;

  return DateTime(
    date.add(Duration(days: offset)).year,
    date.add(Duration(days: offset)).month,
    date.add(Duration(days: offset)).day,
    0,
    0,
    0,
  ).add(Duration(seconds: seconds)).add(Duration(hours: dstAdjust));
}

/// Converts a fractional hour value to a DateTime object.
///
/// This function takes a decimal hour value (e.g., 13.5 for 1:30 PM)
/// and converts it to a proper DateTime object with optional DST adjustment.
///
/// [hourFraction] - The hour as a decimal (0.0 to 23.999...)
/// [date] - The base date to use
/// [summerTimeCalc] - Whether to apply DST adjustment
/// [showSeconds] - Whether to include seconds in the calculation
/// Returns a DateTime object representing the time
DateTime hourFractionToDateTime(
    double hourFraction, DateTime date, bool summerTimeCalc, bool showSeconds) {
  // adjust times for dst
  int dstAdjust = summerTimeCalc && isDSTCalc(date) ? 1 : 0;

  Duration totalSeconds = Duration(seconds: (hourFraction * 3600).round());

  int hour = totalSeconds.inHours;
  int minute = totalSeconds.inMinutes.remainder(60);
  int second = totalSeconds.inSeconds.remainder(60);

  // rounding
  if (second > 30 && !showSeconds) minute++;
  if (minute == 60) minute = 0;

  return DateTime(date.year, date.month, date.day, hour, minute, second)
      .add(Duration(hours: dstAdjust));
}

/// Adds a leading zero to single-digit numbers for formatting.
///
/// [unit] - The number to format
/// Returns a string with leading zero if needed (e.g., "05" for 5)
String appendZero(int unit) {
  if (unit < 10) {
    return '0$unit';
  }
  return '$unit';
}

/// Converts an integer to a two-digit string with leading zero if needed.
///
/// [value] - The integer value to format
/// Returns a two-digit string representation
String toTwoDigitString(int value) {
  return value.toString().padLeft(2, '0');
}

/// Alternative DST check function (similar to isDSTCalc).
///
/// [d] - The date to check for DST
/// Returns true if the date is during DST
bool isDST(DateTime d) {
  var jul = DateTime(d.year, 6, 1).timeZoneOffset;
  return jul == d.timeZoneOffset;
}

/// Formats an integer as a two-digit string.
///
/// [n] - The number to format
/// Returns a string with leading zero if the number is less than 10
String twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}

/// Returns the start of the day (00:00:00) for a given DateTime.
///
/// [time] - The DateTime to get the start of day for
/// Returns a DateTime representing midnight of the same day
DateTime dayStart(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}

/// Returns the end of the day (23:59:59.999999) for a given DateTime.
///
/// [time] - The DateTime to get the end of day for
/// Returns a DateTime representing the last moment of the same day
DateTime dayEnd(DateTime time) {
  return DateTime(time.year, time.month, time.day)
      .add(const Duration(days: 1))
      .subtract(const Duration(microseconds: 1));
}

/// Formats a Duration as a time string (HH:MM or HH:MM:SS).
///
/// [duration] - The Duration to format
/// [adjust] - Optional seconds to add/subtract
/// [round] - If true, excludes seconds from output
/// Returns a formatted time string
String printDuration(Duration duration, {int adjust = 0, bool round = false}) {
  String twoDigitMinutes =
      twoDigits((duration + Duration(seconds: adjust)).inMinutes.remainder(60));
  String twoDigitSeconds =
      twoDigits((duration + Duration(seconds: adjust)).inSeconds.remainder(60));

  if (round)
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes';
  else
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
}

/// Alternative duration formatting with units (e.g., "2h 30m 15s").
///
/// [duration] - The Duration to format
/// [adjust] - Optional seconds to add/subtract
/// [round] - If true, excludes seconds from output
/// Returns a formatted duration string with units
String printDurationAlt(Duration duration,
    {int adjust = 0, bool round = false}) {
  String hrs = '${((duration + Duration(seconds: adjust)).inHours)}';
  String mins = ((duration + Duration(seconds: adjust)).inMinutes.remainder(60))
      .toString();
  String secs = ((duration + Duration(seconds: adjust)).inSeconds.remainder(60))
      .toString();
  if (hrs == '0')
    hrs = '0h';
  else
    hrs = '${hrs}h';

  if (round)
    return '$hrs ${mins}m';
  else
    return '$hrs ${mins}m ${secs}s';
}

/// Capitalizes the first letter of a string.
///
/// [s] - The string to capitalize
/// Returns the string with the first letter capitalized, or empty string if input is empty
String capitalise(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

/// Rounds a double value to a specified number of decimal places.
///
/// [value] - The double value to round
/// [decimals] - Number of decimal places to round to
/// Returns the rounded value as a double
double roundDecimals(double value, int decimals) =>
    double.parse(value.toStringAsFixed(decimals));

// ANSI color codes for terminal output formatting
/// Clears the terminal screen and moves cursor to top-left
String clear = '\x1B[2J\x1B[0;0H';

/// Yellow text color
String yellow = '\u001b[93m';

/// Reset to default color
String noColor = '\u001b[0m';

/// Green text color
String green = '\u001b[32m';

/// Red text color
String red = '\u001b[31m';

/// Gray text color
String gray = '\u001b[90m';
