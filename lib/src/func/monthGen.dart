/// Monthly prayer time generation for Gregorian calendar.
///
/// This file contains functions for generating complete monthly prayer timetables
/// using various calculation methods (map-based, list-based, or astronomical).
library;

import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:prayer_timetable/src/func/helpers.dart';
import 'package:prayer_timetable/src/func/prayers.dart';
import 'package:timezone/timezone.dart' as tz;

/// Generates prayer times for an entire Gregorian month.
///
/// This function creates a complete monthly prayer timetable by calculating
/// prayer times for each day of the specified month using the provided
/// calculation method and parameters.
///
/// [year] - The year (e.g., 2024)
/// [month] - The month (1-12)
/// [timetable] - Optional map-based timetable data
/// [list] - Optional list-based timetable data
/// [differences] - Optional monthly differences for list-based calculations
/// [calc] - Optional astronomical calculation parameters
/// [hijriOffset] - Days to offset for Hijri calendar alignment
/// [timezone] - Timezone identifier (e.g., 'America/New_York')
/// [jamaahOn] - Whether to enable jamaah times
/// [jamaahMethods] - Methods for calculating jamaah times
/// [jamaahOffsets] - Time offsets for jamaah times
/// [joinDhuhr] - Whether to join Dhuhr and Asr prayers
/// [joinMaghrib] - Whether to join Maghrib and Isha prayers
/// [jamaahPerPrayer] - Which prayers have jamaah enabled
/// [prayerLength] - Duration in minutes for joined prayers
///
/// Returns a list of daily prayer lists for the entire month
List<List<Prayer>> monthGen(
  int year,
  int month, {
  Map<dynamic, dynamic>? timetable,
  List? list,
  List? differences,
  TimetableCalc? calc,
  int hijriOffset = 0,
  required String timezone,
  bool jamaahOn = false,
  List<String> jamaahMethods = defaultJamaahMethods,
  List<List<int>> jamaahOffsets = defaultJamaahOffsets,
  bool joinDhuhr = false,
  bool joinMaghrib = false,
  List<bool> jamaahPerPrayer = defaultJamaahPerPrayerOff,
  // bool useTz = false,
  int prayerLength = 10,
}) {
  /// Date
  DateTime date = tz.TZDateTime(
    tz.getLocation(timezone),
    year,
    month,
    1,
    3,
    0,
    0,
  ); // making sure it is after 1 am for time change

  // int daysInYear = date.year % 4 == 0 ? 366 : 365;
  int daysInMonth = DateTime.utc(date.year, date.month + 1, 0).day;

  // print(daysInYear);
  // print(daysInMonth);
  // print(date);

  // var days = [for (var i = 1; i <= daysInMonth; i++) i];

  // print(days);

  List<List<Prayer>> prayerList = List.generate(daysInMonth, (index) {
    // Step calendar days, so a 23- or 25-hour day keeps the month on track.
    final dayDate = dateByAddingDays(date, index);
    return prayersGen(
      dayDate,
      timetableMap: timetable,
      timetableList: list,
      differences: differences,
      timetableCalc: calc?.copyWith(date: dayDate),
      timezone: timezone,
      hijriOffset: hijriOffset,
      jamaahOn: jamaahOn,
      jamaahMethods: jamaahMethods,
      jamaahOffsets: jamaahOffsets,
      joinDhuhr: joinDhuhr,
      joinMaghrib: joinMaghrib,
      jamaahPerPrayer: jamaahPerPrayer,
      prayerLength: prayerLength,
      // useTz: useTz,
    );
  });

  // print(list[0].afternoon);

  return prayerList;
}
