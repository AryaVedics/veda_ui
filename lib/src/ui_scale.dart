// Sizes that are the same size on the glass, whatever the phone's display size.
//
// Android counts in dp, and a phone's "display size" setting changes how many
// pixels a dp is: the same 1080-pixel-wide screen is 360 dp across at one
// setting and 485 at another. A fixed 132 dp ring is then a third bigger on the
// first phone than on the second. The centrepieces already scale from the width
// of the screen; the pieces beside them (the ring and the message card) use
// this scale, so they stay in step with them and look alike on every phone.
// Text is left alone: it follows the person's own text-size setting.

import 'package:flutter/widgets.dart';

/// The screen width, in dp, the fixed sizes were drawn for.
const double kReferenceScreenWidth = 411;

/// How much to scale a size drawn for [kReferenceScreenWidth]. Kept within a
/// range, so a very small phone or a tablet never gets an odd size.
double uiScaleOf(BuildContext context) =>
    (MediaQuery.sizeOf(context).width / kReferenceScreenWidth).clamp(0.82, 1.2);
