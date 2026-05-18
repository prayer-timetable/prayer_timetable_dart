import 'package:date_format/date_format.dart';
import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:prayer_timetable/src/func/helpers.dart';
// import 'package:prayer_timetable/src/func/monthGen.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// ignore: unused_import
import 'src/timetable_list_sarajevo.dart';
// ignore: unused_import
import 'src/timetable_map_dublin.dart';
// ignore: unused_import
import 'src/timetable_map_dublin_leap.dart';
import 'test.dart';

String timezone = timezoneI;
double lat = latI;
double lng = lngI;

DateTime now = tz.TZDateTime.now(tz.getLocation(timezone));
// DateTime setTime = tz.TZDateTime.from(DateTime(2024, 3, 31, 14, 32, 45), tz.getLocation(timezone));
// day before saturday of october dst change
DateTime setTime = DateTime(2025, 10, 24, 23, 41, 55);
// DateTime setTime = DateTime(2025, 10, 26, 18, 41, 55);
DateTime testTime = setTime;

// TimetableCalc calc = TimetableCalc(
//   date: testTime,
//   timezone: timezone,
//   lat: lat,
//   lng: lng,
//   precision: true,
//   fajrAngle: 14.6,
// );

List<List<Prayer>> list = PrayerTimetable.monthTable(
  testTime.year, testTime.month,
  // calc: calc,
  // list: timetableList,
  timetable: dublin,
  // timetable: testTime.year % 4 == 0 ? dublinLeap : dublin,
  // list: base,
  hijriOffset: 0,
  timezone: timezone,
);

// List<List<Prayer>> list = monthGen(
//   testTime.year, testTime.month,
//   // calc: calc,
//   list: timetableList,
//   differences: differences,
//   // timetable: testTime.year % 4 == 0 ? dublinLeap : dublin,
//   // list: base,
//   hijriOffset: 0,
//   timezone: timezone,
// );

void main() {
  tz.initializeTimeZones();

  print('----------------------------------------------------------------------');
  print('Date        Fajr      Sunrise   Dhuhr     Asr       Maghrib   Isha');
  print('----------------------------------------------------------------------');

  for (List<Prayer> item in list) {
    print(
        '''${testTime.day == item[0].prayerTime.day ? green : noColor}${formatDate(item[0].prayerTime, [
          yyyy,
          '-',
          mm,
          '-',
          dd,
          '  ',
          HH,
          ':',
          nn,
          ':',
          ss
        ])}  ${formatDate(item[1].prayerTime, [
          HH,
          ':',
          nn,
          ':',
          ss
        ])}  ${formatDate(item[2].prayerTime, [
          HH,
          ':',
          nn,
          ':',
          ss
        ])}  ${formatDate(item[3].prayerTime, [
          HH,
          ':',
          nn,
          ':',
          ss
        ])}  ${formatDate(item[4].prayerTime, [
          HH,
          ':',
          nn,
          ':',
          ss
        ])}  ${formatDate(item[5].prayerTime, [HH, ':', nn, ':', ss])}''');
  }
  print('----------------------------------------------------------------------');
  print(noColor);
}
