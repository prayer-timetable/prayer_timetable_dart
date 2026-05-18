/// Automated edge-case checks for prayer transitions, midnight, and DST.
library;

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:prayer_timetable/src/PrayerTimetable.dart';
import 'package:prayer_timetable/src/components/TimetableCalc.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'src/timetable_map_dublin.dart' as dublin_data;
import 'src/timetable_vaktija_bh.dart';
import 'test.dart';

int _passed = 0;
int _failed = 0;
final List<String> _failures = [];

void check(String name, bool condition, [String? detail]) {
  if (condition) {
    _passed++;
    print('  PASS  $name');
  } else {
    _failed++;
    final msg = detail == null ? name : '$name — $detail';
    _failures.add(msg);
    print('  FAIL  $msg');
  }
}

void checkCountdown(String name, PrayerTimetable loc, Duration expectedMin, Duration expectedMax) {
  final cd = loc.utils.countDown;
  check(
    name,
    cd >= expectedMin && cd <= expectedMax,
    'countDown=$cd expected ${expectedMin.inMinutes}-${expectedMax.inMinutes}min',
  );
}

PrayerTimetable calcAt(tz.TZDateTime time, {bool jamaahOn = false}) {
  final calc = TimetableCalc(
    date: time,
    timezone: timezoneI,
    lat: latI,
    lng: lngI,
    precision: true,
    fajrAngle: angleI,
    highLatitudeRule: adhan.HighLatitudeRule.twilightAngle.name,
  );
  return PrayerTimetable.calc(
    timetableCalc: calc,
    year: time.year,
    month: time.month,
    day: time.day,
    hour: time.hour,
    minute: time.minute,
    second: time.second,
    jamaahOn: jamaahOn,
    jamaahMethods: ['afterthis', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
    jamaahOffsets: [
      [0, 15],
      [0, 0],
      [0, 15],
      [0, 15],
      [0, 15],
      [0, 15],
    ],
    timezone: timezoneI,
  );
}

PrayerTimetable mapAt(tz.TZDateTime time) {
  return PrayerTimetable.map(
    timetableMap: dublin_data.dublin,
    year: time.year,
    month: time.month,
    day: time.day,
    hour: time.hour,
    minute: time.minute,
    second: time.second,
    jamaahOn: true,
    jamaahMethods: ['afterthis', '', 'afterthis', 'afterthis', 'afterthis', 'fixed'],
    jamaahOffsets: [
      [0, 15],
      [0, 0],
      [0, 15],
      [0, 15],
      [0, 15],
      [23, 0],
    ],
    joinMaghrib: false,
    timezone: timezoneI,
  );
}

PrayerTimetable listAt(tz.TZDateTime time) {
  const cityNo = 77; // Sarajevo
  final timetableList = vaktija['vaktija']['months']
      .map((months) => months['days'])
      .toList()
      .map((days) => days.map((vakat) => vakat['vakat']).toList())
      .toList();
  final differences = vaktija['differences']
      .map((months) => months['months'])
      .toList()[cityNo]
      .map((vakat) => vakat['vakat'])
      .toList();

  return PrayerTimetable.list(
    timetableList: timetableList,
    differences: differences,
    year: time.year,
    month: time.month,
    day: time.day,
    hour: time.hour,
    minute: time.minute,
    second: time.second,
    jamaahOn: true,
    jamaahMethods: ['afterthis', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
    jamaahOffsets: [
      [0, 15],
      [0, 0],
      [0, 15],
      [0, 15],
      [0, 15],
      [0, 15],
    ],
    timezone: timezoneS,
  );
}

tz.TZDateTime dublin(int y, int m, int d, [int h = 0, int min = 0, int s = 0]) =>
    tz.TZDateTime(tz.getLocation(timezoneI), y, m, d, h, min, s);

tz.TZDateTime sarajevo(int y, int m, int d, [int h = 0, int min = 0, int s = 0]) =>
    tz.TZDateTime(tz.getLocation(timezoneS), y, m, d, h, min, s);

void runCalcEdgeCases() {
  print('\n=== calc (Dublin) ===');

  // After isha — next is tomorrow fajr, normal countdown
  final afterIsha = dublin(2025, 5, 19, 23, 45);
  final locAfterIsha = calcAt(afterIsha);
  final isha = locAfterIsha.current[5].prayerTime;
  final nextFajr = locAfterIsha.next[0].prayerTime;
  check('after isha: currentId=5', locAfterIsha.utils.currentId == 5);
  check('after isha: nextId=0', locAfterIsha.utils.nextId == 0);
  check('after isha: isAfterIsha', locAfterIsha.utils.isAfterIsha);
  check('after isha: next is tomorrow fajr', locAfterIsha.utils.next == nextFajr);
  check('after isha: next fajr is next day', nextFajr.day == 20);
  check('after isha: countDown positive', locAfterIsha.utils.countDown.inSeconds > 0);
  check(
    'after isha: countDown matches fajr delta',
    locAfterIsha.utils.countDown == nextFajr.difference(afterIsha),
    'cd=${locAfterIsha.utils.countDown} delta=${nextFajr.difference(afterIsha)}',
  );
  checkCountdown('after isha: countdown under 8h', locAfterIsha, Duration.zero, const Duration(hours: 8));

  // Maghrib → isha window
  final maghrib = locAfterIsha.current[4].prayerTime;
  final ishaTime = locAfterIsha.current[5].prayerTime;
  final betweenMaghribIsha = maghrib.add(Duration(minutes: 5));
  final locMagIsha = calcAt(tz.TZDateTime(
    tz.getLocation(timezoneI),
    betweenMaghribIsha.year,
    betweenMaghribIsha.month,
    betweenMaghribIsha.day,
    betweenMaghribIsha.hour,
    betweenMaghribIsha.minute,
    betweenMaghribIsha.second,
  ));
  check('maghrib→isha: currentId=4', locMagIsha.utils.currentId == 4);
  check('maghrib→isha: nextId=5', locMagIsha.utils.nextId == 5);
  check('maghrib→isha: not after isha', !locMagIsha.utils.isAfterIsha);
  check('maghrib→isha: next is isha', locMagIsha.utils.next == ishaTime);
  check(
    'maghrib→isha: countdown to isha',
    locMagIsha.utils.countDown == ishaTime.difference(betweenMaghribIsha),
  );

  // Midnight before fajr
  final beforeFajr = dublin(2025, 5, 20, 2, 30);
  final locMidnight = calcAt(beforeFajr);
  check('midnight: currentId=5 (isha period)', locMidnight.utils.currentId == 5);
  check('midnight: nextId=0', locMidnight.utils.nextId == 0);
  check('midnight: not isAfterIsha flag', !locMidnight.utils.isAfterIsha);
  check('midnight: next is today fajr', locMidnight.utils.next == locMidnight.current[0].prayerTime);
  check('midnight: countDown positive', locMidnight.utils.countDown.inMinutes > 0);
  check('midnight: countDown under 4h', locMidnight.utils.countDown.inHours < 4);

  // DST spring forward day (Ireland: last Sunday March, 2025-03-30)
  final dstSpring = dublin(2025, 3, 30, 14, 0);
  final locSpring = calcAt(dstSpring);
  check('DST spring: prayers ordered', _prayersOrdered(locSpring.current));
  check('DST spring: isDst', dstSpring.timeZone.isDst);
  check('DST spring: fajr before sunrise', locSpring.current[0].prayerTime.isBefore(locSpring.current[1].prayerTime));

  // DST fall back eve (2025-10-25 23:41 — still IST +1)
  final dstFallEve = dublin(2025, 10, 25, 23, 41, 55);
  final locFallEve = calcAt(dstFallEve);
  check('DST fall eve: isDst', dstFallEve.timeZone.isDst);
  check('DST fall eve: after isha', locFallEve.utils.isAfterIsha);
  check('DST fall eve: next fajr next day', locFallEve.utils.next.day == 26);
  check('DST fall eve: countdown positive', locFallEve.utils.countDown.inHours < 7);

  // DST fall back day (2025-10-26 — clocks back to GMT)
  final dstFallDay = dublin(2025, 10, 26, 18, 47);
  final locFallDay = calcAt(dstFallDay);
  check('DST fall day: not isDst', !dstFallDay.timeZone.isDst);
  check('DST fall day: prayers ordered', _prayersOrdered(locFallDay.current));

  // Jamaah: between isha adhan and isha jamaah
  final jamaahTime = dublin(2025, 5, 19, 23, 25);
  final locJamaah = calcAt(jamaahTime, jamaahOn: true);
  if (jamaahTime.isBefore(locJamaah.current[5].jamaahTime)) {
    check('isha jamaah pending: currentId=5', locJamaah.utils.currentId == 5);
    check('isha jamaah pending: isJamaahPending', locJamaah.utils.isJamaahPending);
    check('isha jamaah pending: not after isha yet', !locJamaah.utils.isAfterIsha);
  }

  print('  isha=$isha maghrib=$maghrib nextFajr=$nextFajr');
}

void runMapEdgeCases() {
  print('\n=== map (Dublin) ===');

  // After isha with fixed jamaah at 23:00
  final afterIsha = dublin(2025, 10, 25, 23, 41, 55);
  final loc = mapAt(afterIsha);
  check('map after isha: isAfterIsha', loc.utils.isAfterIsha);
  check('map after isha: currentId=5', loc.utils.currentId == 5);
  check('map after isha: nextId=0', loc.utils.nextId == 0);
  check('map after isha: countdown positive', loc.utils.countDown.inSeconds > 0);
  check(
    'map after isha: countdown matches next fajr',
    loc.utils.countDown == loc.utils.next.difference(afterIsha),
    'cd=${loc.utils.countDown}',
  );
  check('map after isha: next fajr Oct 26', loc.utils.next.day == 26);

  // Maghrib→isha on DST transition week (after maghrib jamaah)
  final maghribTime = loc.current[4].prayerTime;
  final maghribJamaah = loc.current[4].jamaahTime;
  final between = maghribJamaah.add(const Duration(minutes: 7));
  final locMid = mapAt(tz.TZDateTime(
    tz.getLocation(timezoneI),
    between.year,
    between.month,
    between.day,
    between.hour,
    between.minute,
    between.second,
  ));
  check('map maghrib→isha: currentId=4', locMid.utils.currentId == 4);
  check('map maghrib→isha: next is isha', locMid.utils.next == locMid.current[5].prayerTime);
  check('map maghrib→isha: countdown to isha', locMid.utils.countDown.inMinutes < 90);

  // Maghrib adhan→jamaah pending
  final beforeJamaah = maghribTime.add(const Duration(minutes: 5));
  final locPending = mapAt(tz.TZDateTime(
    tz.getLocation(timezoneI),
    beforeJamaah.year,
    beforeJamaah.month,
    beforeJamaah.day,
    beforeJamaah.hour,
    beforeJamaah.minute,
    beforeJamaah.second,
  ));
  check('map maghrib jamaah pending: next is maghrib jamaah', locPending.utils.next == maghribJamaah);
  check('map maghrib jamaah pending: isJamaahPending', locPending.utils.isJamaahPending);

  // Midnight before fajr
  final midnight = dublin(2025, 10, 26, 1, 30);
  final locMidnight = mapAt(midnight);
  check('map midnight: currentId=5', locMidnight.utils.currentId == 5);
  check('map midnight: not isAfterIsha', !locMidnight.utils.isAfterIsha);
  check('map midnight: countdown to fajr', locMidnight.utils.countDown.inHours < 5);

  print('  maghrib=$maghribTime isha=${loc.current[5].prayerTime} nextFajr=${loc.utils.next}');
}

void runListEdgeCases() {
  print('\n=== list (Sarajevo) ===');

  // After isha — Oct 26 2025 20:00 (approx, verify dynamically)
  final probe = sarajevo(2025, 10, 26, 19, 0);
  final probeLoc = listAt(probe);
  final isha = probeLoc.current[5].prayerTime;
  final ishaLoc = tz.getLocation(timezoneS);
  final ishaTz = tz.TZDateTime(
    ishaLoc,
    isha.year,
    isha.month,
    isha.day,
    isha.hour,
    isha.minute,
    isha.second,
  );
  final afterIsha = ishaTz.add(const Duration(minutes: 30));
  final loc = listAt(afterIsha);

  check('list after isha: isAfterIsha', loc.utils.isAfterIsha);
  check('list after isha: currentId=5', loc.utils.currentId == 5);
  check('list after isha: nextId=0', loc.utils.nextId == 0);
  check('list after isha: countdown positive', loc.utils.countDown.inSeconds > 0);
  check(
    'list after isha: countdown matches next fajr',
    loc.utils.countDown == loc.utils.next.difference(afterIsha),
  );
  check('list after isha: next fajr is next calendar day', loc.utils.next.day == afterIsha.day + 1 || loc.utils.next.month != afterIsha.month);

  // Maghrib→isha (from test_timetable_list scenario: 17:59)
  final maghribWindow = sarajevo(2025, 10, 26, 17, 59, 55);
  final locMag = listAt(maghribWindow);
  check('list maghrib window: currentId=4', locMag.utils.currentId == 4);
  check('list maghrib window: nextId=5', locMag.utils.nextId == 5);
  check('list maghrib window: not after isha', !locMag.utils.isAfterIsha);
  check('list maghrib window: countdown under 2h', locMag.utils.countDown.inHours < 2);

  // Midnight before fajr
  final beforeFajr = sarajevo(2025, 10, 27, 3, 0);
  final locMid = listAt(beforeFajr);
  check('list midnight: currentId=5', locMid.utils.currentId == 5);
  check('list midnight: not isAfterIsha', !locMid.utils.isAfterIsha);
  check('list midnight: countdown positive', locMid.utils.countDown.inMinutes > 0);

  print('  isha=$isha afterIsha=$afterIsha nextFajr=${loc.utils.next}');
}

bool _prayersOrdered(List prayers) {
  for (var i = 0; i < 5; i++) {
    if (!prayers[i].prayerTime.isBefore(prayers[i + 1].prayerTime)) return false;
  }
  return true;
}

void main() {
  tz.initializeTimeZones();

  print('Edge-case test run');
  print('==================');

  runCalcEdgeCases();
  runMapEdgeCases();
  runListEdgeCases();

  print('\n==================');
  print('Results: $_passed passed, $_failed failed');
  if (_failures.isNotEmpty) {
    print('\nFailures:');
    for (final f in _failures) {
      print('  - $f');
    }
    throw StateError('$_failed edge-case check(s) failed');
  }
  print('All edge-case checks passed.');
}
