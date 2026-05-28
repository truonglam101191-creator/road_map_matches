## 1.1.0

* Added `ConnectorLineType` enum supporting `solid` (default) and `flowing` (animated moving dashes) connection styles.
* Optimized dash-flowing phase shifting to run monotonically forward-only (left-to-right) without reversing or rocking back/forth.
* Added `searchHighlightQuery` supporting real-time competitor search and highlight trail. Connected paths for matched competitors automatically highlight using the custom `accentColor` (defaults to Gold `#FFB300`).
* Added dynamic flowing dash customizations: `dashLength` (defaults to `12.0`), `dashGap` (defaults to `8.0`), and `dashSpeedMultiplier` (defaults to `1.0`).
* Fully updated Settings Panel in the example app with dynamic Height animation transition, input text field for searching, and slider controls for dash styling.
* Formatted all source files using standard format rules.

## 1.0.0

* Initial release of `road_map`.
* Premium, high-performance, and highly customizable generic tournament bracket (road map) library for Flutter.
* Supports dynamic infinite rounds, interactive horizontal swipe navigation, and premium sliding tab selectors.
* Fully customizable layout parameters (card width, card height, gaps, top offset).
* Advanced vector line painting with customizable line thickness, active/winning path highlights, and customizable active path glow (width, opacity).
* Fully customizable Round Tab Bar (custom border color, background color, border radius, tab bar height, custom sliding indicator decoration).
* Made `grandFinal` optional/nullable to easily support open-ended tournament brackets without a final championship card.
* Implemented strict bounds safety checking to gracefully handle mathematically imperfect/non-power-of-2 tournament trees without throwing RangeError.
