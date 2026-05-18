// ignore_for_file: dead_code

import 'package:prayer_timetable/src/PrayerTimetable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ignore: unused_import
import 'src/timetable_list_sarajevo.dart';
// ignore: unused_import
import 'src/timetable_vaktija_bh.dart';
import 'test.dart';

String timezone = timezoneS;

DateTime now = tz.TZDateTime.now(tz.getLocation(timezone));
// DateTime setTime = tz.TZDateTime.from(DateTime(2024, 3, 31, 14, 32, 45), tz.getLocation(timezone));
DateTime setTime = tz.TZDateTime(tz.getLocation(timezone), 2025, 10, 26, 17, 59, 55);
DateTime testTime = setTime;

// print(vaktija['vaktija']['months'][0]['days'][0]['vakat']);
// print(vaktija['differences'][77]['months'][0]['vakat'][0]); // 0

// List timetableList = base;
int cityNo = 77; // Sarajevo
// int cityNo = 2; // Bihać

List timetableList = vaktija['vaktija']['months']
    .map((months) => months['days'])
    .toList()
    .map((days) => days.map((vakat) => vakat['vakat']).toList())
    .toList();

List differences = vaktija['differences']
    .map((months) => months['months'])
    .toList()[cityNo]
    .map((vakat) => vakat['vakat'])
    .toList();

PrayerTimetable list(DateTime testTime) => PrayerTimetable.list(
      timetableList: timetableList,
      differences: differences,
      year: testTime.year,
      month: testTime.month,
      day: testTime.day,
      hour: testTime.hour,
      minute: testTime.minute,
      second: testTime.second,
      jamaahOn: true,
      // jamaahMethods: ['fixed', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
      jamaahMethods: ['afterthis', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
      jamaahOffsets: [
        // [6, 0],
        [0, 15],
        [0, 0],
        [0, 15],
        [0, 15],
        [0, 15],
        [0, 15]
      ],
      // jamaahPerPrayer: [false, false, true, true, false, false],
      timezone: timezone,
      // useTz: false,
    );

PrayerTimetable location = list(testTime);

void main() {
  tz.initializeTimeZones();
  print('\x1B[2J\x1B[0;0H'); // clear entire screen, move cursor to 0;0
  bool live = true;

  // infoTest(testTime);
  // print(timetableList.length);

  // print(timetableList[0][0][0]); // month/day/prayer

  // print(differences);

  if (!live) {
    jamaahTest(location,
        utils: false, jamaah: false, prayer: true, tomorrow: true, yesterday: true);
  } else {
    liveTest(location);
  }
}
