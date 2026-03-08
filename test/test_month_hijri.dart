import 'package:date_format/date_format.dart';
import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:prayer_timetable/src/func/helpers.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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
DateTime setTime = DateTime(2025, 3, 1, 14, 32, 45);
DateTime testTime = now;

// params.madhab = Madhab.Hanafi;
// params.adjustments.fajr = 2;

TimetableCalc calc = TimetableCalc(
  date: testTime,
  timezone: timezone,
  lat: lat,
  lng: lng,
  precision: true,
  fajrAngle: 14.6,
);

// Generate Hijri month table for Jumada al-awwal 1447
List<List<Prayer>> list = PrayerTimetable.monthHijriTable(
  1447, 5, // Jumada al-awwal 1447
  timetable: testTime.year % 4 == 0 ? dublinLeap : dublin,
  hijriOffset: 0,
  timezone: timezone,
);

void main() {
  tz.initializeTimeZones();

  print('Testing PrayerTimetable.monthHijriTable() for Jumada al-awwal 1447');
  print('Using Dublin timetable with timezone: $timezone');
  print('');
  print('--------------------------------------------------------------------------------------');
  print('Hijri Date  Fajr      Sunrise   Dhuhr     Asr       Maghrib   Isha      Gregorian');
  print('--------------------------------------------------------------------------------------');

  for (int dayIndex = 0; dayIndex < list.length; dayIndex++) {
    List<Prayer> item = list[dayIndex];
    DateTime gregorianDate = item[0].prayerTime;

    // Since we're using monthHijriTable, we know this is Jumada al-awwal 1447
    int hijriDay = dayIndex + 1;
    String hijriDateStr = Utils.formatHijriDate(1447, 5, hijriDay);

    print(
        '''${testTime.day == item[0].prayerTime.day ? green : noColor}$hijriDateStr  ${formatDate(item[0].prayerTime, [
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
        ])}  ${formatDate(item[5].prayerTime, [
          HH,
          ':',
          nn,
          ':',
          ss
        ])}  ${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}$noColor''');
  }
  print('----------------------------------------------------------------------');
}
