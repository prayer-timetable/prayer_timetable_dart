/// Example usage of the prayer_timetable library
///
/// This example demonstrates the main features of the library including:
/// - Astronomical prayer time calculations
/// - Jamaah time management
/// - Prayer analysis and utilities
/// - Qibla direction calculation
/// - Hijri calendar integration

import 'package:prayer_timetable/prayer_timetable.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  // Initialize timezone data (required for timezone calculations)
  tz.initializeTimeZones();

  print('=== Prayer Timetable Library Example ===\n');

  // Example 1: Basic astronomical calculations
  basicExample();

  print('\n${'=' * 50}\n');

  // Example 2: Advanced features with jamaah times
  advancedExample();

  print('\n${'=' * 50}\n');

  // Example 3: Monthly prayer timetable
  monthlyExample();
}

/// Basic example showing simple prayer time calculations
void basicExample() {
  print('1. Basic Prayer Time Calculations');
  print('-' * 35);

  // Create a timetable for New York using astronomical calculations
  final timetable = PrayerTimetable.calc(
    timetableCalc: TimetableCalc(
      date: DateTime.now(),
      timezone: 'America/New_York',
      lat: 40.7128, // New York latitude
      lng: -74.0060, // New York longitude
      precision: true,
      fajrAngle: 15.0,
      highLatitudeRule: 'twilightAngle',
      madhab: 'shafi',
    ),
    jamaahOn: false,
    timezone: 'America/New_York',
  );

  // Display today's prayer times
  print('Today\'s Prayer Times (New York):');
  final prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  for (int i = 0; i < 6; i++) {
    Prayer prayer = timetable.current[i];
    String timeStr = '${prayer.prayerTime.hour.toString().padLeft(2, '0')}:'
        '${prayer.prayerTime.minute.toString().padLeft(2, '0')}';
    print('  ${prayerNames[i].padRight(8)}: $timeStr');
  }

  // Show current prayer status
  print('\nPrayer Status:');
  print(
      '  Current prayer ID: ${timetable.utils.currentId} (${prayerNames[timetable.utils.currentId]})');
  print(
      '  Next prayer ID: ${timetable.utils.nextId} (${prayerNames[timetable.utils.nextId]})');
  print(
      '  Time until next prayer: ${formatDuration(timetable.utils.countDown)}');
  print(
      '  Prayer completion: ${timetable.utils.percentage.toStringAsFixed(1)}%');
}

/// Advanced example with jamaah times and additional features
void advancedExample() {
  print('2. Advanced Features with Jamaah Times');
  print('-' * 40);

  // Create a timetable with jamaah times enabled
  final timetable = PrayerTimetable.calc(
    timetableCalc: TimetableCalc(
      date: DateTime.now(),
      timezone: 'Europe/London',
      lat: 51.5074, // London latitude
      lng: -0.1278, // London longitude
      precision: true,
      fajrAngle: 18.0, // Different angle for London
      ishaAngle: 17.0,
      highLatitudeRule: 'twilightAngle',
      madhab: 'hanafi', // Hanafi madhab
    ),
    jamaahOn: true,
    jamaahMethods: [
      'afterthis',
      '',
      'afterthis',
      'afterthis',
      'afterthis',
      'afterthis'
    ],
    jamaahOffsets: [
      [0, 15], // Fajr jamaah 15 minutes after adhan
      [0, 0], // Sunrise (no jamaah)
      [0, 10], // Dhuhr jamaah 10 minutes after adhan
      [0, 10], // Asr jamaah 10 minutes after adhan
      [0, 5], // Maghrib jamaah 5 minutes after adhan
      [0, 20] // Isha jamaah 20 minutes after adhan
    ],
    jamaahPerPrayer: [true, false, true, true, true, true],
    timezone: 'Europe/London',
  );

  // Display prayer and jamaah times
  print('Today\'s Prayer Times (London) with Jamaah:');
  final prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  for (int i = 0; i < 6; i++) {
    Prayer prayer = timetable.current[i];
    String prayerTimeStr =
        '${prayer.prayerTime.hour.toString().padLeft(2, '0')}:'
        '${prayer.prayerTime.minute.toString().padLeft(2, '0')}';

    String output = '  ${prayerNames[i].padRight(8)}: $prayerTimeStr';

    if (prayer.jamaahTime != prayer.prayerTime && i != 1) {
      String jamaahTimeStr =
          '${prayer.jamaahTime.hour.toString().padLeft(2, '0')}:'
          '${prayer.jamaahTime.minute.toString().padLeft(2, '0')}';
      output = '$output (Jamaah: $jamaahTimeStr)';
    }

    print(output);

    if (prayer.jamaahTime != prayer.prayerTime && i != 1) {
      String jamaahTimeStr =
          '${prayer.jamaahTime.hour.toString().padLeft(2, '0')}:'
          '${prayer.jamaahTime.minute.toString().padLeft(2, '0')}';
      print(' (Jamaah: $jamaahTimeStr)');
    } else {
      print('');
    }
  }

  // Islamic information
  print('\nIslamic Information:');
  print(
      '  Qibla direction: ${timetable.utils.qibla.toStringAsFixed(1)}° from North');
  print(
      '  Hijri date: ${timetable.utils.hijri[2]}/${timetable.utils.hijri[1]}/${timetable.utils.hijri[0]}');
  print('  Islamic midnight: ${formatTime(timetable.utils.midnight)}');
  print('  Last third of night: ${formatTime(timetable.utils.lastThird)}');
}

/// Example showing monthly prayer timetable generation
void monthlyExample() {
  print('3. Monthly Prayer Timetable');
  print('-' * 28);

  // Generate monthly prayer times for current month
  final now = DateTime.now();
  final monthlyPrayers = PrayerTimetable.monthTable(
    now.year,
    now.month,
    calc: TimetableCalc(
      date: now,
      timezone: 'Asia/Dubai',
      lat: 25.2048, // Dubai latitude
      lng: 55.2708, // Dubai longitude
      precision: true,
      fajrAngle: 18.0,
    ),
    timezone: 'Asia/Dubai',
    jamaahOn: false,
  );

  print(
      'Monthly Prayer Times for Dubai (${getMonthName(now.month)} ${now.year}):');
  print('Day  Fajr   Sunrise Dhuhr  Asr    Maghrib Isha');
  print('-' * 50);

  // Show first 7 days as example
  for (int day = 0; day < 7 && day < monthlyPrayers.length; day++) {
    List<Prayer> dayPrayers = monthlyPrayers[day];
    String dayStr = (day + 1).toString().padLeft(2);

    String line = '$dayStr   ';
    for (int i = 0; i < 6; i++) {
      String timeStr =
          '${dayPrayers[i].prayerTime.hour.toString().padLeft(2, '0')}:'
          '${dayPrayers[i].prayerTime.minute.toString().padLeft(2, '0')}';
      line += timeStr.padRight(7);
    }
    print(line);
  }

  print('... (showing first 7 days of ${monthlyPrayers.length} total days)');
}

/// Helper function to format Duration as readable string
String formatDuration(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  } else {
    return '${minutes}m';
  }
}

/// Helper function to format DateTime as time string
String formatTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}

/// Helper function to get month name
String getMonthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[month - 1];
}
