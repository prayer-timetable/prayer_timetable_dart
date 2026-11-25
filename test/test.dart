import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:prayer_timetable/src/func/helpers.dart';
import 'package:prayer_timetable/src/func/prayers.dart';

// Dublin
double latI = 53.3046593;
double lngI = -6.2344076;
double altitudeI = 85;
double angleI = 14.6; //18
double iangleI = 14.6; //16
String timezoneI = 'Europe/Dublin';

// Sarajevo
double latS = 43.8563;
double lngS = 18.4131;
double altitudeS = 518;
double angleS = 14.6; //iz =19
double iangleS = 14.6; // iz = 17
String timezoneS = 'Europe/Sarajevo';

void infoTest(dynamic time) {
  List<String> timeSplit = time.toString().split(' ');

  print('$green******************* Info *******************$noColor');
  print('time:\t\t${timeSplit[1]}');
  print('date:\t\t${timeSplit[0]}');
  print('timeZoneOffset:\t${time.timeZoneOffset}');
  print('isDst:\t\t${time.timeZone.isDst}');
  print('location:\t${time.location}');
  print('timeZone:\t${time.timeZone}');
  print('timeZone abr:\t${time.timeZone.abbreviation}');
  print('offset (ms):\t${time.timeZone.offset}');
  print('isDSTCalc:\t${isDSTCalc(time)}');

  // timeZone: ${lastMidnight.timeZone} or lastMidnight.location.name
  // time: ${lastMidnight.toIso8601String()}
  // lastMidnight.timeZone.offset in miliseconds
}

void timetableTest(PrayerTimetable location) {
  print('$yellow***************** Current ******************$noColor');
  print('fajr:\t\t${location.current[0].prayerTime}');
  print('sunrise:\t${location.current[1].prayerTime}');
  print('dhuhr:\t\t${location.current[2].prayerTime}');
  print('asr:\t${location.current[3].prayerTime}');
  print('maghrib:\t\t${location.current[4].prayerTime}');
  print('isha:\t\t${location.current[5].prayerTime}');
  print('$yellow****************** Next ********************$noColor');
  print('fajr:\t\t${location.next[0].prayerTime}');
  print('sunrise:\t${location.next[1].prayerTime}');
  print('dhuhr:\t\t${location.next[2].prayerTime}');
  print('asr:\t${location.next[3].prayerTime}');
  print('maghrib:\t\t${location.next[4].prayerTime}');
  print('isha:\t\t${location.next[5].prayerTime}');
  print('$yellow************** Previous ******************$noColor');
  print('fajr:\t\t${location.previous[0].prayerTime}');
  print('sunrise:\t${location.previous[1].prayerTime}');
  print('dhuhr:\t\t${location.previous[2].prayerTime}');
  print('asr:\t${location.previous[3].prayerTime}');
  print('maghrib:\t\t${location.previous[4].prayerTime}');
  print('isha:\t\t${location.previous[5].prayerTime}');
  print('$yellow************** Calc ******************$noColor');
  print('time:\t${location.utils.time}');
  print('current:\t${location.utils.current}');
  print('next:\t\t${location.utils.next}');
  print('previous:\t${location.utils.previous}');
  print('isAfterIsha:\t${location.utils.isAfterIsha}');
  print('currentId:\t${location.utils.currentId}');
  print('countDown:\t${location.utils.countDown}');
  print('countUp:\t${location.utils.countUp}');
  print('Qibla:\t${location.utils.qibla}');
  print('percentage:\t${location.utils.percentage}');
  print('midnight:\t${location.utils.midnight}');
  print('lastThird\t${location.utils.lastThird}');
}

void jamaahTest(
  PrayerTimetable location, {
  bool prayer = true,
  bool jamaah = false,
  bool utils = false,
  bool today = true,
  bool yesterday = true,
  bool tomorrow = true,
  bool info = false,
}) {
  if (info) infoTest(location.utils.time);
  if (prayer && today) {
    print('$yellow****************** Today *******************$noColor');
    print('fajr:\t\t${location.current[0].prayerTime}');
    print('sunrise:\t${location.current[1].prayerTime}');
    print('dhuhr:\t\t${location.current[2].prayerTime}');
    print('asr:\t\t${location.current[3].prayerTime}');
    print('maghrib:\t${location.current[4].prayerTime}');
    print('isha:\t\t${location.current[5].prayerTime}');
  }

  if (jamaah && today) {
    print('$gray************** Today Jamaah ****************$noColor');
    print('fajr:\t\t${location.current[0].jamaahTime}');
    print('sunrise:\t${location.current[1].jamaahTime}');
    print('dhuhr:\t\t${location.current[2].jamaahTime}');
    print('asr:\t\t${location.current[3].jamaahTime}');
    print('maghrib:\t${location.current[4].jamaahTime}');
    print('isha:\t\t${location.current[5].jamaahTime}');
  }

  if (prayer && tomorrow) {
    print('$yellow***************** Tomorrow *****************$noColor');
    print('fajr:\t\t${location.next[0].prayerTime}');
    print('sunrise:\t${location.next[1].prayerTime}');
    print('dhuhr:\t\t${location.next[2].prayerTime}');
    print('asr:\t\t${location.next[3].prayerTime}');
    print('maghrib:\t${location.next[4].prayerTime}');
    print('isha:\t\t${location.next[5].prayerTime}');
  }

  if (jamaah && tomorrow) {
    print('$gray************* Tomorrow Jamaah **************$noColor');
    print('fajr:\t\t${location.next[0].jamaahTime}');
    print('sunrise:\t${location.next[1].jamaahTime}');
    print('dhuhr:\t\t${location.next[2].jamaahTime}');
    print('asr:\t\t${location.next[3].jamaahTime}');
    print('maghrib:\t${location.next[4].jamaahTime}');
    print('isha:\t\t${location.next[5].jamaahTime}');
  }

  if (prayer && yesterday) {
    print('$yellow***************** Yesterday ****************$noColor');
    print('fajr:\t\t${location.previous[0].prayerTime}');
    print('sunrise:\t${location.previous[1].prayerTime}');
    print('dhuhr:\t\t${location.previous[2].prayerTime}');
    print('asr:\t\t${location.previous[3].prayerTime}');
    print('maghrib:\t${location.previous[4].prayerTime}');
    print('isha:\t\t${location.previous[5].prayerTime}');
  }

  if (jamaah && yesterday) {
    print('$gray************* Yesterday Jamaah *************$noColor');
    print('fajr:\t\t${location.previous[0].jamaahTime}');
    print('sunrise:\t${location.previous[1].jamaahTime}');
    print('dhuhr:\t\t${location.previous[2].jamaahTime}');
    print('asr:\t\t${location.previous[3].jamaahTime}');
    print('maghrib:\t${location.previous[4].jamaahTime}');
    print('isha:\t\t${location.previous[5].jamaahTime}');
  }

  if (utils) {
    print('$yellow****************** Utils *******************$noColor');
    print('time:\t\t${location.utils.time}');
    print('current:\t${location.utils.current}');
    print('next:\t\t${location.utils.next}');
    print('previous:\t${location.utils.previous}');
    print('isAfterIsha:\t${location.utils.isAfterIsha}');
    print('isJamaahPend:\t${location.utils.isJamaahPending}');
    print('currentId:\t${location.utils.currentId}');
    print('countDown:\t${location.utils.countDown}');
    print('countUp:\t${location.utils.countUp}');
    print('percentage:\t${location.utils.percentage}');
    print('qibla:\t\t${location.utils.qibla}');
    print('hijri:\t\t${location.utils.hijri}');
    print('midnight:\t${location.utils.midnight}');
    print('lastThird\t${location.utils.lastThird}');
    print('timezone\t${location.timezone}');
    print('useTz\t\t${location.useTz}');
    print('utcOffsetHours\t${location.utils.utcOffsetHours}');
    // print(location.current);
  }
}

void liveTest(
  PrayerTimetable location, {
  bool show = true,
  bool info = false,
  bool realtime = false,
}) {
  DateTime time = location.utils.time;
  PrayerTimetable loc = location;

  void runable() {
    loc = PrayerTimetable.base(
      timezone: loc.timezone,
      timetableMap: loc.timetableMap,
      timetableList: loc.timetableList,
      timetableCalc: loc.timetableCalc,
      year: time.year,
      month: time.month,
      day: time.day,
      hour: time.hour,
      minute: time.minute,
      second: time.second,
      hijriOffset: loc.hijriOffset,
      jamaahOn: loc.jamaahOn,
      joinMaghrib: loc.joinMaghrib,
      joinDhuhr: loc.joinDhuhr,
      jamaahPerPrayer: loc.jamaahPerPrayer,
      jamaahMethods: loc.jamaahMethods,
      jamaahOffsets: loc.jamaahOffsets,
      lat: loc.lat,
      lng: loc.lng,
    );

    // List<Prayer> prayers = loc.focus;
    List<Prayer> prayers = loc.utils.isAfterIsha ? loc.next : loc.current;

    if (show) {
      print('\x1B[2J\x1B[0;0H'); // clear entire screen, move cursor to 0;0

      if (info) infoTest(time);

      print('date:\t\t${formatDate(time, [yyyy, '-', mm, '-', dd])}');
      print(
        'hijri:\t\t${loc.utils.hijri[0]}-${loc.utils.hijri[1]}-${loc.utils.hijri[2]}',
      );
      print('time:\t\t${formatDate(time, [HH, ':', nn, ':', ss])}');

      print('$gray----------------------------------------$noColor');
      print(
        'Prayers for:\t${formatDate(prayers.first.prayerTime, [yyyy, '-', mm, '-', dd])}',
      );
      print('$gray----------------------------------------$noColor');

      for (var i = 0; i <= 5; i++) {
        print(
          '${prayers[i].isNext ? green : ''}${('${prayerNames[i]}:').padRight(8)}\t${formatDate(prayers[i].prayerTime, [HH, ':', nn, ':', ss])}\t${formatDate(prayers[i].jamaahTime, [HH, ':', nn, ':', ss])}$noColor',
        );
      }

      print('$gray----------------------------------------$noColor');
      print('$green${'-' * (loc.utils.percentage / 100 * 40).round()}$noColor');
      print('$gray----------------------------------------$noColor');
      print(
        '${yellow}countDown:\t${printDuration(loc.utils.countDown)}$noColor',
      );
      print('${yellow}countUp:\t${printDuration(loc.utils.countUp)}$noColor');
      print('${yellow}percentage:\t${loc.utils.percentage}$noColor');
      // print('${yellow}currentId:\t${loc.utils.currentId}${noColor}');
      // print('${yellow}nextId:\t\t${loc.utils.nextId}${noColor}');
      // print('${yellow}previousId:\t${loc.utils.previousId}${noColor}');
      print('${yellow}isJamaahPend:\t${loc.utils.isJamaahPending}$noColor');
      print('${yellow}isAfterIsha:\t${loc.utils.isAfterIsha}$noColor');

      String isNextString = '${yellow}isNext:\t\t';
      String isCurrentString = '${yellow}isCurrent:\t';

      for (var i = 0; i <= 5; i++) {
        isNextString =
            '$isNextString${prayers[i].isNext ? green : yellow}${prayers[i].isNext}${i != 5 ? '\t' : ''}';
        isCurrentString =
            '$isCurrentString${prayers[i].isCurrent ? green : yellow}${prayers[i].isCurrent}${i != 5 ? '\t' : ''}';
      }
      isCurrentString = '$isCurrentString$noColor';
      print(isCurrentString);
      isNextString = '$isNextString$noColor';
      print(isNextString);

      // print(
      // '${yellow}isNext:\t${prayers[0].isNext}\t${prayers[1].isNext}\t${prayers[2].isNext}\t${prayers[3].isNext}\t${prayers[4].isNext}\t${prayers[5].isNext}${noColor}');
    } else {
      print(clear);
      print('isha adhan\t${prayers[5].prayerTime}');
      print('isha jamaah\t${prayers[5].jamaahTime}');
      print('-----');
      print('time\t\t$time');
      print('-----');
      print('fajr adhan\t${prayers[0].prayerTime}');
      print('fajr jamaah\t${prayers[0].jamaahTime}');
      print('-----');
      print('isAfterIsha\t${loc.utils.isAfterIsha}');
      print('${prayers[0].jamaahTime.isAfter(time)}');
      print('fajr next?\t${prayers[0].isNext}');
      print('isha next?\t${prayers[5].isNext}');
    }
  }

  if (realtime)
    Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      time = time.add(Duration(seconds: 1));
      runable();
    });
  else
    runable();
}

// exports.colors = {
//   pass: 90,
//   fail: 31,
//   'bright pass': 92,
//   'bright fail': 91,
//   'bright yellow': 93,
//   pending: 36,
//   suite: 0,
//   'error title': 0,
//   'error message': 31,
//   'error stack': 90,
//   checkmark: 32,
//   fast: 90,
//   medium: 33,
//   slow: 31,
//   green: 32,
//   light: 90,
//   'diff gutter': 90,
//   'diff added': 32,
//   'diff removed': 31
// };
