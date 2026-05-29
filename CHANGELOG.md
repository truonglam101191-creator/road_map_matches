## 1.2.0

* Added `TournamentDrawEngine` helper utility for automatic tournament bracket seeding, symmetric seed distributions, and automated BYE slot calculations.
* Added `includeFinal` option to `TournamentDrawEngine.buildInitialBracket` to easily stop bracket generation at the semifinals stage when Grand Final and Third Place matches are managed separately.
* Added 2D Zoom & Pan interactive viewing mode (`BracketViewMode.interactive2D`) using `InteractiveViewer`, with a toggle button to switch between page-swipe and interactive 2D map view.
* Added `PremiumMatchCard` widget featuring check-in status indicators, real-time live match indicator badge, ELO/Rank info display, and walkover / dispute warning styles.
* Added support for `thirdPlaceMatch` (Bronze Match) card rendering positioned cleanly below the Grand Final.
* Updated `BracketPainter` to render final round connection lines using the orthogonal curved/sharp style (`ConnectorStyle.curved` or `sharp`) matching the intermediate rounds, keeping them completely clear of the Third Place match card.
* Added Dispute branch freezing: connection lines coming out of matches in `MatchStatus.dispute` are drawn as warning/caution red dashed tapes with an exclamation mark (!) badge.
* Added comprehensive unit and widget tests covering draw engine seeding logic, BYE calculations, and structural round generation.

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
