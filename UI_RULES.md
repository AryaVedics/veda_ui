# UI rules for the Véda family

## Centrepiece choice (Lifestyle, and any app with a switchable centrepiece)

- The app always opens on the centrepiece the person last chose in Profile.
  Until they choose one there, it opens on the default (the heart in Lifestyle).
- Switching the centrepiece on the Today card changes the view for that session
  only. It does not change the saved choice.
- Only a choice made in Profile is saved, and it becomes the new default.

## Message rings and carousels

- See NOTICES.md: the message carousel's place and size, and the gradient on
  every accessory ring.

## Petal charts

- Any petal chart, filled or empty, is drawn as an "X" when the number of petals
  is even, never a cross. The first petal starts half a step round.
- The rule lives in one place: `petalOffsetDegrees` in
  `lib/src/metric_ghost.dart`. Use it, don't write a new one.

## Trend lines

- Skin Score trend lines follow Véda's: smooth, curved lines between the points,
  never sharp straight segments or jagged joins.
- Every accessory app's trend chart draws its line the same way as Véda's
  Trends chart. Véda's chart is the reference.

## Véda is the basis

- Véda's standards are the basis of the UI. Where an accessory app differs from
  Véda in size, shape, edge, end cap or placement, Véda wins.
- The message ring is Véda's size (132), has Véda's thin edge rings, flat arc
  ends and straight glowing end line, and sits at the left edge with a 20 gap
  before the message box.

## The top of every page (Véda's exact measures)

Every screen of every Véda app starts the way Véda's does. New apps copy these
numbers; do not eyeball them.

- Header: title in the display font at 23, the app medallion at the right.
  Medallion 56 with 4 tap padding, its word under it at 11, letter spacing 2,
  muted, pulled up 6, with the small caret. `ScreenHeader` and `VedaLockup`
  draw this; use them, never a lookalike.
- Top padding of the page is 24, sides 20. The gap between the header and what
  follows is 14 (`PinnedHeaderList` already adds it).
- No date line under the header. Today pages go straight from the header to the
  message row.
- Message row, directly under the header: the ring (132) at the left edge, a 20
  gap, then the message box filling the rest, 112 high, with the 3px track 8
  below it when there is more than one message. Ring and box are centred on the
  same line. `NoticeCarousel` + `MiniRing` draw this.
- The ring has Véda's thin edge rings, flat arc ends and the straight glowing
  end line, in a gradient of the app's own colour.

## Rings: colours, tracks and captions

- Every accessory ring has its own colour and its own dark track, set once as
  `ringTrack` in the app's `VedaBrand`. The track is a deep shade from the app's
  own colour family (Lifestyle navy, Routine forest green, Cycle plum-rose, Sun
  ember brown), never Véda's gold-brown, which turns muddy beside any other
  colour. Do not pass a track colour at the call site; change the brand.
- The caption under the number says what the number is in full words ("days to
  period", "of 5", "wellness", "UV peak"). A long caption shrinks to fit inside
  the ring; it never touches the edge.
- The glass look is for Véda's main Skin Score ring only, and only in Véda.
  Nothing in the accessory apps uses it. It is soft on purpose: a gentle inner glow, a faint
  gold halo just outside the ring, and a gloss along the band. Keep the inner light low so it never outshines the number.

## Pages

- No date line under a page header, on any tab. A date belongs in a card that
  is about that day, never as a subtitle under the header.
- A line chart is always drawn smooth, with a dot on each reading and a ringed
  marker on the latest, exactly as Véda's Trends chart (the shared `TrendChart`).

## Life in the centrepiece

- A centrepiece that is a line (Lifestyle's Pulse) draws itself out like an ECG
  whenever it first appears, either as the app opens on it or when the user
  switches to it. Afterwards, every five to seven seconds, one small bright dash
  runs along the line from end to end. With reduced motion it is drawn at once
  and stays still.
- Surprises stay rare and brief (see Routine's forest friends).

## The background medallion

- Every page of every Véda app has the app's medallion faintly behind it: 5%
  opacity, anchored to the bottom of the page, moved 22 down so a sliver hides
  under the tab bar, and as wide as the screen, so the medallion's outer ring
  spans the full width. `BrandWatermark` draws it; do not place it any other way.
- An app whose header mark carries extra glow, fireflies or an orbit round the
  medallion (Routine) would sit smaller in the same box. Such an app sets
  `watermarkAsset` in its `VedaBrand` to plain art drawn like the others, with the
  outer ring full width. Routine's is `routine_watermark.png` (orbit ring, sun and
  moon, no glow or fireflies).
