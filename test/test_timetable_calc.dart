import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:prayer_timetable/src/PrayerTimetable.dart';
import 'package:prayer_timetable/src/components/TimetableCalc.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ignore: unused_import
import 'test.dart';

String timezone = timezoneI;

DateTime now = tz.TZDateTime.now(tz.getLocation(timezone));
DateTime setTime = tz.TZDateTime(tz.getLocation(timezone), 2024, 3, 31, 14, 32, 45);
DateTime testTime = now;

TimetableCalc timetableCalc = TimetableCalc(
  // testTime,
  date: testTime,
  timezone: timezone,
  lat: latI,
  lng: lngI,
  precision: true,
  fajrAngle: 14.6,
  highLatitudeRule: adhan.HighLatitudeRule.twilightAngle.name,
  // highLatitudeRule: HighLatitudeRule.middleOfTheNight,
  // highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
);

PrayerTimetable calc(DateTime testTime) => PrayerTimetable.calc(
      timetableCalc: timetableCalc,
      year: testTime.year,
      month: testTime.month,
      day: testTime.day,
      jamaahOn: true,
      jamaahMethods: ['fixed', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
      jamaahOffsets: [
        [6, 0],
        [0, 0],
        [0, 15],
        [0, 15],
        [0, 15],
        [0, 15]
      ],
      jamaahPerPrayer: [false, false, true, true, false, false],
      timezone: timezone,
    );

PrayerTimetable location = calc(testTime);

adhan.CalculationParameters params = adhan.CalculationParameters(
  fajrAngle: 18.0,
  ishaAngle: 17.0,
  method: adhan.CalculationMethod.muslimWorldLeague,
  highLatitudeRule: adhan.HighLatitudeRule.twilightAngle,
);

final prayerTimes = adhan.PrayerTimes(
  coordinates: adhan.Coordinates(latI, lngI),
  date: now,
  calculationParameters: params,

  // CalculationParameters(
  //   'MuslimWorldLeague',
  //   14.6,
  //   14.6,
  //   highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
  //   madhab: Madhab.shafi,
  //   adjustments: {'fajr': 100, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
  //   methodAdjustments: {'fajr': 200, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
  // ),
  precision: true,
);

void main() {
  tz.initializeTimeZones();
  print('\x1B[2J\x1B[0;0H'); // clear entire screen, move cursor to 0;0
  bool live = false;

  infoTest(testTime);

  timetableCalc.highLatitudeRule = adhan.HighLatitudeRule.middleOfTheNight.name;
  print(timetableCalc.prayerTimes.fajr);

  timetableCalc.highLatitudeRule = adhan.HighLatitudeRule.seventhOfTheNight.name;
  print(timetableCalc.prayerTimes.fajr);

  timetableCalc.highLatitudeRule = adhan.HighLatitudeRule.twilightAngle.name;
  print(timetableCalc.prayerTimes.fajr);

  prayerTimes.calculationParameters.highLatitudeRule = adhan.HighLatitudeRule.twilightAngle;
  print(prayerTimes.fajr);

  if (!live) {
    jamaahTest(location);

    // ignore: dead_code
  } else {
    liveTest(location);
  }
}
