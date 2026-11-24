// Apple Health keeps a night of sleep as many small samples (in bed, asleep,
// and the stages of sleep), not one session as Android's Health Connect does.
// The apps need only when a night began and ended, so the samples are joined
// into nights here; nothing about the stages is kept.

/// One sample from the phone's health store: when it began and ended.
class SleepSample {
  const SleepSample(this.id, this.start, this.end);

  final String id;
  final DateTime start;
  final DateTime end;
}

/// Joins [samples] into nights: samples that begin within [gap] of the one
/// before belong to the same night. A night starts where its first sample
/// starts and ends where its last one ends, and is named after its first
/// sample, so the same night is always the same night.
List<SleepSample> mergeSleepSamples(
  Iterable<SleepSample> samples, {
  Duration gap = const Duration(minutes: 60),
}) {
  final sorted = [...samples]..sort((a, b) => a.start.compareTo(b.start));
  final out = <SleepSample>[];
  for (final s in sorted) {
    if (!s.end.isAfter(s.start)) continue;
    if (out.isNotEmpty && s.start.difference(out.last.end) <= gap) {
      final last = out.removeLast();
      out.add(
        SleepSample(
          last.id,
          last.start,
          s.end.isAfter(last.end) ? s.end : last.end,
        ),
      );
    } else {
      out.add(SleepSample('night-${s.id}', s.start, s.end));
    }
  }
  return out;
}
