import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

const _a = NoticeMessage('a', Icons.star, 'First');
const _b = NoticeMessage('b', Icons.star, 'Second');

void main() {
  final start = DateTime(2026, 10, 1, 9);

  test('a new message shows, and its fourteen days start at the first showing', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final shown = await visibleNotices('lifestyle', [_a, _b], now: start, prefs: prefs);
    expect(shown.map((m) => m.id), ['a', 'b']);
    expect(prefs.getInt('notice.lifestyle.a.shownAt'), start.millisecondsSinceEpoch);
  });

  test('a message is gone fourteen days after it first showed', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await visibleNotices('lifestyle', [_a], now: start, prefs: prefs);
    final day13 = await visibleNotices('lifestyle', [_a],
        now: start.add(const Duration(days: 13)), prefs: prefs);
    expect(day13.length, 1);
    final day14 = await visibleNotices('lifestyle', [_a],
        now: start.add(const Duration(days: 14)), prefs: prefs);
    expect(day14, isEmpty);
  });

  test('a dismissed message never comes back, and apps keep their own', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await dismissNotice('lifestyle', _a, prefs: prefs);
    final lifestyle = await visibleNotices('lifestyle', [_a, _b], now: start, prefs: prefs);
    expect(lifestyle.map((m) => m.id), ['b']);
    final routine = await visibleNotices('routine', [_a], now: start, prefs: prefs);
    expect(routine.map((m) => m.id), ['a']);
  });
}
