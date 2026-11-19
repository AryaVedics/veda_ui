import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

/// The curve's y at the point of segment [s] a fraction [t] along it, from
/// the cubic's own definition.
double _y(Offset from, SoftSegment s, double t) {
  final u = 1 - t;
  return u * u * u * from.dy +
      3 * u * u * t * s.c1.dy +
      3 * u * t * t * s.c2.dy +
      t * t * t * s.to.dy;
}

void main() {
  const pts = [
    Offset(0, 50),
    Offset(30, 20),
    Offset(60, 80),
    Offset(90, 70),
    Offset(120, 10),
    Offset(150, 40),
  ];

  test(
    'the soft line starts and ends on its points, one piece between each',
    () {
      final segs = softLineSegments(pts);
      expect(segs, hasLength(pts.length - 1));
      for (var i = 0; i < segs.length; i++) {
        expect(
          segs[i].to,
          pts[i + 1],
          reason: 'passes exactly through a point',
        );
      }
    },
  );

  test('it never swells past the readings either side of it', () {
    final segs = softLineSegments(pts);
    for (var i = 0; i < segs.length; i++) {
      final lo = math.min(pts[i].dy, pts[i + 1].dy);
      final hi = math.max(pts[i].dy, pts[i + 1].dy);
      for (var k = 0; k <= 20; k++) {
        final y = _y(pts[i], segs[i], k / 20);
        expect(y, inInclusiveRange(lo - 1e-9, hi + 1e-9));
      }
    }
  });

  test('a flat run stays flat, and the line moves left to right only', () {
    const flat = [
      Offset(0, 40),
      Offset(20, 40),
      Offset(40, 40),
      Offset(60, 10),
    ];
    final segs = softLineSegments(flat);
    expect(segs[0].c1.dy, 40);
    expect(segs[0].c2.dy, 40);
    for (final s in softLineSegments(pts)) {
      expect(s.c1.dx, lessThanOrEqualTo(s.c2.dx));
    }
  });

  test('one point or none draws nothing; two are a straight line', () {
    expect(softLineSegments(const [Offset(5, 5)]), isEmpty);
    expect(softLineSegments(const []), isEmpty);
    final two = softLineSegments(const [Offset(0, 0), Offset(30, 60)]);
    expect(two.single.to, const Offset(30, 60));
    expect(softLinePath(const []).getBounds(), Rect.zero);
  });
}
