import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/src/calendar.dart';

void main() {
  test('Easter Sunday matches the published dates', () {
    expect(easterSunday(2024), DateTime(2024, 3, 31));
    expect(easterSunday(2025), DateTime(2025, 4, 20));
    expect(easterSunday(2026), DateTime(2026, 4, 5));
    expect(easterSunday(2027), DateTime(2027, 3, 28));
  });

  test('regional holidays fall on the right weekday', () {
    // US Mother's Day: second Sunday in May, 2026 is May 10.
    expect(
      holidayOn(DateTime(2026, 5, 10), countryCode: 'US'),
      Holiday.mothersDay,
    );
    expect(holidayOn(DateTime(2026, 5, 10), countryCode: 'IN'), isNull);
    // Thanksgiving: fourth Thursday in November, 2026 is November 26.
    expect(holidayOn(DateTime(2026, 11, 26)), Holiday.thanksgiving);
  });

  test('universal and fixed holidays', () {
    expect(holidayOn(DateTime(2026, 1, 1)), Holiday.newYearsDay);
    expect(holidayOn(DateTime(2026, 12, 25)), Holiday.christmas);
    expect(holidayOn(DateTime(2026, 6, 3)), isNull);
  });

  test('equinox and solstice fall on their local day in 2026', () {
    // Each event on the phone's own calendar day, whatever the time zone.
    for (final e in SkyEvent.values) {
      final local = skyEventUtc(e, 2026).toLocal();
      expect(skyEventOn(DateTime(local.year, local.month, local.day)), e);
    }
  });

  test('seasons flip in the southern hemisphere', () {
    expect(
      seasonOf(DateTime(2026, 1, 15), southern: false).season,
      Season.winter,
    );
    expect(
      seasonOf(DateTime(2026, 1, 15), southern: true).season,
      Season.summer,
    );
  });
}
