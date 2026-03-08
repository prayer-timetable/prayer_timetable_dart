# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.5] - 2025-03-08

### Changed

- **Dependency Updates**: Updated package dependencies to latest compatible versions
    - Updated http from 1.5.0 to 1.6.0
    - Updated lints from 6.0.0 to 6.1.0
    - Updated meta from 1.17.0 to 1.18.1
    - Updated source_span from 1.10.1 to 1.10.2

## [2.2.4] - 2025-10-27

### Fixed

- **DST Prayer Time Adjustment**: Fixed `adjDst` calculation in prayers.dart to properly add one hour to all prayer times during daylight saving time periods
    - Replaced hardcoded `adjDst = 0` with dynamic DST detection using `timestamp.timeZone.isDst`
    - Prayer times from timetable maps now correctly adjust for DST transitions
    - Ensures accurate prayer time display during DST periods across all supported timezones

### Improved

- **Code Quality**: Cleaned up prayers.dart file by removing unnecessary comments, debug prints, and commented-out test code
- **Documentation**: Enhanced inline documentation throughout prayers.dart with detailed explanations of:
    - DST adjustment logic and timezone handling
    - Prayer time calculation methods (map, list, astronomical)
    - Jamaah time calculation with different methods ('afterthis', 'fixed')
    - Prayer joining functionality for combined prayers
    - Current/next prayer determination algorithms

### Technical Details

- Removed unused `timestampTZsafe` variable and associated commented code
- Added comprehensive inline comments explaining complex prayer time logic
- Improved code readability while maintaining all existing functionality
- All prayer time calculations now properly respect DST status of target date

## [2.2.3] - 2025-10-26

### Fixed

- **Critical Timezone Issues**: Resolved fundamental timezone conversion problems affecting all European timezones
    - Fixed `nowTZ` function that was incorrectly treating local DateTime as UTC time
    - Fixed `tz.TZDateTime.from()` usage in multiple functions that caused unwanted timezone conversions
    - Corrected timezone handling in `prayers.dart`, `monthGen.dart`, `tzTime.dart`, and test files
    - Fixed prayer time calculations showing incorrect times (e.g., 18:59:55 instead of 17:59:55)
- **DST Transition Accuracy**: Ensured proper Daylight Saving Time transitions for all supported timezones
    - Dublin: IST (+1) → GMT (+0) transition working correctly
    - Sarajevo: CEST (+2) → CET (+1) transition working correctly
    - London: BST (+1) → GMT (+0) transition working correctly
- **DST Prayer Time Calculation**: Fixed critical issue where prayer times were calculated one hour early during DST periods
    - Fixed DST adjustment logic to use target date's DST status instead of current timestamp
    - Resolved issue where Friday evening prayers for Saturday were showing incorrect times (e.g., 05:24 instead of 06:24)
    - Ensured prayer times are correctly adjusted for DST throughout transition periods
- **Test Suite Consistency**: Updated all test files to use correct timezone-aware DateTime creation
- **Cross-timezone Compatibility**: Verified accurate prayer time calculations across multiple European timezones

### Technical Details

- Replaced `tz.TZDateTime.from(DateTime(...), location)` with `tz.TZDateTime(location, year, month, day, hour, minute, second)`
- Fixed timezone conversion logic in 6 different files affecting core prayer time calculations
- Enhanced timezone handling for both map-based and calculation-based prayer time methods

## [2.2.2] - 2025-10-26

### Fixed

- **Documentation Quality**: Fixed unresolved documentation references that could impact pub.dev scoring
    - Fixed `[hours, minutes]` reference in `defaultJamaahOffsets` documentation
    - Fixed `[year, month, day]` references in Utils class documentation
    - Improved documentation clarity for Hijri calendar functions

## [2.2.1] - 2025-10-26

### Added

- **Comprehensive Monthly Table Documentation**: Detailed examples and usage for both Gregorian and Hijri monthly prayer table generation
    - Clear separation between `PrayerTimetable.monthTable()` and `PrayerTimetable.monthHijriTable()` methods
    - Integration examples showing how to use Utils Hijri conversion methods with monthly tables
    - Dual calendar display examples (showing both Hijri and Gregorian dates)
    - Performance optimization documentation for pre-calculated timetables

### Fixed

- Minor code quality improvements in test files
- Removed unused variables and unnecessary string interpolation braces

## [2.2.0] - 2025-10-26

### Added

- **Hijri Calendar Conversion Functions**: Comprehensive static methods in Utils class for Hijri calendar operations
    - `Utils.hijriToGregorian(year, month, day)` - Convert specific Hijri dates to Gregorian
    - `Utils.gregorianToHijri(DateTime)` - Convert Gregorian dates to Hijri
    - `Utils.getHijriMonthStart(year, month)` - Get first day of Hijri month in Gregorian
    - `Utils.getHijriMonthEnd(year, month)` - Get last day of Hijri month in Gregorian
    - `Utils.getHijriMonthLength(year, month)` - Get number of days in Hijri month
    - `Utils.getHijriYearStart(year)` - Get first day of Hijri year (1st Muharram)
    - `Utils.getHijriYearEnd(year)` - Get last day of Hijri year (last day of Dhul Hijjah)
    - `Utils.formatHijriDate(year, month, day)` - Format Hijri dates as "YYYY-MM-DD" strings
    - `Utils.getHijriMonthNameEnglish(month)` - Get English month names (e.g., "Ramadan")
    - `Utils.getHijriMonthNameArabic(month)` - Get Arabic month names (e.g., "رمضان")
- Enhanced documentation with comprehensive Hijri conversion examples
- Full API documentation for all new Hijri calendar functions

### Changed

- Moved Hijri conversion functions from helpers to Utils class as static methods for better organization
- Updated README with detailed Hijri calendar conversion section and examples
- Improved code organization by centralizing Islamic calendar utilities in Utils class

### Fixed

- **DST Calculation Bug**: Corrected Daylight Saving Time logic for Dublin timezone that was incorrectly adding hours instead of subtracting during DST end transition
- Prayer time adjustments now properly handle DST transitions, ensuring accurate times during timezone changes
- Verified DST behavior for October 26, 2025 transition and other DST boundary dates

### Technical Details

- All Hijri functions are now accessible via `Utils.functionName()` syntax
- Functions support both individual date conversions and bulk month/year operations
- Comprehensive error handling and input validation for all date parameters
- Full compatibility with existing hijri package for accurate calendar calculations

## [2.1.0] - 2024-12-19

### Added

- Comprehensive inline documentation for all classes, methods, and properties
- Complete API documentation with parameter explanations and usage examples
- Enhanced README with detailed usage examples and feature explanations
- Support for string-based enum parameters in TimetableCalc (highLatitudeRule, madhab)
- Helper methods for converting string parameters to proper enum types
- Detailed prayer ID documentation and explanation
- Islamic context documentation for developers unfamiliar with prayer times

### Changed

- Improved type safety throughout the codebase
- Enhanced error handling and parameter validation
- Updated README to reflect current API and features
- Modernized package structure and documentation standards

### Fixed

- Type conversion issues in TimetableCalc constructor
- Null assertion warnings in prayer time calculations
- Enum parameter handling for configuration flexibility
- All linting issues and type safety warnings

### Documentation

- Added comprehensive class-level documentation
- Documented all public APIs with examples
- Added parameter descriptions for all methods
- Included Islamic prayer time concepts explanation
- Added timezone and DST handling documentation

## [2.0.0] - 2024-03-15

### Added

- Multiple calculation methods support (astronomical, map-based, list-based)
- Jamaah (congregation) time management with customizable offsets
- Full timezone support with automatic DST handling
- Prayer joining functionality (Dhuhr-Asr, Maghrib-Isha)
- Monthly prayer time generation for Gregorian and Hijri calendars
- Prayer status analysis (current, next, pending jamaah)
- Qibla direction calculation using coordinates
- Hijri calendar integration
- Sunnah time calculations (Islamic midnight, last third of night)

### Changed

- Complete rewrite of the prayer calculation engine
- Improved accuracy using adhan_dart library
- Enhanced timezone handling with proper DST support
- Modernized API design with multiple constructor patterns

### Breaking Changes

- New API structure with PrayerTimetable.calc(), .map(), .list() constructors
- Prayer objects now use arrays instead of named properties
- Utils class replaces separate Calc, Sunnah, and Qibla classes
- Updated parameter names and types for consistency

## [1.5.0] - 2023-08-20

### Added

- High latitude calculation rules support
- Madhab selection (Shafi, Hanafi) for Asr calculation
- Prayer time adjustments and method adjustments
- Precision control for seconds display
- Enhanced DST calculation accuracy

### Changed

- Improved astronomical calculation precision
- Better handling of extreme latitude locations
- Enhanced date and time manipulation utilities

### Fixed

- DST calculation issues in certain timezones
- Precision rounding in prayer time calculations
- Edge cases in high latitude regions

## [1.4.0] - 2023-05-10

### Added

- Custom calculation parameters support
- Multiple calculation methods (Muslim World League, ISNA, etc.)
- Altitude-based prayer time adjustments
- Enhanced debugging and logging capabilities

### Changed

- Refactored calculation engine for better maintainability
- Improved error handling and validation
- Enhanced documentation and code comments

### Fixed

- Memory leaks in continuous calculations
- Performance issues with repeated calculations
- Timezone offset calculation accuracy

## [1.3.0] - 2023-02-15

### Added

- Hijri calendar support and conversions
- Islamic date utilities and formatting
- Monthly prayer time tables generation
- Prayer time difference calculations

### Changed

- Enhanced DateTime handling and manipulation
- Improved calculation performance
- Better memory management for large datasets

### Fixed

- Leap year calculations in Hijri calendar
- Month boundary issues in prayer calculations
- Timezone conversion edge cases

## [1.2.0] - 2022-11-30

### Added

- Qibla direction calculation from coordinates
- Prayer countdown and count-up timers
- Prayer completion percentage calculation
- Current prayer detection logic

### Changed

- Improved prayer time analysis algorithms
- Enhanced user interface for prayer status
- Better integration with timezone libraries

### Fixed

- Prayer transition timing accuracy
- Current prayer detection edge cases
- Timer synchronization issues

## [1.1.0] - 2022-09-15

### Added

- Sunnah time calculations (midnight, last third)
- Prayer period end time calculations
- Enhanced prayer status tracking
- Timezone-aware calculations

### Changed

- Refactored core calculation logic
- Improved code organization and structure
- Enhanced testing coverage

### Fixed

- Prayer end time calculation accuracy
- Sunnah time calculation in different seasons
- Edge cases in prayer period detection

## [1.0.0] - 2022-06-01

### Added

- Initial release of prayer_timetable library
- Basic prayer time calculations using astronomical formulas
- Support for five daily prayers plus sunrise
- Timezone and DST support
- Coordinate-based calculations
- Customizable calculation angles (Fajr, Isha)
- Prayer time formatting and display utilities

### Features

- Accurate astronomical calculations based on Jean Meeus algorithms
- Support for different geographic locations
- Customizable prayer calculation parameters
- DateTime integration for easy time manipulation
- Cross-platform compatibility (Dart/Flutter)

---

## Version History Summary

- **v2.1.0**: Documentation overhaul and type safety improvements
- **v2.0.0**: Major rewrite with multiple calculation methods and jamaah support
- **v1.5.0**: High latitude rules and madhab selection
- **v1.4.0**: Custom calculation parameters and multiple methods
- **v1.3.0**: Hijri calendar integration and monthly tables
- **v1.2.0**: Qibla calculation and prayer analysis
- **v1.1.0**: Sunnah times and enhanced status tracking
- **v1.0.0**: Initial release with core prayer calculations

## Migration Guide

### From v1.x to v2.0.0

The v2.0.0 release introduced breaking changes to improve the API design:

```dart
// Old API (v1.x)
PrayerTimetable location = PrayerTimetable(timezone, lat, lng, angle);
print(location.prayers.current.dawn);

// New API (v2.0.0+)
final timetable = PrayerTimetable.calc(
  timetableCalc: TimetableCalc(
    date: DateTime.now(),
    timezone: 'America/New_York',
    lat: lat,
    lng: lng,
    precision: true,
    fajrAngle: angle,
  ),
  jamaahOn: false,
  timezone: 'America/New_York',
);
print(timetable.current[0].prayerTime); // Fajr
```

### Key Changes:

- Use constructor methods: `.calc()`, `.map()`, `.list()`
- Prayer times are now arrays: `current[0]` instead of `current.dawn`
- Utils class combines Calc, Sunnah, and Qibla functionality
- Enhanced timezone handling with string identifiers
