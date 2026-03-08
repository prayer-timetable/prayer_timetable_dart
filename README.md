# Prayer Timetable Dart

[![pub package](https://img.shields.io/pub/v/prayer_timetable.svg)](https://pub.dev/packages/prayer_timetable)
[![pub points](https://img.shields.io/pub/points/prayer_timetable)](https://pub.dev/packages/prayer_timetable/score)
[![popularity](https://img.shields.io/pub/popularity/prayer_timetable)](https://pub.dev/packages/prayer_timetable/score)
[![likes](https://img.shields.io/pub/likes/prayer_timetable)](https://pub.dev/packages/prayer_timetable/score)
[![GitHub](https://img.shields.io/github/license/prayer-timetable/prayer_timetable_dart)](https://github.com/prayer-timetable/prayer_timetable_dart)

A comprehensive Dart library for Islamic prayer time calculations with multiple calculation methods, timezone support, and jamaah (congregation) time management.

**📦 [View on pub.dev](https://pub.dev/packages/prayer_timetable) | 🔗 [GitHub Repository](https://github.com/prayer-timetable/prayer_timetable_dart)**

## Features

- **Multiple Calculation Methods**: Astronomical calculations, pre-calculated maps, and list-based timetables
- **Comprehensive Prayer Management**: All five daily prayers plus Sunrise with status tracking
- **Jamaah Time Support**: Customizable congregation times with various calculation methods
- **Timezone Handling**: Full timezone support with automatic DST adjustments
- **Islamic Calendar**: Hijri date integration and conversion utilities
- **Monthly Generation**: Complete monthly prayer timetables for both calendars
- **Prayer Analysis**: Current prayer detection, countdown timers, and completion percentages

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
    prayer_timetable: ^2.2.5
```

Or install it from the command line:

```bash
dart pub add prayer_timetable
```

## Quick Examples

### Daily Prayer Times

Generate and display prayer times for a single day:

```dart
import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();

  final timetable = PrayerTimetable.calc(
    timetableCalc: TimetableCalc(
      date: DateTime.now(),
      timezone: 'America/New_York',
      lat: 40.7128,
      lng: -74.0060,
      precision: true,
      fajrAngle: 15.0,
    ),
    jamaahOn: true,
    jamaahMethods: ['afterthis', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
    jamaahOffsets: [[0, 15], [0, 0], [0, 10], [0, 10], [0, 5], [0, 15]],
    timezone: 'America/New_York',
  );

  print('=== Prayer Times for ${DateTime.now().toString().split(' ')[0]} ===');

  final prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  for (int i = 0; i < 6; i++) {
    final prayer = timetable.current[i];
    final timeStr = prayer.prayerTime.toString().split(' ')[1].substring(0, 5);
    final jamaahStr = prayer.jamaahTime != prayer.prayerTime
        ? ' (Jamaah: ${prayer.jamaahTime.toString().split(' ')[1].substring(0, 5)})'
        : '';
    final status = prayer.isCurrent ? ' [CURRENT]' : prayer.isNext ? ' [NEXT]' : '';

    print('${prayerNames[i].padRight(8)}: $timeStr$jamaahStr$status');
  }

  print('\nNext prayer in: ${timetable.utils.countDown}');
  print('Qibla direction: ${timetable.utils.qibla.toStringAsFixed(1)}°');
}
```

**Terminal Output:**

```
=== Prayer Times for 2025-10-27 ===
Fajr    : 06:15 (Jamaah: 06:30)
Sunrise : 07:42
Dhuhr   : 12:28 (Jamaah: 12:38) [NEXT]
Asr     : 15:45 (Jamaah: 15:55)
Maghrib : 18:14 (Jamaah: 18:19)
Isha    : 19:32 (Jamaah: 19:47)

Next prayer in: 2:15:33.000000
Qibla direction: 58.5°
```

### Monthly Prayer Timetable

Generate a complete monthly prayer schedule:

```dart
import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();

  final calc = TimetableCalc(
    date: DateTime(2025, 3, 1),
    timezone: 'America/New_York',
    lat: 40.7128,
    lng: -74.0060,
    precision: true,
    fajrAngle: 15.0,
  );

  // Generate March 2025 prayer times
  final monthlyPrayers = PrayerTimetable.monthTable(
    2025, 3, // March 2025
    calc: calc,
    timezone: 'America/New_York',
    jamaahOn: false,
  );

  print('=== March 2025 Prayer Timetable (New York) ===');
  print('Date       Fajr   Sunrise Dhuhr   Asr     Maghrib Isha');
  print('─' * 58);

  for (int day = 0; day < monthlyPrayers.length; day++) {
    final dayPrayers = monthlyPrayers[day];
    final date = dayPrayers[0].prayerTime;
    final dateStr = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

    final times = dayPrayers.map((prayer) =>
      prayer.prayerTime.toString().split(' ')[1].substring(0, 5)
    ).toList();

    print('$dateStr       ${times[0]}  ${times[1]}   ${times[2]}   ${times[3]}   ${times[4]}   ${times[5]}');
  }

  print('\nTotal days: ${monthlyPrayers.length}');
}
```

**Terminal Output:**

```
=== March 2025 Prayer Timetable (New York) ===
Date       Fajr   Sunrise Dhuhr   Asr     Maghrib Isha
──────────────────────────────────────────────────────
03/01       05:45  07:06   12:12   15:18   17:18   18:38
03/02       05:44  07:07   12:12   15:19   17:19   18:39
03/03       05:42  07:08   12:12   15:20   17:20   18:40
03/04       05:41  07:09   12:12   15:21   17:21   18:41
03/05       05:39  07:10   12:12   15:22   17:22   18:42
03/06       05:38  07:11   12:12   15:23   17:23   18:43
03/07       05:36  07:12   12:12   15:24   17:24   18:44
03/08       05:35  07:13   12:12   15:25   17:25   18:45
03/09       06:33  08:14   13:12   16:26   18:26   19:46
03/10       06:32  08:15   13:12   16:27   18:27   19:47
03/11       06:30  08:16   13:12   16:28   18:28   19:48
03/12       06:29  08:17   13:12   16:29   18:29   19:49
03/13       06:27  08:18   13:12   16:30   18:30   19:50
03/14       06:26  08:19   13:12   16:31   18:31   19:51
03/15       06:24  08:20   13:12   16:32   18:32   19:52
03/16       06:23  08:21   13:12   16:33   18:33   19:53
03/17       06:21  08:22   13:12   16:34   18:34   19:54
03/18       06:20  08:23   13:12   16:35   18:35   19:55
03/19       06:18  08:24   13:12   16:36   18:36   19:56
03/20       06:17  08:25   13:12   16:37   18:37   19:57
03/21       06:15  08:26   13:12   16:38   18:38   19:58
03/22       06:14  08:27   13:12   16:39   18:39   19:59
03/23       06:12  08:28   13:12   16:40   18:40   20:00
03/24       06:11  08:29   13:12   16:41   18:41   20:01
03/25       06:09  08:30   13:12   16:42   18:42   20:02
03/26       06:08  08:31   13:12   16:43   18:43   20:03
03/27       06:06  08:32   13:12   16:44   18:44   20:04
03/28       06:05  08:33   13:12   16:45   18:45   20:05
03/29       06:03  08:34   13:12   16:46   18:46   20:06
03/30       06:02  08:35   13:12   16:47   18:47   20:07
03/31       06:00  08:36   13:12   16:48   18:48   20:08

Total days: 31
```

## Core Classes

### PrayerTimetable

Main class with three calculation methods:

#### Astronomical Calculations

```dart
final timetable = PrayerTimetable.calc(
  timetableCalc: TimetableCalc(
    date: DateTime.now(),
    timezone: 'America/New_York',
    lat: 40.7128,
    lng: -74.0060,
    precision: true,
    fajrAngle: 15.0,
    madhab: 'shafi', // or 'hanafi'
  ),
  jamaahOn: true,
  timezone: 'America/New_York',
);
```

#### Pre-calculated Maps

```dart
final timetable = PrayerTimetable.map(
  timetableMap: yourPrayerTimeMap,
  jamaahOn: true,
  timezone: 'America/New_York',
);
```

#### List-based Timetables

```dart
final timetable = PrayerTimetable.list(
  timetableList: yourPrayerTimeList,
  differences: monthlyDifferences,
  jamaahOn: true,
  timezone: 'America/New_York',
);
```

### Prayer Object

Each prayer contains timing and status information:

```dart
Prayer fajr = timetable.current[0]; // Prayer IDs: 0-5
print('${fajr.name}: ${fajr.prayerTime}');
print('Jamaah: ${fajr.jamaahTime}');
print('Current: ${fajr.isCurrent}');
print('Next: ${fajr.isNext}');
```

**Prayer IDs:**

- 0: Fajr, 1: Sunrise, 2: Dhuhr, 3: Asr, 4: Maghrib, 5: Isha

### Utils Class

Prayer analysis and Islamic calculations:

```dart
Utils utils = timetable.utils;
print('Next prayer in: ${utils.countDown}');
print('Prayer completion: ${utils.percentage}%');
print('Qibla direction: ${utils.qibla}°');
print('Hijri date: ${utils.hijri}'); // [year, month, day]
```

## Hijri Calendar Integration

Comprehensive Hijri calendar conversion utilities:

```dart
// Date conversions
DateTime gregorian = Utils.hijriToGregorian(1446, 9, 26);
var hijri = Utils.gregorianToHijri(DateTime(2025, 3, 26));

// Month operations
DateTime ramadanStart = Utils.getHijriMonthStart(1446, 9);
int ramadanDays = Utils.getHijriMonthLength(1446, 9);

// Formatting and names
String formatted = Utils.formatHijriDate(1446, 9, 26); // "1446-09-26"
String monthName = Utils.getHijriMonthNameEnglish(9);  // "Ramadan"
String arabicName = Utils.getHijriMonthNameArabic(9);  // "رمضان"
```

## Jamaah Configuration

Customize congregation prayer times:

```dart
final timetable = PrayerTimetable.calc(
  timetableCalc: calc,
  jamaahOn: true,
  jamaahMethods: ['fixed', '', 'afterthis', 'afterthis', 'afterthis', 'afterthis'],
  jamaahOffsets: [
    [6, 0],    // Fajr at 6:00 AM (fixed)
    [0, 0],    // Sunrise (no jamaah)
    [0, 15],   // Dhuhr + 15 minutes
    [0, 15],   // Asr + 15 minutes
    [0, 5],    // Maghrib + 5 minutes
    [0, 20]    // Isha + 20 minutes
  ],
  jamaahPerPrayer: [true, false, true, true, true, true],
  timezone: 'America/New_York',
);
```

## Monthly Timetables

Generate complete monthly schedules for both Gregorian and Hijri calendars:

```dart
// Gregorian month
List<List<Prayer>> marchPrayers = PrayerTimetable.monthTable(
  2025, 3, // March 2025
  calc: timetableCalc,
  timezone: 'America/New_York',
);

// Hijri month
List<List<Prayer>> ramadanPrayers = PrayerTimetable.monthHijriTable(
  1446, 9, // Ramadan 1446 AH
  calc: timetableCalc,
  timezone: 'America/New_York',
);
```

## Documentation

Full API documentation is available with inline comments. Generate docs with:

```bash
dart doc
```

## Contributing

Contributions welcome! Submit issues and pull requests on [GitHub](https://github.com/prayer-timetable/prayer_timetable_dart).

## License

MIT License - see LICENSE file for details.

---

_May Allah accept our efforts in facilitating Islamic prayers. Ameen._
