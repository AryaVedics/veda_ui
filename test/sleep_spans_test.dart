import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  DateTime t(int d, int h, [int m = 0]) => DateTime(2026, 11, d, h, m);

  test('the pieces of one night are joined into one', () {
    final nights = mergeSleepSamples([
      SleepSample('c', t(23, 1), t(23, 3)),
      SleepSample('a', t(22, 23), t(23, 0, 30)),
      SleepSample('b', t(23, 0, 30), t(23, 1)),
      SleepSample('d', t(23, 3, 20), t(23, 6, 40)),
    ]);
    expect(nights, hasLength(1));
    expect(nights.single.start, t(22, 23));
    expect(nights.single.end, t(23, 6, 40));
    expect(nights.single.id, 'night-a');
  });

  test('a long wait between two samples makes two nights', () {
    final nights = mergeSleepSamples([
      SleepSample('a', t(22, 23), t(23, 6)),
      SleepSample('b', t(23, 14), t(23, 15)),
      SleepSample('c', t(23, 23), t(24, 7)),
    ]);
    expect(nights, hasLength(3));
    expect(nights.map((n) => n.id), ['night-a', 'night-b', 'night-c']);
  });

  test('empty and backwards samples are left out', () {
    expect(mergeSleepSamples(const []), isEmpty);
    expect(
      mergeSleepSamples([SleepSample('a', t(22, 23), t(22, 23))]),
      isEmpty,
    );
  });
}
