/// Timezone utilities for prayer time calculations.
///
/// This file provides functions for working with timezones and creating
/// timezone-aware DateTime objects for accurate prayer time calculations.
library;

import 'package:timezone/timezone.dart' as tz;

/// Creates a timezone-aware DateTime object for the current time or specified time.
///
/// This function creates a TZDateTime object in the specified timezone,
/// either for the current time or for a custom date/time if parameters are provided.
///
/// [timezone] - The timezone identifier (e.g., 'America/New_York', 'Europe/London')
/// [year] - Optional year (defaults to current year)
/// [month] - Optional month (defaults to current month)
/// [day] - Optional day (defaults to current day)
/// [hour] - Optional hour (defaults to current hour)
/// [minute] - Optional minute (defaults to current minute)
/// [second] - Optional second (defaults to current second)
///
/// Returns a timezone-aware DateTime object
DateTime nowTZ(String timezone,
    {int? year, int? month, int? day, int? hour, int? minute, int? second}) {
  tz.setLocalLocation(tz.getLocation(timezone));
  DateTime now = tz.TZDateTime.now(tz.getLocation(timezone));

  DateTime newTime = tz.TZDateTime(
    tz.getLocation(timezone),
    year ?? now.year,
    month ?? now.month,
    day ?? now.day,
    hour ?? now.hour,
    minute ?? now.minute,
    second ?? now.second,
  );

  return newTime;
}

/// Gets the UTC offset in hours for a specific timezone and date.
///
/// This function calculates the UTC offset for a given timezone on January 1st
/// of the specified year. This is useful for timezone calculations and
/// adjustments in prayer time calculations.
///
/// [date] - The date to check the offset for
/// [timezone] - The timezone identifier
///
/// Returns the UTC offset in hours (can be negative)
int offsetHr(
  DateTime date,
  String timezone,
) {
  int offset = tz.TZDateTime(tz.getLocation(timezone), date.year, 1, 1)
      .timeZoneOffset
      .inHours;

  return offset;
}
