# The message carousel: where it goes and how big it is

The rule, taken from Véda's own Today tab. It holds for every Véda app.

## Where

- At the top of the Today page, directly under the header and the date, and
  above the centrepiece (the ring, the heart, the dial, the wheel).
- Never at the bottom of the page, and never down among the scrolling cards.
- In Véda it sits in the row beside the Skin Score ring. The other apps have no
  ring in that row, so it takes the full width of the same slot.

## How big

- The message box is 112 high, with a 3px track beneath it that shows which
  message you are on. There is no card behind it.
- On the left, the app's own mark, in a column about a third of the width, the
  same as Véda's ring. The message box takes the rest of the row.
- Each message is an icon and a line of text at 11.5, with a × to dismiss it.

## How it behaves

- A message shows once it first appears, stays for fourteen days from then, and
  is gone for good once dismissed (`NoticeCarousel`, in
  `lib/src/notice_carousel.dart`).
- New messages for the user go into this carousel as another entry in the app's
  list. They never get a card of their own.

## The rings beside the messages

- Every accessory app's ring has a gradient. The arc runs from a faint start to
  full colour at its end, or follows the scale (the UV ring runs yellow to red).
  `MiniRing` requires a gradient, so a plain ring cannot be written.
- Each ring keeps its app's own colour: Lifestyle starlight silver, Routine the
  fireflies' lime, Cycle the period phase's colour, Sun the UV warning's colours.
  Véda's gold is kept for Véda's own ring only.

## Ring ends

- Every ring in the accessory apps has flat ends, not round ones. The arc stops
  square, and a straight glowing end line (as Véda draws it) marks where it has reached. `MiniRing` draws it.
