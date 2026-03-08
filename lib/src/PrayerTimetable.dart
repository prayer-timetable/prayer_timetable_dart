/// Main PrayerTimetable implementation providing comprehensive Islamic prayer time management.
///
/// This file contains the core PrayerTimetable class and its various constructors
/// for different prayer time calculation methods.
library;

import 'dart:core';

import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:prayer_timetable/src/func/monthGen.dart';
import 'package:prayer_timetable/src/func/monthHijriGen.dart';
import 'package:prayer_timetable/src/func/prayers.dart';
import 'package:prayer_timetable/src/func/tzTime.dart';

// typedef Future<List<T>> PrayerTimetableOnFind<T>(String text);
// typedef String PrayerTimetableItemAsString<T>(T item);
// typedef bool PrayerTimetableFilterFn<T>(T item, String filter);
// typedef bool PrayerTimetableCompareFn<T>(T item1, T item2);

// typedef Future<bool?> BeforeChange<T>(T? prevItem, T? nextItem);
// typedef Future<bool?> BeforePopupOpening<T>(T? selectedItem);
// typedef Future<bool?> BeforePopupOpeningMultiSelection<T>(List<T> selItems);
// typedef Future<bool?> BeforeChangeMultiSelection<T>(
//   List<T> prevItems,
//   List<T> nextItems,
// );

// typedef void OnItemAdded<T>(List<T> selectedItems, T addedItem);
// typedef void OnItemRemoved<T>(List<T> selectedItems, T removedItem);

// ///[items] are the original item from [items] or/and [asyncItems]
// typedef List<T> FavoriteItems<T>(List<T> items);

// enum Mode { DIALOG, MODAL_BOTTOM_SHEET, MENU, BOTTOM_SHEET }
/// Default jamaah time offsets in hours and minutes for each prayer.
/// Index 0=Fajr, 1=Sunrise, 2=Dhuhr, 3=Asr, 4=Maghrib, 5=Isha
const List<List<int>> defaultJamaahOffsets = [
  [0, 0], // Fajr: no offset
  [0, 0], // Sunrise: no jamaah typically
  [0, 0], // Dhuhr: no offset
  [0, 0], // Asr: no offset
  [0, 0], // Maghrib: no offset
  [0, 0] // Isha: no offset
];

/// Default jamaah calculation methods for each prayer.
/// 'afterthis' means jamaah time is calculated as prayer time + offset
/// Empty string means no jamaah for that prayer
const List<String> defaultJamaahMethods = [
  'afterthis', // Fajr
  '', // Sunrise (no jamaah)
  'afterthis', // Dhuhr
  'afterthis', // Asr
  'afterthis', // Maghrib
  'afterthis' // Isha
];

/// Default setting to disable jamaah for all prayers
const List<bool> defaultJamaahPerPrayerOff = [
  false,
  false,
  false,
  false,
  false,
  false
];

/// Default setting to enable jamaah for all prayers
const List<bool> defaultJamaahPerPrayerOn = [
  true,
  true,
  true,
  true,
  true,
  true
];

/// Main class for Islamic prayer time management and calculations.
///
/// This class provides comprehensive prayer time functionality including:
/// - Multiple calculation methods (map-based, list-based, astronomical)
/// - Jamaah (congregation) time management
/// - Prayer time analysis and utilities
/// - Support for different timezones and locations
/// - Monthly prayer time generation
///
/// The class maintains prayer times for three days (previous, current, next)
/// and provides utilities for determining current prayer status, countdowns,
/// and other Islamic time-related calculations.
///
/// Example usage:
/// ```dart
/// // Using astronomical calculations
/// final timetable = PrayerTimetable.calc(
///   timetableCalc: TimetableCalc(...),
///   jamaahOn: true,
///   timezone: 'America/New_York',
/// );
///
/// // Access current prayer times
/// Prayer fajr = timetable.current[0];
/// print('Fajr: ${fajr.prayerTime}');
/// print('Next prayer in: ${timetable.utils.countDown}');
/// ```
class PrayerTimetable<T> {
  // Data sources (only one should be provided)
  /// Pre-calculated prayer times in map format
  Map? timetableMap;

  /// Pre-calculated prayer times in list format
  List? timetableList;

  /// Monthly differences for list-based calculations
  List? differences;

  /// Astronomical calculation parameters
  TimetableCalc? timetableCalc;

  // Prayer time arrays (6 prayers each: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
  /// Prayer times for the current day
  List<Prayer> current = List<Prayer>.filled(6, Prayer(), growable: false);

  /// Prayer times for the next day
  List<Prayer> next = List<Prayer>.filled(6, Prayer(), growable: false);

  /// Prayer times for the previous day
  List<Prayer> previous = List<Prayer>.filled(6, Prayer(), growable: false);

  /// The prayers currently in focus (current day or next day if after Isha)
  List<Prayer> focus = List<Prayer>.filled(6, Prayer(), growable: false);

  /// Utility class providing prayer analysis and additional calculations
  Utils utils;

  /// Prayer times for the current month
  // List<List<Prayer>>? monthPrayerTimes;

  /// Prayer times for the current hijri month
  // List<List<Prayer>>? monthHijriPrayerTimes;

// PrayerTimetableMap map;

  /// ***************************************************

  int? year;
  int? month;
  int? day;
  final int? hijriOffset;
  // bool summerTimeCalc = true,
  final String timezone;
  // true means we're using tz time
  bool? useTz;

  /// Enables jamaah times globaly.
  bool jamaahOn = false;

  /// Jammah times per individual prayers. Ignored if global jamaahOn is false.
  List<bool>? jamaahPerPrayer;

  List<String>? jamaahMethods;
  List<List<int>>? jamaahOffsets;
  // for testing:
  bool? testing;
  int? hour;
  int? minute;
  int? second;
  bool? joinMaghrib;
  bool? joinDhuhr;

  int? prayerLength;

  double? lat;
  double? lng;

/***************************************************** */

/***************************************************** */

  /// ***************************************************
  // factory PrayerTimetable(String name) {
  //   return PrayerTimetable.base();
  // }

  // static final PrayerTimetable base2 = PrayerTimetable.base();

  PrayerTimetable.base({
    this.timetableMap,
    this.timetableList,
    this.differences,
    this.timetableCalc,
    this.year,
    this.month,
    this.day,
    this.hijriOffset,
    // this.summerTimeCalc = true,

    /// Enables jamaah times globaly.
    required this.jamaahOn,
    this.joinMaghrib = false,
    this.joinDhuhr = false,
    this.prayerLength = 10,
    required this.timezone,
    this.useTz = true,

    /// Jammah times per individual prayers. Ignored if global jamaahOn is false.
    this.jamaahPerPrayer,
    this.jamaahMethods = defaultJamaahMethods,
    this.jamaahOffsets = defaultJamaahOffsets,
    this.hour,
    this.minute,
    this.second,
    this.lat,
    this.lng,
  })  : assert((jamaahOn) && (jamaahMethods != null && jamaahOffsets != null) ||
            (jamaahOn && jamaahPerPrayer != null) ||
            jamaahOn == false),
        assert(timetableCalc != null ||
            (lat != null && lng != null) ||
            timetableList != null ||
            timetableMap != null), //  && jamaahPerPrayer != null
        testing = false,
        utils = defaultUtils {
    /// ********************************************
    /// Define time
    /// ********************************************
    DateTime date = nowTZ(timezone,
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second);

    // print('${this.year}, ${this.month}, ${this.day}');
    // print(DateTime(this.year ?? date.year, this.month ?? date.month, (this.day ?? date.day) + 1,
    //     this.hour ?? 3, this.minute ?? 0, this.second ?? 0));
    bool localJamaahOn = jamaahOn;
    List<bool> localJamaahPerPrayer = !localJamaahOn
        ? defaultJamaahPerPrayerOff
        : jamaahPerPrayer ?? defaultJamaahPerPrayerOn;

    /// ********************************************
    /// Define prayer times
    /// ********************************************
    current = prayersGen(
      DateTime(year ?? date.year, month ?? date.month, day ?? date.day,
          hour ?? 3, minute ?? 0, second ?? 0),
      timetableMap: timetableMap,
      timetableList: timetableList,
      differences: differences,
      timetableCalc: timetableCalc?.copyWith(
          date: DateTime(year ?? date.year, month ?? date.month,
              (day ?? date.day), hour ?? 3, minute ?? 0, second ?? 0)),
      timezone: timezone,
      // useTz: useTz,
      hijriOffset: hijriOffset ?? 0,
      joinMaghrib: joinMaghrib ?? false,
      joinDhuhr: joinDhuhr ?? false,
      jamaahOn: jamaahOn,
      jamaahMethods: jamaahMethods ?? defaultJamaahMethods,
      jamaahOffsets: jamaahOffsets ?? defaultJamaahOffsets,
      jamaahPerPrayer: localJamaahPerPrayer,
      prayerLength: prayerLength,
    );

    next = prayersGen(
      DateTime(year ?? date.year, month ?? date.month, (day ?? date.day) + 1,
          hour ?? 3, minute ?? 0, second ?? 0),
      timetableMap: timetableMap,
      timetableList: timetableList,
      differences: differences,
      timetableCalc: timetableCalc?.copyWith(
          date: DateTime(year ?? date.year, month ?? date.month,
              (day ?? date.day) + 1, hour ?? 3, minute ?? 0, second ?? 0)),
      timezone: timezone,
      // useTz: useTz,
      hijriOffset: hijriOffset ?? 0,
      joinMaghrib: joinMaghrib ?? false,
      joinDhuhr: joinDhuhr ?? false,
      jamaahOn: jamaahOn,
      jamaahMethods: jamaahMethods ?? defaultJamaahMethods,
      jamaahOffsets: jamaahOffsets ?? defaultJamaahOffsets,
      jamaahPerPrayer: localJamaahPerPrayer,
      prayerLength: prayerLength,
    );
    previous = prayersGen(
      DateTime(year ?? date.year, month ?? date.month, (day ?? date.day) - 1,
          hour ?? 3, minute ?? 0, second ?? 0),
      timetableMap: timetableMap,
      timetableList: timetableList,
      differences: differences,
      timetableCalc: timetableCalc?.copyWith(
          date: DateTime(year ?? date.year, month ?? date.month,
              (day ?? date.day) - 1, hour ?? 3, minute ?? 0, second ?? 0)),
      timezone: timezone,
      // useTz: useTz,
      hijriOffset: hijriOffset ?? 0,
      joinMaghrib: joinMaghrib ?? false,
      joinDhuhr: joinDhuhr ?? false,
      jamaahOn: jamaahOn,
      jamaahMethods: jamaahMethods ?? defaultJamaahMethods,
      jamaahOffsets: jamaahOffsets ?? defaultJamaahOffsets,
      jamaahPerPrayer: localJamaahPerPrayer,
      prayerLength: prayerLength,
    );

    /// ********************************************
    /// Utils
    /// ********************************************
    utils = Utils(
      date,
      prayersCurrent: current,
      prayersNext: next,
      prayersPrevious: previous,
      jamaahOn: jamaahOn,
      lat: lat ?? lat ?? 0,
      lng: lng ?? lng ?? 0,
      jamaahPerPrayer: jamaahPerPrayer,
    );

    utils.utcOffsetHours = offsetHr(date, timezone);

    /// ********************************************
    /// Prayers in focus
    /// ********************************************
    focus = utils.isAfterIsha ? next : current;
    // to avoid next day isha adding few minutes and becoming next again
    if (utils.isAfterIsha) {
      focus.last.isNext = false;
      focus.first.isNext = true;
    }

    // else {
    //   for (Prayer prayer in this.focus) {
    //     prayer.isNext = this.utils.nextId == prayer.id && !prayer.isJamaahPending;
    //     prayer.isCurrent = this.utils.currentId == prayer.id;
    //   }
    // }

    // this.next.first.is

    /// ********************************************
    /// Month calendars
    /// ********************************************
    // this.monthPrayerTimes = monthGen(date, hijriOffset: hijriOffset ?? 0, timezone: this.timezone);
    // this.monthHijriPrayerTimes =
    //     monthHijriGen(date, hijriOffset: hijriOffset ?? 0, timezone: this.timezone);

    /// end
  }

  /// end PrayerTimetable base
/***************************************************** */

  // static monthTable({
  //   required String timezone,
  //   required int year,
  //   required int month,
  //   int hijriOffset = 0,
  //   Map? timetableMap,
  //   List? timetableList,
  //   List? differences,
  //   TimetableCalc? timetableCalc,
  //   List<String> jamaahMethods,
  //   List<List<int>> jamaahOffsets,
  //   bool jamaahOn = false,
  //   List<bool> jamaahPerPrayer,
  //   bool joinDhuhr = false,
  //   bool joinMaghrib = false,
  // }) =>
  //     monthGen(
  //       nowTZ(timezone, year: year, month: month, day: 15),
  //       hijriOffset: hijriOffset,
  //       timezone: timezone,
  //       timetable: timetableMap,
  //       list: timetableList,
  //       differences: differences,
  //       calc: timetableCalc,
  //       jamaahMethods: jamaahMethods ?? defaultJamaahMethods,
  //       jamaahOffsets: jamaahOffsets ?? defaultJamaahOffsets,
  //       jamaahOn: jamaahOn,
  //       jamaahPerPrayer: jamaahPerPrayer ?? defaultJamaahPerPrayerOff,
  //       joinDhuhr: joinDhuhr ?? false,
  //       joinMaghrib: joinMaghrib ?? false,
  //     );

  // PrayerTimetable.month({
  //   this.year,
  //   this.month,
  //   this.hijriOffset,
  //   required this.timezone,
  //   this.useTz = true,
  // })  : //  && jamaahPerPrayer != null
  //       this.testing = false,
  //       utils = defaultUtils {
  //   /// ********************************************
  //   /// Define time
  //   /// ********************************************
  //   DateTime date = nowTZ(timezone, year: year, month: month, day: 15);

  //   /// ********************************************
  //   /// Month calendars
  //   /// ********************************************

  //   // this.monthPrayerTimes = monthGen(
  //   //   date,
  //   //   hijriOffset: hijriOffset ?? 0,
  //   //   timezone: this.timezone,
  //   //   timetable: timetableMap,
  //   //   list: timetableList,
  //   //   differences: differences,
  //   //   calc: timetableCalc,
  //   //   jamaahMethods: jamaahMethods ?? defaultJamaahMethods,
  //   //   jamaahOffsets: jamaahOffsets ?? defaultJamaahOffsets,
  //   //   jamaahOn: jamaahOn,
  //   //   jamaahPerPrayer: jamaahPerPrayer ?? defaultJamaahPerPrayerOff,
  //   //   joinDhuhr: joinDhuhr ?? false,
  //   //   joinMaghrib: joinMaghrib ?? false,
  //   // );
  //   // this.monthHijriPrayerTimes = monthHijriGen(
  //   //   date,
  //   //   hijriOffset: hijriOffset ?? 0,
  //   //   timezone: this.timezone,
  //   //   timetable: timetableMap,
  //   //   list: timetableList,
  //   //   differences: differences,
  //   //   calc: timetableCalc,
  //   //   jamaahMethods: jamaahMethods ?? defaultJamaahMethods,
  //   //   jamaahOffsets: jamaahOffsets ?? defaultJamaahOffsets,
  //   //   jamaahOn: jamaahOn,
  //   //   jamaahPerPrayer: jamaahPerPrayer ?? defaultJamaahPerPrayerOff,
  //   //   joinDhuhr: joinDhuhr ?? false,
  //   //   joinMaghrib: joinMaghrib ?? false,
  //   // );

  //   /// end
  // }

  /// ********************************************
  /// Month calendars
  /// ********************************************
  static const monthTable = monthGen;
  static const monthHijriTable = monthHijriGen;

  /// end PrayerTimetable month
  /// ***************************************************

  PrayerTimetable.map({
    required Map timetableMap,
    int? year,
    int? month,
    int? day,
    int? hijriOffset,

    /// Enables jamaah times globaly.
    required bool jamaahOn,
    bool joinMaghrib = false,
    bool joinDhuhr = false,
    int prayerLength = 10,
    required String timezone,
    bool useTz = true,

    /// Jammah times per individual prayers. Ignored if global jamaahOn is false.
    List<bool>? jamaahPerPrayer,
    List<String>? jamaahMethods,
    List<List<int>>? jamaahOffsets,
    int? hour,
    int? minute,
    int? second,
    double? lat,
    double? lng,
  }) : this.base(
          timetableMap: timetableMap,
          year: year,
          month: month,
          day: day,
          hijriOffset: hijriOffset,
          jamaahOn: jamaahOn,
          joinMaghrib: joinMaghrib,
          joinDhuhr: joinDhuhr,
          prayerLength: prayerLength,
          timezone: timezone,
          useTz: useTz,
          jamaahPerPrayer: jamaahPerPrayer,
          jamaahMethods: jamaahMethods,
          jamaahOffsets: jamaahOffsets,
          hour: hour,
          minute: minute,
          second: second,
          lat: lat,
          lng: lng,
        );

  /// end PrayerTimetable.map

  PrayerTimetable.list({
    required List timetableList,
    List differences = const [
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0]
    ],
    int? year,
    int? month,
    int? day,
    int? hijriOffset,

    /// Enables jamaah times globaly.
    bool jamaahOn = false,
    bool joinMaghrib = false,
    bool joinDhuhr = false,
    int prayerLength = 10,
    required String timezone,
    bool useTz = true,

    /// Jammah times per individual prayers. Ignored if global jamaahOn is false.
    List<bool>? jamaahPerPrayer,
    List<String>? jamaahMethods,
    List<List<int>>? jamaahOffsets,
    int? hour,
    int? minute,
    int? second,
    double? lat,
    double? lng,
  }) : this.base(
          timetableList: timetableList,
          differences: differences,
          year: year,
          month: month,
          day: day,
          hijriOffset: hijriOffset,
          jamaahOn: jamaahOn,
          joinMaghrib: joinMaghrib,
          joinDhuhr: joinDhuhr,
          prayerLength: prayerLength,
          timezone: timezone,
          useTz: useTz,
          jamaahPerPrayer: jamaahPerPrayer,
          jamaahMethods: jamaahMethods,
          jamaahOffsets: jamaahOffsets,
          hour: hour,
          minute: minute,
          second: second,
          lat: lat,
          lng: lng,
        );

  /// end PrayerTimetable.list

  ///
  PrayerTimetable.calc({
    required TimetableCalc timetableCalc,
    int? year,
    int? month,
    int? day,
    int? hijriOffset,

    /// Enables jamaah times globaly.
    bool jamaahOn = false,
    bool joinMaghrib = false,
    bool joinDhuhr = false,
    int prayerLength = 10,
    required String timezone,
    bool useTz = true,

    /// Jammah times per individual prayers. Ignored if global jamaahOn is false.
    List<bool>? jamaahPerPrayer,
    List<String>? jamaahMethods,
    List<List<int>>? jamaahOffsets,
    int? hour,
    int? minute,
    int? second,
  }) : this.base(
          timetableCalc: timetableCalc,
          year: year,
          month: month,
          day: day,
          hijriOffset: hijriOffset,
          jamaahOn: jamaahOn,
          joinMaghrib: joinMaghrib,
          joinDhuhr: joinDhuhr,
          prayerLength: prayerLength,
          timezone: timezone,
          useTz: useTz,
          jamaahPerPrayer: jamaahPerPrayer,
          jamaahMethods: jamaahMethods,
          jamaahOffsets: jamaahOffsets,
          hour: hour,
          minute: minute,
          second: second,
        );

  /// end PrayerTimetable.list
}

// PrayerTimetable.map(Map timetable);
// }
