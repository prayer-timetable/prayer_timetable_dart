import 'package:adhan_dart/adhan_dart.dart' as adhan;

/// A calculator for Islamic prayer times using astronomical algorithms.
///
/// This class wraps the adhan_dart library to provide prayer time calculations
/// based on geographical coordinates, date, and various calculation parameters.
/// It supports different calculation methods, high latitude rules, and madhabs
/// (Islamic jurisprudence schools).
///
/// The class handles string-to-enum conversions for parameters that may come
/// from configuration files or user input as strings, making it more flexible
/// for different use cases.
///
/// Example usage:
/// ```dart
/// final calc = TimetableCalc(
///   date: DateTime.now(),
///   timezone: 'America/New_York',
///   lat: 40.7128,
///   lng: -74.0060,
///   precision: true,
///   fajrAngle: 15.0,
///   highLatitudeRule: 'twilightAngle',
///   madhab: 'shafi',
/// );
///
/// print('Fajr time: ${calc.prayerTimes.fajr}');
/// ```
class TimetableCalc {
  /// Creates a new TimetableCalc instance with the specified parameters.
  ///
  /// [date] - The date for which to calculate prayer times
  /// [timezone] - The timezone identifier (e.g., 'America/New_York')
  /// [lat] - Latitude in decimal degrees
  /// [lng] - Longitude in decimal degrees
  /// [precision] - Whether to use high precision calculations
  /// [fajrAngle] - The angle below horizon for Fajr prayer (typically 15-18 degrees)
  /// [ishaAngle] - The angle below horizon for Isha prayer (defaults to fajrAngle)
  /// [highLatitudeRule] - Rule for high latitude locations as string ('twilightAngle', 'middleOfTheNight', 'seventhOfTheNight')
  /// [madhab] - Islamic jurisprudence school as string ('shafi', 'hanafi')
  /// [adjustments] - Manual time adjustments for each prayer in minutes
  /// [methodAdjustments] - Method-specific adjustments for each prayer in minutes
  TimetableCalc({
    required this.date,
    required this.timezone,
    required this.lat,
    required this.lng,
    required this.precision,
    required this.fajrAngle,
    this.ishaAngle,
    this.highLatitudeRule,
    this.madhab,
    this.adjustments,
    this.methodAdjustments,
  }) : prayerTimes = adhan.PrayerTimes(
          coordinates: adhan.Coordinates(lat, lng),
          date: date,
          calculationParameters: adhan.CalculationParameters(
            method: adhan.CalculationMethod.muslimWorldLeague,
            fajrAngle: fajrAngle,
            ishaAngle: ishaAngle ?? fajrAngle,
            highLatitudeRule: _parseHighLatitudeRule(highLatitudeRule) ??
                adhan.HighLatitudeRule.twilightAngle,
            madhab: _parseMadhab(madhab) ?? adhan.Madhab.shafi,
            adjustments: _parseAdjustments(adjustments) ??
                {
                  adhan.Prayer.fajr: 0,
                  adhan.Prayer.sunrise: 0,
                  adhan.Prayer.dhuhr: 0,
                  adhan.Prayer.asr: 0,
                  adhan.Prayer.maghrib: 0,
                  adhan.Prayer.isha: 0,
                },
            methodAdjustments: _parseAdjustments(methodAdjustments) ??
                {
                  adhan.Prayer.fajr: 0,
                  adhan.Prayer.sunrise: 0,
                  adhan.Prayer.dhuhr: 0,
                  adhan.Prayer.asr: 0,
                  adhan.Prayer.maghrib: 0,
                  adhan.Prayer.isha: 0,
                },
          ),
          precision: precision,
        );

  /// The date for which prayer times are calculated
  DateTime date;

  /// The timezone identifier (e.g., 'America/New_York')
  String timezone;

  /// Latitude in decimal degrees
  double lat;

  /// Longitude in decimal degrees
  double lng;

  /// Whether to use high precision calculations
  bool precision;

  /// The calculated prayer times from adhan_dart library
  adhan.PrayerTimes prayerTimes;

  /// The angle below horizon for Fajr prayer (typically 15-18 degrees)
  double fajrAngle;

  /// The angle below horizon for Isha prayer (optional, defaults to fajrAngle)
  double? ishaAngle;

  /// High latitude rule as string ('twilightAngle', 'middleOfTheNight', 'seventhOfTheNight')
  String? highLatitudeRule;

  /// Islamic jurisprudence school as string ('shafi', 'hanafi')
  String? madhab;

  /// Manual time adjustments for each prayer in minutes
  Map<dynamic, dynamic>? adjustments;

  /// Method-specific adjustments for each prayer in minutes
  Map<dynamic, dynamic>? methodAdjustments;

  /// Creates a copy of this TimetableCalc with optionally updated parameters.
  ///
  /// This method is useful for creating variations of the same calculation
  /// with different dates or parameters while preserving the original settings.
  ///
  /// Returns a new TimetableCalc instance with updated prayer times.
  TimetableCalc copyWith({
    DateTime? date,
    String? timezone,
    double? lat,
    double? lng,
    bool? precision,
    double? fajrAngle,
    double? ishaAngle,
    String? highLatitudeRule,
    String? madhab,
    Map<dynamic, dynamic>? adjustments,
    Map<dynamic, dynamic>? methodAdjustments,
  }) =>
      TimetableCalc(
        date: date ?? this.date,
        timezone: timezone ?? this.timezone,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        precision: precision ?? this.precision,
        fajrAngle: fajrAngle ?? this.fajrAngle,
        ishaAngle: ishaAngle ?? this.ishaAngle ?? this.fajrAngle,
        highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
        madhab: madhab ?? this.madhab,
        adjustments: adjustments ?? this.adjustments,
        methodAdjustments: methodAdjustments ?? this.methodAdjustments,
      );

  /// Converts a string representation of high latitude rule to the corresponding enum.
  ///
  /// Supported values (case-insensitive):
  /// - 'middleofthenight' -> HighLatitudeRule.middleOfTheNight
  /// - 'seventhofthenight' -> HighLatitudeRule.seventhOfTheNight
  /// - 'twilightangle' -> HighLatitudeRule.twilightAngle
  ///
  /// Returns null for unrecognized values.
  static adhan.HighLatitudeRule? _parseHighLatitudeRule(String? rule) {
    if (rule == null) return null;
    switch (rule.toLowerCase()) {
      case 'middleofthenight':
        return adhan.HighLatitudeRule.middleOfTheNight;
      case 'seventhofthenight':
        return adhan.HighLatitudeRule.seventhOfTheNight;
      case 'twilightangle':
        return adhan.HighLatitudeRule.twilightAngle;
      default:
        return null;
    }
  }

  /// Converts a string representation of madhab to the corresponding enum.
  ///
  /// Supported values (case-insensitive):
  /// - 'shafi' -> Madhab.shafi
  /// - 'hanafi' -> Madhab.hanafi
  ///
  /// Returns null for unrecognized values.
  static adhan.Madhab? _parseMadhab(String? madhab) {
    if (madhab == null) return null;
    switch (madhab.toLowerCase()) {
      case 'shafi':
        return adhan.Madhab.shafi;
      case 'hanafi':
        return adhan.Madhab.hanafi;
      default:
        return null;
    }
  }

  /// Converts a dynamic map of prayer adjustments to a typed map.
  ///
  /// The input map should have prayer names as keys (strings) and
  /// adjustment values in minutes as values (integers).
  ///
  /// Example input: {'fajr': 2, 'dhuhr': -1, 'asr': 0}
  ///
  /// Returns null if the input is null or results in an empty map.
  static Map<adhan.Prayer, int>? _parseAdjustments(
      Map<dynamic, dynamic>? adjustments) {
    if (adjustments == null) return null;
    Map<adhan.Prayer, int> result = {};

    adjustments.forEach((key, value) {
      adhan.Prayer? prayer = _parsePrayer(key.toString());
      if (prayer != null && value is int) {
        result[prayer] = value;
      }
    });

    return result.isEmpty ? null : result;
  }

  /// Converts a string representation of prayer name to the corresponding enum.
  ///
  /// Supported values (case-insensitive):
  /// - 'fajr' -> Prayer.fajr
  /// - 'sunrise' -> Prayer.sunrise
  /// - 'dhuhr' -> Prayer.dhuhr
  /// - 'asr' -> Prayer.asr
  /// - 'maghrib' -> Prayer.maghrib
  /// - 'isha' -> Prayer.isha
  ///
  /// Returns null for unrecognized values.
  static adhan.Prayer? _parsePrayer(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return adhan.Prayer.fajr;
      case 'sunrise':
        return adhan.Prayer.sunrise;
      case 'dhuhr':
        return adhan.Prayer.dhuhr;
      case 'asr':
        return adhan.Prayer.asr;
      case 'maghrib':
        return adhan.Prayer.maghrib;
      case 'isha':
        return adhan.Prayer.isha;
      default:
        return null;
    }
  }
}
