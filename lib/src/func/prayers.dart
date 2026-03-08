/// Core prayer time generation and calculation functions.
///
/// This file contains the main logic for generating individual prayer times
/// using various data sources (maps, lists, or astronomical calculations).
/// It handles timezone conversions, DST adjustments, jamaah times, and
/// prayer joining functionality.
library;

import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:timezone/timezone.dart' as tz;

/// Names of the six prayer/time periods in order
List<String> prayerNames = [
  'fajr',
  'sunrise',
  'dhuhr',
  'asr',
  'maghrib',
  'isha'
];

/// Generates prayer times for a single day using the specified calculation method.
///
/// This is the core function that calculates prayer times for a given date using
/// one of three possible data sources: timetableMap, timetableList, or timetableCalc.
/// It handles timezone conversions, DST adjustments, jamaah times, and various
/// Islamic prayer time rules.
///
/// [date] - The date to calculate prayer times for
/// [timetableMap] - Optional pre-calculated prayer times in map format
/// [timetableList] - Optional pre-calculated prayer times in list format
/// [differences] - Optional monthly differences for list-based calculations
/// [timetableCalc] - Optional astronomical calculation parameters
/// [hijriOffset] - Days to offset for Hijri calendar alignment
/// [timezone] - Timezone identifier for accurate time calculations
/// [jamaahOn] - Whether to enable jamaah (congregation) times
/// [jamaahMethods] - Methods for calculating jamaah times ('afterthis', 'fixed', etc.)
/// [jamaahOffsets] - Time offsets for jamaah times in [hours, minutes] format
/// [joinDhuhr] - Whether to join Dhuhr and Asr prayers
/// [joinMaghrib] - Whether to join Maghrib and Isha prayers
/// [jamaahPerPrayer] - Boolean array indicating which prayers have jamaah
/// [prayerLength] - Duration in minutes between joined prayers
///
/// Returns a list of 6 Prayer objects representing the daily prayer times
List<Prayer> prayersGen(
  DateTime date, {
  Map? timetableMap,
  List? timetableList,
  List? differences,
  TimetableCalc? timetableCalc,
  required int hijriOffset,
  required String timezone,
  required bool jamaahOn,
  required List<String> jamaahMethods,
  required List<List<int>> jamaahOffsets,
  required bool joinDhuhr,
  required bool joinMaghrib,
  required List<bool> jamaahPerPrayer,
  int? prayerLength = 10,
}) {
  // Get timezone location for accurate time calculations
  tz.Location tzGet = tz.getLocation(timezone);

  // Adjust date by Hijri offset for calendar alignment
  DateTime adjustedDate = date.add(Duration(days: hijriOffset));
  tz.TZDateTime timestamp = tz.TZDateTime(
      tzGet,
      adjustedDate.year,
      adjustedDate.month,
      adjustedDate.day,
      adjustedDate.hour,
      adjustedDate.minute,
      adjustedDate.second);

  // Calculate day boundaries for prayer time calculations
  DateTime dayBegin =
      tz.TZDateTime(tzGet, timestamp.year, timestamp.month, timestamp.day)
          .add(Duration(days: hijriOffset));
  DateTime dayEnd =
      tz.TZDateTime(tzGet, timestamp.year, timestamp.month, timestamp.day + 1)
          .add(Duration(days: hijriOffset));

  // DST adjustment: add 1 hour if daylight saving time is active
  int adjDst = timestamp.timeZone.isDst ? 1 : 0;

  List<Prayer> prayers = [];
  List prayerCount = Iterable<int>.generate(6).toList();

  // Generate prayer times for each of the 6 prayers/periods
  for (var prayerId in prayerCount) {
    Prayer prayer = Prayer();
    DateTime prayerTime = DateTime.now();
    DateTime prayerEndTime = DateTime.now();

    // Calculate prayer times based on data source: map, list, or calculation
    if (timetableMap != null) {
      // Use pre-calculated map data with DST adjustment
      prayerTime = tz.TZDateTime(
        tzGet,
        timestamp.year,
        timestamp.month,
        timestamp.day,
        timetableMap[timestamp.month.toString()][timestamp.day.toString()]
            [prayerId][0],
        timetableMap[timestamp.month.toString()][timestamp.day.toString()]
            [prayerId][1],
      ).add(Duration(hours: adjDst));

      prayerEndTime = prayerId == 5
          ? dayEnd
          : tz.TZDateTime(
              tzGet,
              timestamp.year,
              timestamp.month,
              timestamp.day,
              timetableMap[timestamp.month.toString()][timestamp.day.toString()]
                  [prayerId + 1][0],
              timetableMap[timestamp.month.toString()][timestamp.day.toString()]
                  [prayerId + 1][1],
            ).add(Duration(hours: adjDst));
    } else if (timetableList != null) {
      // Use list-based data with seconds from midnight
      prayerTime = dayEnd
          .add(Duration(
              hours: -24 + adjDst,
              seconds: timetableList[timestamp.month - 1][timestamp.day - 1]
                  [prayerId]))
          .add(Duration(
              seconds: differences != null
                  ? differences[timestamp.month - 1][prayerId]
                  : 0));

      prayerEndTime = prayerId == 5
          ? dayEnd
          : dayEnd
              .add(Duration(
                  hours: -24 + adjDst,
                  seconds: timetableList[timestamp.month - 1][timestamp.day - 1]
                      [prayerId + 1]))
              .add(Duration(
                  seconds: differences != null
                      ? differences[timestamp.month - 1][prayerId + 1]
                      : 0));
    } else if (timetableCalc != null) {
      // Use astronomical calculations for prayer times
      DateTime fajrTime = tz.TZDateTime(
          tzGet,
          timetableCalc.prayerTimes.fajr.year,
          timetableCalc.prayerTimes.fajr.month,
          timetableCalc.prayerTimes.fajr.day,
          timetableCalc.prayerTimes.fajr.hour,
          timetableCalc.prayerTimes.fajr.minute,
          timetableCalc.prayerTimes.fajr.second);
      DateTime sunriseTime = tz.TZDateTime(
          tzGet,
          timetableCalc.prayerTimes.sunrise.year,
          timetableCalc.prayerTimes.sunrise.month,
          timetableCalc.prayerTimes.sunrise.day,
          timetableCalc.prayerTimes.sunrise.hour,
          timetableCalc.prayerTimes.sunrise.minute,
          timetableCalc.prayerTimes.sunrise.second);
      DateTime dhuhrTime = tz.TZDateTime(
          tzGet,
          timetableCalc.prayerTimes.dhuhr.year,
          timetableCalc.prayerTimes.dhuhr.month,
          timetableCalc.prayerTimes.dhuhr.day,
          timetableCalc.prayerTimes.dhuhr.hour,
          timetableCalc.prayerTimes.dhuhr.minute,
          timetableCalc.prayerTimes.dhuhr.second);
      DateTime asrTime = tz.TZDateTime(
          tzGet,
          timetableCalc.prayerTimes.asr.year,
          timetableCalc.prayerTimes.asr.month,
          timetableCalc.prayerTimes.asr.day,
          timetableCalc.prayerTimes.asr.hour,
          timetableCalc.prayerTimes.asr.minute,
          timetableCalc.prayerTimes.asr.second);
      DateTime maghribTime = tz.TZDateTime(
          tzGet,
          timetableCalc.prayerTimes.maghrib.year,
          timetableCalc.prayerTimes.maghrib.month,
          timetableCalc.prayerTimes.maghrib.day,
          timetableCalc.prayerTimes.maghrib.hour,
          timetableCalc.prayerTimes.maghrib.minute,
          timetableCalc.prayerTimes.maghrib.second);
      DateTime ishaTime = tz.TZDateTime(
          tzGet,
          timetableCalc.prayerTimes.isha.year,
          timetableCalc.prayerTimes.isha.month,
          timetableCalc.prayerTimes.isha.day,
          timetableCalc.prayerTimes.isha.hour,
          timetableCalc.prayerTimes.isha.minute,
          timetableCalc.prayerTimes.isha.second);

      if (prayerId == 0) {
        prayerTime = fajrTime;
        prayerEndTime = sunriseTime;
      } else if (prayerId == 1) {
        prayerTime = sunriseTime;
        prayerEndTime = dhuhrTime;
      } else if (prayerId == 2) {
        prayerTime = dhuhrTime;
        prayerEndTime = asrTime;
      } else if (prayerId == 3) {
        prayerTime = asrTime;
        prayerEndTime = maghribTime;
      } else if (prayerId == 4) {
        prayerTime = maghribTime;
        prayerEndTime = ishaTime;
      } else if (prayerId == 5) {
        prayerTime = ishaTime;
        prayerEndTime = dayEnd;
      }
    }

    // Set basic prayer properties
    prayer.id = prayerId;
    prayer.name = prayerNames[prayerId];
    prayer.prayerTime = prayerTime;
    prayer.endTime = prayerEndTime;

    // Calculate jamaah (congregation) times based on method and offsets
    int jamaahOffsetMin =
        jamaahOffsets[prayerId][0] * 60 + jamaahOffsets[prayerId][1];

    if (!jamaahPerPrayer[prayerId]) {
      // No jamaah for this prayer
      prayer.jamaahTime = prayerTime;
    } else if (jamaahMethods[prayerId] == 'afterthis') {
      // Jamaah time is offset from prayer time
      prayer.jamaahTime = prayerTime.add(Duration(minutes: jamaahOffsetMin));
    } else if (jamaahMethods[prayerId] == 'fixed') {
      // Fixed jamaah time regardless of prayer time
      prayer.jamaahTime = tz.TZDateTime(
          tzGet,
          prayerTime.year,
          prayerTime.month,
          prayerTime.day,
          jamaahOffsets[prayerId][0],
          jamaahOffsets[prayerId][1]);
    } else {
      prayer.jamaahTime = prayerTime;
    }

    // Ensure jamaah time is not before prayer time
    if (prayer.jamaahTime.isBefore(prayer.prayerTime))
      prayer.prayerTime = prayer.jamaahTime;
    // Handle prayer joining (combining prayers)
    if (joinMaghrib && prayerId == 5) {
      // Join Isha with Maghrib
      prayer.prayerTime =
          prayers[4].jamaahTime.add(Duration(minutes: prayerLength ?? 10));
      prayer.jamaahTime =
          prayers[4].jamaahTime.add(Duration(minutes: prayerLength ?? 10));
    }
    if (joinDhuhr && prayerId == 3) {
      // Join Asr with Dhuhr
      prayer.prayerTime =
          prayers[2].jamaahTime.add(Duration(minutes: prayerLength ?? 10));
      prayer.jamaahTime =
          prayers[2].jamaahTime.add(Duration(minutes: prayerLength ?? 10));
    }

    // Set jamaah pending status
    if (jamaahOn) {
      prayer.isJamaahPending = timestamp.isAfter(prayer.prayerTime) &&
          timestamp.isBefore(prayer.jamaahTime);
    }

    prayer.isNext = false;
    // Determine if this prayer is currently active
    if (prayerId == 5 &&
        timestamp.isAfter(dayBegin) &&
        (timestamp.isBefore(prayers[0].prayerTime) ||
            timestamp.isAtSameMomentAs(prayers[0].prayerTime))) {
      prayer.isCurrent = true; // Isha is current if before Fajr
    }
    if ((timestamp.isAfter(prayerTime) && timestamp.isBefore(prayerEndTime)) ||
        prayer.isJamaahPending ||
        timestamp.isAtSameMomentAs(prayerEndTime)) {
      prayer.isCurrent = true;
    }

    prayers.insert(prayerId, prayer);
  }

  // Determine which prayer is next based on current prayer status
  for (Prayer prayer in prayers) {
    int nextId = prayer.id != 5 ? prayer.id + 1 : 0;
    if ((prayer.isCurrent && !prayer.isJamaahPending) ||
        prayers[nextId].isJamaahPending) {
      prayers[nextId].isNext = true;
    }
  }

  return prayers;
}
