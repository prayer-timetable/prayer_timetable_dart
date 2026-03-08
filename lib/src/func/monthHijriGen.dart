import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:prayer_timetable/src/func/prayers.dart';
// import 'timetable_map.dart';
// import 'package:timezone/data/latest.dart' as tz;

// import 'package:hijri/digits_converter.dart';
// import 'package:hijri/hijri_array.dart';
import 'package:hijri/hijri_calendar.dart';

List<List<Prayer>> monthHijriGen(
  int hYear,
  int hMonth, {
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
  // DateTime date = tz.TZDateTime.from(
  //     DateTime(year, month, time.day)
  //         .add(Duration(hours: 3)), // making sure it is after 1 am for time change
  //     tz.getLocation(timezone));

  // var hTimeBase = HijriCalendar.fromDate(date);

  // First of the hijri month
  // var hTime = hTimeBase;
  // hTime.hDay = 1;

  int hDay = 1;

  var hDate = HijriCalendar.now();

  hDate.hYear = hYear;
  hDate.hMonth = hMonth;

  // print('$hYear $hMonth $hDay');

  // int daysInHijriMonth = 30;
  int daysInHijriMonth = hDate.lengthOfMonth;

  DateTime startDate =
      hDate.hijriToGregorian(hYear, hMonth, hDay).add(Duration(hours: 3));

  List<List<Prayer>> prayerList = List.generate(daysInHijriMonth, (index) {
    return prayersGen(
      startDate.add(Duration(days: index)),
      timetableMap: timetable,
      timetableList: list,
      differences: differences,
      timetableCalc: calc?.copyWith(date: startDate.add(Duration(days: index))),
      timezone: timezone,
      hijriOffset: hijriOffset,
      jamaahOn: jamaahOn,
      jamaahMethods: jamaahMethods,
      jamaahOffsets: jamaahOffsets,
      joinDhuhr: joinDhuhr,
      joinMaghrib: joinMaghrib,
      jamaahPerPrayer: jamaahPerPrayer,
      // useTz: useTz,
      prayerLength: prayerLength,
    );
  });

  return prayerList;
}
