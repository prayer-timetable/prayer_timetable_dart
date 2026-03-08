import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:prayer_timetable/src/components/Prayer.dart';
import 'package:prayer_timetable/src/func/helpers.dart';
// ignore: unused_import
import 'package:timezone/timezone.dart' as tz;

// import 'package:adhan_dart/adhan_dart.dart';

/// Utility class providing prayer time analysis and additional Islamic calculations.
///
/// This class analyzes the current time in relation to prayer times and provides
/// useful information such as:
/// - Which prayer is currently active
/// - Which prayer is next
/// - Countdown to next prayer
/// - Prayer completion percentage
/// - Qibla direction
/// - Hijri date information
/// - Sunnah times (midnight, last third of night)
///
/// The class handles both regular prayer times and jamaah (congregation) times,
/// providing accurate status information for mosque applications.
///
/// Example usage:
/// ```dart
/// final utils = Utils(
///   DateTime.now(),
///   prayersCurrent: currentPrayers,
///   prayersNext: nextPrayers,
///   prayersPrevious: previousPrayers,
///   jamaahOn: true,
///   lat: 40.7128,
///   lng: -74.0060,
/// );
///
/// print('Current prayer: ${utils.currentId}');
/// print('Time until next prayer: ${utils.countDown}');
/// print('Qibla direction: ${utils.qibla}°');
/// ```
class Utils {
  /// The current time being analyzed
  DateTime time = DateTime.now();

  /// Prayer times relative to the current time
  /// The currently active prayer time
  DateTime current = DateTime.now();

  /// The next upcoming prayer time
  DateTime next = DateTime.now();

  /// The most recent past prayer time
  DateTime previous = DateTime.now();

  /// Prayer identification and status
  /// ID of the currently active prayer (0-5)
  int currentId = 1;

  /// ID of the previous prayer (0-5)
  int previousId = 0;

  /// ID of the next prayer (0-5)
  int nextId = 2;

  /// Whether jamaah time is pending for current prayer
  bool isJamaahPending = false;

  /// Whether current time is after Isha prayer (affects next day calculations)
  bool isAfterIsha = false;

  /// Sunnah (recommended) prayer times
  /// Islamic midnight (halfway between sunset and dawn)
  DateTime midnight = DateTime.now();

  /// Last third of the night (recommended time for Tahajjud prayer)
  DateTime lastThird = DateTime.now();

  /// Time calculations
  /// Duration until the next prayer
  Duration countDown = Duration.zero;

  /// Duration since the current prayer started
  Duration countUp = Duration(seconds: 10);

  /// Percentage of current prayer period completed (0-100)
  double percentage = 0.1;

  /// Qibla direction in degrees from North (0-360)
  double qibla = 0;

  /// Calendar information
  /// Hijri date as a list containing year, month, and day
  List<int> hijri = [];

  /// Whether the current Gregorian year is a leap year
  bool isLeap = false;

  /// UTC offset in hours for the current timezone
  int? utcOffsetHours;

  /// Creates a Utils instance with comprehensive prayer time analysis.
  ///
  /// [inputDate] - The current date/time to analyze
  /// [prayersCurrent] - List of 6 prayers for the current day
  /// [prayersNext] - List of 6 prayers for the next day
  /// [prayersPrevious] - List of 6 prayers for the previous day
  /// [jamaahOn] - Whether jamaah times are enabled
  /// [lat] - Latitude for Qibla calculation
  /// [lng] - Longitude for Qibla calculation
  /// [jamaahPerPrayer] - Which prayers have jamaah enabled (6 booleans)
  /// [utcOffsetHours] - UTC offset in hours for timezone
  Utils(
    DateTime inputDate, {
    required List<Prayer> prayersCurrent,
    required List<Prayer> prayersNext,
    required List<Prayer> prayersPrevious,
    bool? jamaahOn,
    double lat = 0.0,
    double lng = 0.0,
    List<bool>? jamaahPerPrayer,
    int? utcOffsetHours,
  }) {
    DateTime tempCurrent = current;
    DateTime tempNext = next;
    DateTime tempPrevious = previous;
    int tempCurrentId = currentId;
    int tempPreviousId = previousId;
    int tempNextId = nextId;
    bool tempIsAfterIsha = false;

    // time is local for PrayerTimetable and PrayerTimetableAlt
    // utc for PrayerTimetable
    /* *********************** */
    /* _current, _previous, _next */
    /* *********************** */

    /// NO JAMAAH
    if (jamaahOn != null && !jamaahOn) {
      // midnight - fajr
      if (inputDate.isBefore(prayersCurrent[0].prayerTime)) {
        tempPrevious = prayersPrevious[4].prayerTime;
        tempCurrent = prayersPrevious[5].prayerTime;
        tempNext = prayersCurrent[0].prayerTime;
        tempCurrentId = 5;
      }
      // fajr - sunrise
      else if (inputDate.isBefore(prayersCurrent[1].prayerTime)) {
        tempPrevious = prayersPrevious[5].prayerTime;
        tempCurrent = prayersCurrent[0].prayerTime;
        tempNext = prayersCurrent[1].prayerTime;
        tempCurrentId = 0;
      }
      // sunrise - dhuhr
      else if (inputDate.isBefore(prayersCurrent[2].prayerTime)) {
        tempPrevious = prayersCurrent[0].prayerTime;
        tempCurrent = prayersCurrent[1].prayerTime;
        tempNext = prayersCurrent[2].prayerTime;
        tempCurrentId = 1;
      }
      // dhuhr - asr
      else if (inputDate.isBefore(prayersCurrent[3].prayerTime)) {
        tempPrevious = prayersCurrent[1].prayerTime;
        tempCurrent = prayersCurrent[2].prayerTime;
        tempNext = prayersCurrent[3].prayerTime;
        tempCurrentId = 2;
      }
      // asr - maghrib
      else if (inputDate.isBefore(prayersCurrent[4].prayerTime)) {
        tempPrevious = prayersCurrent[2].prayerTime;
        tempCurrent = prayersCurrent[3].prayerTime;
        tempNext = prayersCurrent[4].prayerTime;
        tempCurrentId = 3;
      }
      // maghrib - isha
      else if (inputDate.isBefore(prayersCurrent[5].prayerTime)) {
        tempPrevious = prayersCurrent[3].prayerTime;
        tempCurrent = prayersCurrent[4].prayerTime;
        tempNext = prayersCurrent[5].prayerTime;
        tempCurrentId = 4;
      } else {
        // isha till midnight
        tempPrevious = prayersCurrent[4].prayerTime;
        tempCurrent = prayersCurrent[5].prayerTime;
        tempNext = prayersNext[0].prayerTime;
        tempCurrentId = 5;
        tempIsAfterIsha = true;
      }
    }

    // JAMAAH
    bool tempJamaahPending = false;

    if (jamaahOn != null && jamaahOn) {
      jamaahPerPrayer ??= const [true, true, true, true, true, true];

      // midnight - fajr
      if (inputDate.isBefore(prayersCurrent[0].prayerTime)) {
        tempPrevious = prayersPrevious[4].prayerTime;
        tempCurrent = jamaahPerPrayer[5]
            ? prayersPrevious[5].jamaahTime
            : prayersPrevious[5].prayerTime;
        tempNext = prayersCurrent[0].prayerTime;
        tempCurrentId = 5;
      }
      // fajr - fajr jamaah
      else if (inputDate.isBefore(prayersCurrent[0].jamaahTime)) {
        tempPrevious = prayersPrevious[5].prayerTime;
        tempCurrent = prayersCurrent[0].prayerTime;
        tempNext = jamaahPerPrayer[0]
            ? prayersCurrent[0].jamaahTime
            : prayersCurrent[1].prayerTime;
        tempCurrentId = 0;
        tempJamaahPending = jamaahPerPrayer[0];
      }
      // fajr jammah - sunrise
      else if (inputDate.isBefore(prayersCurrent[1].prayerTime)) {
        tempPrevious = prayersPrevious[5].prayerTime;
        tempCurrent = jamaahPerPrayer[0]
            ? prayersCurrent[0].jamaahTime
            : prayersCurrent[0].prayerTime;
        tempNext = prayersCurrent[1].prayerTime;
        tempCurrentId = 0;
      }
      // sunrise - dhuhr
      else if (inputDate.isBefore(prayersCurrent[2].prayerTime)) {
        tempPrevious = prayersCurrent[0].prayerTime;
        tempCurrent = prayersCurrent[1].prayerTime;
        tempNext = prayersCurrent[2].prayerTime;
        tempCurrentId = 1;
      }
      // dhuhr - dhuhr jamaah
      else if (inputDate.isBefore(prayersCurrent[2].jamaahTime)) {
        tempPrevious = prayersCurrent[1].prayerTime;
        tempCurrent = prayersCurrent[2].prayerTime;
        tempNext = jamaahPerPrayer[2]
            ? prayersCurrent[2].jamaahTime
            : prayersCurrent[3].prayerTime;
        tempCurrentId = 2;
        tempJamaahPending = jamaahPerPrayer[2];
      }
      // dhuhr jamaah - asr
      else if (inputDate.isBefore(prayersCurrent[3].prayerTime)) {
        tempPrevious = prayersCurrent[1].prayerTime;
        tempCurrent = jamaahPerPrayer[2]
            ? prayersCurrent[2].jamaahTime
            : prayersCurrent[2].prayerTime;
        tempNext = prayersCurrent[3].prayerTime;
        tempCurrentId = 2;
      }
      // asr - asr jamaah
      else if (inputDate.isBefore(prayersCurrent[3].jamaahTime)) {
        tempPrevious = prayersCurrent[2].prayerTime;
        tempCurrent = prayersCurrent[3].prayerTime;
        tempNext = jamaahPerPrayer[3]
            ? prayersCurrent[3].jamaahTime
            : prayersCurrent[4].prayerTime;
        tempCurrentId = 3;
        tempJamaahPending = jamaahPerPrayer[3];
      }
      // asr jamaah - maghrib
      else if (inputDate.isBefore(prayersCurrent[4].prayerTime)) {
        tempPrevious = prayersCurrent[2].prayerTime;
        tempCurrent = jamaahPerPrayer[3]
            ? prayersCurrent[3].jamaahTime
            : prayersCurrent[3].prayerTime;
        tempNext = prayersCurrent[4].prayerTime;
        tempCurrentId = 3;
      }
      // maghrib - maghrib jamaah
      else if (inputDate.isBefore(prayersCurrent[4].jamaahTime)) {
        tempPrevious = prayersCurrent[3].prayerTime;
        tempCurrent = prayersCurrent[4].prayerTime;
        tempNext = jamaahPerPrayer[4]
            ? prayersCurrent[4].jamaahTime
            : prayersCurrent[5].prayerTime;
        tempCurrentId = 4;
        tempJamaahPending = jamaahPerPrayer[4];
      }
      // maghrib jamaah - isha
      else if (inputDate.isBefore(prayersCurrent[5].prayerTime)) {
        tempPrevious = prayersCurrent[3].prayerTime;
        tempCurrent = jamaahPerPrayer[4]
            ? prayersCurrent[4].jamaahTime
            : prayersCurrent[4].prayerTime;
        tempNext = prayersCurrent[5].prayerTime;
        tempCurrentId = 4;
      }
      // isha - isha jamaah
      else if (inputDate.isBefore(prayersCurrent[5].jamaahTime)) {
        tempPrevious = prayersCurrent[4].prayerTime;
        tempCurrent = prayersCurrent[5].prayerTime;
        tempNext = jamaahPerPrayer[5]
            ? prayersCurrent[5].jamaahTime
            : prayersNext[0].prayerTime;
        tempCurrentId = 5;
        tempJamaahPending = jamaahPerPrayer[5];
      }
      // isha jamaah - midnight
      else {
        tempPrevious = prayersCurrent[4].prayerTime;
        tempCurrent = jamaahPerPrayer[5]
            ? prayersCurrent[5].prayerTime
            : prayersCurrent[5].prayerTime;
        tempNext = prayersNext[0].prayerTime;
        tempCurrentId = 5;
        tempIsAfterIsha = true;
      }
    }

    tempNextId = tempCurrentId == 5 ? 0 : tempCurrentId + 1;
    tempPreviousId = tempCurrentId == 0 ? 5 : tempCurrentId - 1;

    /// Sunnah
    DateTime dawnTomorrow = prayersNext[0].prayerTime;
    DateTime dawnToday = prayersCurrent[0].prayerTime;
    DateTime sunsetToday = prayersCurrent[4].prayerTime;
    DateTime sunsetYesterday = prayersPrevious[4].prayerTime;
    midnight = time.isBefore(dawnToday)
        ? sunsetYesterday.add(Duration(
            minutes:
                (dawnToday.difference(sunsetYesterday).inMinutes / 2).floor()))
        : sunsetToday.add(Duration(
            minutes:
                (dawnTomorrow.difference(sunsetToday).inMinutes / 2).floor()));

    lastThird = time.isBefore(dawnToday)
        ? sunsetYesterday.add(Duration(
            minutes: (2 * dawnToday.difference(sunsetYesterday).inMinutes / 3)
                .floor()))
        : sunsetToday.add(Duration(
            minutes: (2 * dawnTomorrow.difference(sunsetToday).inMinutes / 3)
                .floor()));

    // components
    time = inputDate;
    current = tempCurrent;
    next = tempNext;
    previous = tempPrevious;

    currentId = tempCurrentId;
    nextId = tempNextId;
    previousId = tempPreviousId;
    isAfterIsha = tempIsAfterIsha;
    isJamaahPending = tempJamaahPending;

    countDown = tempNext.difference(inputDate);
    countUp = inputDate.difference(tempCurrent);

    percentage = round2Decimals(
        100 * (countUp.inSeconds / (countDown + countUp).inSeconds));

    percentage = percentage.isNaN ? 0 : percentage;

    // print(lat);
    qibla = adhan.Qibla.qibla(adhan.Coordinates(lat, lng));

    var hTime = HijriCalendar.fromDate(inputDate);
    hijri = [hTime.hYear, hTime.hMonth, hTime.hDay];
    isLeap = inputDate.year % 4 == 0;

    //end
  }

  // HIJRI CALENDAR CONVERSION STATIC METHODS

  /// Converts a specific Hijri date to Gregorian date.
  ///
  /// This function converts a complete Hijri date with year, month, and day to its
  /// corresponding Gregorian date using the Islamic calendar system.
  ///
  /// [hijriYear] - The Hijri year (e.g., 1446)
  /// [hijriMonth] - The Hijri month (1-12)
  /// [hijriDay] - The Hijri day (1-30)
  /// Returns a DateTime object representing the Gregorian date
  ///
  /// Example:
  /// ```dart
  /// DateTime gregorianDate = Utils.hijriToGregorian(1446, 9, 26);
  /// // Returns: 2025-03-26
  /// ```
  static DateTime hijriToGregorian(
      int hijriYear, int hijriMonth, int hijriDay) {
    var hDate = HijriCalendar.now();
    return hDate.hijriToGregorian(hijriYear, hijriMonth, hijriDay);
  }

  /// Converts a Gregorian date to Hijri date.
  ///
  /// This function converts a Gregorian DateTime to its corresponding
  /// Hijri date representation.
  ///
  /// [gregorianDate] - The Gregorian DateTime to convert
  /// Returns a HijriCalendar object representing the Hijri date
  ///
  /// Example:
  /// ```dart
  /// HijriCalendar hijriDate = Utils.gregorianToHijri(DateTime(2025, 3, 26));
  /// // Returns: 1446-09-26
  /// ```
  static HijriCalendar gregorianToHijri(DateTime gregorianDate) {
    return HijriCalendar.fromDate(gregorianDate);
  }

  /// Gets the first day of a Hijri month in Gregorian calendar.
  ///
  /// This function returns the Gregorian date that corresponds to the
  /// first day of the specified Hijri month and year.
  ///
  /// [hijriYear] - The Hijri year
  /// [hijriMonth] - The Hijri month (1-12)
  /// Returns a DateTime object for the first day of the Hijri month
  ///
  /// Example:
  /// ```dart
  /// DateTime firstDay = Utils.getHijriMonthStart(1446, 9);
  /// // Returns the Gregorian date for 1446-09-01
  /// ```
  static DateTime getHijriMonthStart(int hijriYear, int hijriMonth) {
    return hijriToGregorian(hijriYear, hijriMonth, 1);
  }

  /// Gets the last day of a Hijri month in Gregorian calendar.
  ///
  /// This function returns the Gregorian date that corresponds to the
  /// last day of the specified Hijri month and year.
  ///
  /// [hijriYear] - The Hijri year
  /// [hijriMonth] - The Hijri month (1-12)
  /// Returns a DateTime object for the last day of the Hijri month
  ///
  /// Example:
  /// ```dart
  /// DateTime lastDay = Utils.getHijriMonthEnd(1446, 9);
  /// // Returns the Gregorian date for the last day of Ramadan 1446
  /// ```
  static DateTime getHijriMonthEnd(int hijriYear, int hijriMonth) {
    var hDate = HijriCalendar.now();
    hDate.hYear = hijriYear;
    hDate.hMonth = hijriMonth;
    int daysInMonth = hDate.lengthOfMonth;
    return hijriToGregorian(hijriYear, hijriMonth, daysInMonth);
  }

  /// Gets the number of days in a specific Hijri month.
  ///
  /// This function returns the total number of days in the specified
  /// Hijri month and year (either 29 or 30 days).
  ///
  /// [hijriYear] - The Hijri year
  /// [hijriMonth] - The Hijri month (1-12)
  /// Returns the number of days in the month
  ///
  /// Example:
  /// ```dart
  /// int days = Utils.getHijriMonthLength(1446, 9);
  /// // Returns: 30 (for Ramadan 1446)
  /// ```
  static int getHijriMonthLength(int hijriYear, int hijriMonth) {
    var hDate = HijriCalendar.now();
    hDate.hYear = hijriYear;
    hDate.hMonth = hijriMonth;
    return hDate.lengthOfMonth;
  }

  /// Gets the first day of a Hijri year in Gregorian calendar.
  ///
  /// This function returns the Gregorian date that corresponds to the
  /// first day (1st of Muharram) of the specified Hijri year.
  ///
  /// [hijriYear] - The Hijri year
  /// Returns a DateTime object for the first day of the Hijri year
  ///
  /// Example:
  /// ```dart
  /// DateTime newYear = Utils.getHijriYearStart(1446);
  /// // Returns the Gregorian date for 1446-01-01 (1st Muharram)
  /// ```
  static DateTime getHijriYearStart(int hijriYear) {
    return hijriToGregorian(hijriYear, 1, 1);
  }

  /// Gets the last day of a Hijri year in Gregorian calendar.
  ///
  /// This function returns the Gregorian date that corresponds to the
  /// last day (29th or 30th of Dhul Hijjah) of the specified Hijri year.
  ///
  /// [hijriYear] - The Hijri year
  /// Returns a DateTime object for the last day of the Hijri year
  ///
  /// Example:
  /// ```dart
  /// DateTime yearEnd = Utils.getHijriYearEnd(1446);
  /// // Returns the Gregorian date for the last day of 1446
  /// ```
  static DateTime getHijriYearEnd(int hijriYear) {
    var hDate = HijriCalendar.now();
    hDate.hYear = hijriYear;
    hDate.hMonth = 12; // Dhul Hijjah
    int daysInMonth = hDate.lengthOfMonth;
    return hijriToGregorian(hijriYear, 12, daysInMonth);
  }

  /// Formats a Hijri date as a string.
  ///
  /// This function takes Hijri date components and formats them as a
  /// readable string in YYYY-MM-DD format.
  ///
  /// [hijriYear] - The Hijri year
  /// [hijriMonth] - The Hijri month (1-12)
  /// [hijriDay] - The Hijri day (1-30)
  /// Returns a formatted string representation of the Hijri date
  ///
  /// Example:
  /// ```dart
  /// String formatted = Utils.formatHijriDate(1446, 9, 26);
  /// // Returns: "1446-09-26"
  /// ```
  static String formatHijriDate(int hijriYear, int hijriMonth, int hijriDay) {
    return '$hijriYear-${hijriMonth.toString().padLeft(2, '0')}-${hijriDay.toString().padLeft(2, '0')}';
  }

  /// Gets the name of a Hijri month in Arabic.
  ///
  /// This function returns the Arabic name of the specified Hijri month.
  ///
  /// [hijriMonth] - The Hijri month number (1-12)
  /// Returns the Arabic name of the month
  ///
  /// Example:
  /// ```dart
  /// String monthName = Utils.getHijriMonthNameArabic(9);
  /// // Returns: "رمضان" (Ramadan)
  /// ```
  static String getHijriMonthNameArabic(int hijriMonth) {
    const List<String> monthNames = [
      'محرم', // Muharram
      'صفر', // Safar
      'ربيع الأول', // Rabi' al-awwal
      'ربيع الثاني', // Rabi' al-thani
      'جمادى الأولى', // Jumada al-awwal
      'جمادى الثانية', // Jumada al-thani
      'رجب', // Rajab
      'شعبان', // Sha'ban
      'رمضان', // Ramadan
      'شوال', // Shawwal
      'ذو القعدة', // Dhu al-Qi'dah
      'ذو الحجة' // Dhu al-Hijjah
    ];

    if (hijriMonth >= 1 && hijriMonth <= 12) {
      return monthNames[hijriMonth - 1];
    }
    return '';
  }

  /// Gets the name of a Hijri month in English.
  ///
  /// This function returns the English name of the specified Hijri month.
  ///
  /// [hijriMonth] - The Hijri month number (1-12)
  /// Returns the English name of the month
  ///
  /// Example:
  /// ```dart
  /// String monthName = Utils.getHijriMonthNameEnglish(9);
  /// // Returns: "Ramadan"
  /// ```
  static String getHijriMonthNameEnglish(int hijriMonth) {
    const List<String> monthNames = [
      'Muharram',
      'Safar',
      'Rabi\' al-awwal',
      'Rabi\' al-thani',
      'Jumada al-awwal',
      'Jumada al-thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah'
    ];

    if (hijriMonth >= 1 && hijriMonth <= 12) {
      return monthNames[hijriMonth - 1];
    }
    return '';
  }
}

/// Default Utils instance used as a fallback when no specific utils are provided.
///
/// This instance uses current time with empty prayer lists and disabled jamaah.
/// It's primarily used for initialization purposes.
Utils defaultUtils = Utils(
  DateTime.now(),
  prayersCurrent: List<Prayer>.filled(6, Prayer(), growable: false),
  prayersNext: List<Prayer>.filled(6, Prayer(), growable: false),
  prayersPrevious: List<Prayer>.filled(6, Prayer(), growable: false),
  jamaahOn: false,
  lat: 0,
  lng: 0,
  jamaahPerPrayer: [false, false, false, false, false, false],
);
