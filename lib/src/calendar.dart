// The calendar the Véda family shares: the solstices and equinoxes, seasons,
// clock changes, moon phases, and the holidays of the day. Pure functions of
// their inputs, so every rule here is testable. Holidays are computed, never
// fetched, so nothing about the day leaves the phone.
//
// The lunar holidays (Eid, Passover, Hanukkah, Diwali, Holi, Vesak, Lunar New
// Year) are not in this file yet: they need their own calendar arithmetic.

DateTime _fromJulian(double jd) => DateTime.fromMillisecondsSinceEpoch(
  ((jd - 2440587.5) * 86400000).round(),
  isUtc: true,
);

enum SkyEvent { marchEquinox, juneSolstice, septemberEquinox, decemberSolstice }

/// When [event] falls in [year] (UTC): Meeus's mean-value formula, accurate
/// to well under an hour for this century.
DateTime skyEventUtc(SkyEvent event, int year) {
  final y = (year - 2000) / 1000;
  final y2 = y * y, y3 = y2 * y, y4 = y3 * y;
  final jde = switch (event) {
    SkyEvent.marchEquinox =>
      2451623.80984 + 365242.37404 * y + 0.05169 * y2 - 0.00411 * y3 - 0.00057 * y4,
    SkyEvent.juneSolstice =>
      2451716.56767 + 365241.62603 * y + 0.00325 * y2 + 0.00888 * y3 - 0.00030 * y4,
    SkyEvent.septemberEquinox =>
      2451810.21715 + 365242.01767 * y - 0.11575 * y2 + 0.00337 * y3 + 0.00078 * y4,
    SkyEvent.decemberSolstice =>
      2451900.05952 + 365242.74049 * y - 0.06223 * y2 - 0.00823 * y3 + 0.00032 * y4,
  };
  return _fromJulian(jde);
}

/// The solstice or equinox falling on [localDay]'s date, if any.
SkyEvent? skyEventOn(DateTime localDay) {
  for (final event in SkyEvent.values) {
    final at = skyEventUtc(event, localDay.year).toLocal();
    if (at.year == localDay.year &&
        at.month == localDay.month &&
        at.day == localDay.day) {
      return event;
    }
  }
  return null;
}

/// +1 when the clocks sprang forward overnight, -1 when they went back,
/// 0 otherwise, from the UTC offsets at noon yesterday and noon today.
int clockChange(Duration yesterdayOffset, Duration todayOffset) =>
    todayOffset.compareTo(yesterdayOffset).sign;

enum MoonPhase { newMoon, fullMoon }

const _synodicMonthDays = 29.53058867;

/// A known new moon (Jan 6, 2000, 18:14 UTC) as the reference; every other
/// new or full moon is some whole number of synodic months from it. Good to
/// within a few hours for any date this app will run on.
double _moonAge(DateTime localDay) {
  final knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  final noon = DateTime(localDay.year, localDay.month, localDay.day, 12);
  final daysSince = noon.toUtc().difference(knownNewMoon).inHours / 24;
  final age = daysSince % _synodicMonthDays;
  return age < 0 ? age + _synodicMonthDays : age;
}

/// The moon phase on [localDay], if it's close enough to count: within half a
/// day of exactly new or exactly full. Null most days.
MoonPhase? moonPhaseOn(DateTime localDay) {
  final age = _moonAge(localDay);
  if (age < 0.5 || age > _synodicMonthDays - 0.5) return MoonPhase.newMoon;
  if ((age - _synodicMonthDays / 2).abs() < 0.5) return MoonPhase.fullMoon;
  return null;
}

// Southern-hemisphere countries, for season names when no latitude is known.
const _southernCountries = {
  'AR', 'AU', 'BO', 'BW', 'BR', 'CL', 'LS', 'MG', 'MU', 'MW', 'MZ', 'NA', //
  'NZ', 'PE', 'PY', 'SZ', 'UY', 'ZA', 'ZM', 'ZW',
};

bool isSouthern({double? latitude, String? countryCode}) =>
    latitude != null ? latitude < 0 : _southernCountries.contains(countryCode);

enum Season { spring, summer, autumn, winter }

/// The meteorological season [localDay] falls in (whole months: Dec-Feb is
/// northern winter), and the date it began.
({Season season, DateTime start}) seasonOf(
  DateTime localDay, {
  required bool southern,
}) {
  const northern = [
    Season.winter, Season.winter, Season.spring, Season.spring, //
    Season.spring, Season.summer, Season.summer, Season.summer, //
    Season.autumn, Season.autumn, Season.autumn, Season.winter,
  ];
  const flip = {
    Season.winter: Season.summer,
    Season.summer: Season.winter,
    Season.spring: Season.autumn,
    Season.autumn: Season.spring,
  };
  final base = northern[localDay.month - 1];
  // Seasons start in Mar, Jun, Sep and Dec.
  final startMonth = localDay.month - (localDay.month % 3);
  final start = startMonth == 0
      ? DateTime(localDay.year - 1, 12)
      : DateTime(localDay.year, startMonth);
  return (season: southern ? flip[base]! : base, start: start);
}

enum Holiday {
  newYearsDay,
  newYearsEve,
  valentinesDay,
  internationalWomensDay,
  mothersDay,
  fathersDay,
  earthDay,
  easter,
  halloween,
  thanksgiving,
  christmas,
}

DateTime _nthWeekday(int year, int month, int weekday, int n) {
  final first = DateTime(year, month);
  final offset = (weekday - first.weekday + 7) % 7;
  return DateTime(year, month, 1 + offset + 7 * (n - 1));
}

/// Western Easter Sunday in [year], by the Anonymous Gregorian computus.
DateTime easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(year, month, day);
}

/// The holiday on [localDay] from the holidays computed here: universal ones,
/// the regional ones for [countryCode], and Easter. Null on most days.
Holiday? holidayOn(DateTime localDay, {String? countryCode}) {
  final y = localDay.year, m = localDay.month, d = localDay.day;
  bool on(DateTime t) => t.month == m && t.day == d;

  // Universal holidays
  if (m == 1 && d == 1) return Holiday.newYearsDay;
  if (m == 12 && d == 31) return Holiday.newYearsEve;
  if (m == 2 && d == 14) return Holiday.valentinesDay;
  if (m == 3 && d == 8) return Holiday.internationalWomensDay;
  if (m == 4 && d == 22) return Holiday.earthDay;
  if (m == 10 && d == 31) return Holiday.halloween;
  if (on(easterSunday(y))) return Holiday.easter;

  // Western holidays (regional)
  if (countryCode == 'US' || countryCode == 'CA' || countryCode == 'GB') {
    if (on(_nthWeekday(y, 5, DateTime.sunday, 2))) return Holiday.mothersDay;
    if (on(_nthWeekday(y, 6, DateTime.sunday, 3))) return Holiday.fathersDay;
  }
  if (on(_nthWeekday(y, 11, DateTime.thursday, 4))) return Holiday.thanksgiving;
  if (m == 12 && d == 25) return Holiday.christmas;

  return null;
}
