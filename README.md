# road_map

A premium, responsive, and highly customizable generic tournament bracket (road map) library for Flutter. It supports dynamic infinite rounds, interactive swipe navigation, customizable branch layouts, and high-performance glowing victory connection lines.

<p align="center">
  <img src="https://raw.githubusercontent.com/truonglam101191-creator/road_map_matches/main/screenshots/demo.png" alt="Interactive Swipe & Tab Navigation Demo" width="300" />
  <img src="https://raw.githubusercontent.com/truonglam101191-creator/road_map_matches/main/screenshots/demo1.png" alt="Light/Dark Premium Themes" width="300" />
</p>

<details>
  <summary>📸 Click to view more screenshots (Grid Layout)</summary>
  <p align="center">
    <table align="center">
      <tr>
        <td align="center">
          <img src="https://raw.githubusercontent.com/truonglam101191-creator/road_map_matches/main/screenshots/custom_layout1.gif" alt="Custom Layout 1" width="220"/>
          <br/><b>Premium Dark</b>
        </td>
        <!-- <td align="center">
          <img src="https://raw.githubusercontent.com/truonglam101191-creator/road_map_matches/main/screenshots/custom_layout2.png" alt="Custom Layout 2" width="220"/>
          <br/><b>Checked-in & QR</b>
        </td>
        <td align="center">
          <img src="https://raw.githubusercontent.com/truonglam101191-creator/road_map_matches/main/screenshots/custom_layout3.png" alt="Custom Layout 3" width="220"/>
          <br/><b>Dynamic Gaps</b>
        </td> -->
      </tr>
    </table>
  </p>
</details>

---

## Features

- 🏆 **Generic Type Support**: Works with any custom match model `T` by passing simple getter callbacks.
- 💫 **Glowing Victory Connectors**: Draws orthogonal connection lines between rounds with configurable active/inactive state and glowing highlight paths.
- 🗺️ **2D Zoom & Pan Interactive View**: Smoothly pan, zoom, and navigate the entire tournament bracket using `InteractiveViewer` with a toggle mode button.
- 🎴 **Premium Match Card built-in**: Use the premium glassmorphic `PremiumMatchCard` out-of-the-box, supporting Live score badge, QR check-in status, ELO info, and walkthrough warnings.
- 🥉 **Third-Place Match**: Easy support for Third-Place (Bronze) matches rendered cleanly and aligned underneath the Grand Final.
- 🔒 **Dispute Branch Freezing**: Automatically turns connection lines into striped caution tapes with an exclamation badge (`!`) when a match is in a dispute state.
- 🧩 **Tournament Draw Engine**: Includes a symmetric seeding and automatic BYE allocation utility (`TournamentDrawEngine`) to construct bracket trees programmatically.
- 📱 **Interactive Swipe & Tab Navigation**: Swipe horizontally or tap tabs with premium sliding indicator to navigate rounds effortlessly.
- ⚡ **Highly Customizable**: Complete control over round tab labels, theme colors, connector corner radius, and match card widgets.
- 🎨 **Adaptive Layout**: Smoothly morphs vertical alignments to support infinite rounds without overflow. For smaller brackets (e.g. 2 items or fewer), the bracket is automatically aligned to the top of the viewport to maintain a clean structure.

---

## Installation

Add `road_map` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  road_map: ^1.2.1
```

Then run:

```bash
flutter pub get
```

---

## Usage

Here is a quick example of how to use `AnimatedTournamentBracket`.

### 1. Define Your Custom Model

```dart
class MyMatch {
  final int id;
  final String label;
  final String player1;
  final String player2;
  final String? winner;

  const MyMatch({
    required this.id,
    required this.label,
    required this.player1,
    required this.player2,
    this.winner,
  });

  bool get hasWinner => winner != null;
}
```

### 2. Implement the Widget

Here is how to set up the bracket using `TournamentDrawEngine` to generate matches, `PremiumMatchCard` to render the cards, and the interactive zoom/pan view:

```dart
import 'package:flutter/material.dart';
import 'package:road_map/road_map.dart';

class TournamentBracketScreen extends StatefulWidget {
  const TournamentBracketScreen({super.key});

  @override
  State<TournamentBracketScreen> createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> {
  late List<List<MatchModel<Player>>> _rounds;
  MatchModel<Player>? _grandFinal;
  MatchModel<Player>? _thirdPlaceMatch;

  @override
  void initState() {
    super.initState();
    _generateBracket();
  }

  void _generateBracket() {
    // 1. Prepare players list (with optional seeding and check-in status)
    final List<Player> players = [
      Player(name: 'Nguyễn Văn A', flag: '⭐️', isCheckedIn: true),
      Player(name: 'Trần Thị B', flag: '⭐️', isCheckedIn: true),
      Player(name: 'Lê Hoàng C', flag: '👤'),
      Player(name: 'Phạm Minh D', flag: '👤'),
      Player(name: 'Hoàng Anh E', flag: '👤'),
      Player(name: 'Vũ Đức F', flag: '👤'),
      Player(name: 'Ngô Quốc G', flag: '👤'),
      Player(name: 'Đặng Thanh H', flag: '👤'),
    ];

    // 2. Build rounds using TournamentDrawEngine (BYE matches will be allocated automatically)
    final generatedRounds = TournamentDrawEngine.buildInitialBracket<Player>(
      players: players,
      matchLabelPrefix: 'Match ',
      includeFinal: false, // Exclude final to handle grand final and third place manually
    );

    setState(() {
      _rounds = generatedRounds;

      // Initialize Grand Final and Third Place matches
      _grandFinal = const MatchModel<Player>(
        id: 100,
        label: 'Grand Final',
        table: 'Main Table',
        time: 'Sunday 20:00',
        competitors: [],
        scores: [0, 0],
        status: MatchStatus.scheduled,
      );

      _thirdPlaceMatch = const MatchModel<Player>(
        id: 101,
        label: 'Third-Place Match',
        table: 'Table 2',
        time: 'Sunday 18:00',
        competitors: [],
        scores: [0, 0],
        status: MatchStatus.scheduled,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: SafeArea(
        child: AnimatedTournamentBracket<MatchModel<Player>>(
          branch1Rounds: _rounds,
          grandFinal: _grandFinal,
          thirdPlaceMatch: _thirdPlaceMatch,
          
          // Use the modern 2D pan & zoom viewport by default
          defaultViewMode: BracketViewMode.interactive2D,
          showViewModeToggle: true,

          // Map match details and status
          hasWinner: (m) => m.hasWinner,
          getWinnerName: (m) => m.winner?.name ?? '',
          getPlayer1Name: (m) => m.competitors.isNotEmpty ? m.competitors.first.name : '',
          getPlayer2Name: (m) => m.competitors.length > 1 ? m.competitors.last.name : '',
          getMatchStatus: (m) => m.status,

          // Stylings
          primaryColor: const Color(0xFF0066FF),
          secondaryColor: const Color(0xFF00E5FF),
          surfaceColor: const Color(0xFF131A30),
          backgroundColor: const Color(0xFF070B19), // Set to null for a transparent background
          useGradientBackground: true, // Set to false to render backgroundColor as a solid color
          // backgroundGradient: const RadialGradient(...), // Optional custom background gradient
          disputeColor: const Color(0xFFFF3366),

          // Build premium glassmorphic cards out of the box
          itemBuilder: (context, match) {
            return PremiumMatchCard(
              match: match,
              primaryColor: const Color(0xFF0066FF),
              secondaryColor: const Color(0xFF00E5FF),
              surfaceColor: const Color(0xFF131A30),
              accentColor: const Color(0xFFFFB300),
              disputeColor: const Color(0xFFFF3366),
              onTap: () {
                // Open match score editor, toggle dispute status, or update winners here.
              },
            );
          },
        ),
      ),
    );
  }
}
```

---

## Detailed Parameters

| Parameter | Type | Description |
|---|---|---|
| `branch1Rounds` | `List<List<T>>` | Required. List of rounds containing matches of type `T` for the primary branch (e.g. Upper Branch). |
| `grandFinal` | `T?` | Optional. The ultimate championship match connecting the branch winners. |
| `thirdPlaceMatch` | `T?` | Optional. The third-place (bronze medal) match positioned cleanly below the grand final. |
| `itemBuilder` | `Widget Function(BuildContext, T)` | Required. Callback builder to construct your custom match card widgets. |
| `roundTitles` | `List<String>?` | Optional. Custom names for each round tab (e.g. `['Round 1', 'Quarter-Finals', ...]`). |
| `tabBuilder` | `Widget Function(BuildContext, int, bool)?` | Optional. Callback to build highly custom tab labels. |
| `hasWinner` | `bool Function(T)?` | Optional. Returns whether a match has concluded with a winner. |
| `getWinnerName` | `String Function(T)?` | Optional. Returns the name of the winning player to highlight the line. |
| `getPlayer1Name` | `String Function(T)?` | Optional. Returns player 1's name to trace the path. |
| `getPlayer2Name` | `String Function(T)?` | Optional. Returns player 2's name to trace the path. |
| `defaultViewMode` | `BracketViewMode` | The default viewing layout mode: `BracketViewMode.swipe` or `BracketViewMode.interactive2D` (Zoom/Pan). Defaults to `BracketViewMode.swipe`. |
| `showViewModeToggle` | `bool` | Whether to show the floating action button to switch between Swipe and 2D mode. Defaults to `true`. |
| `getMatchStatus` | `MatchStatus Function(T)?` | Optional. Returns the status of the match (`scheduled`, `inProgress`, `completed`, `dispute`) to control card borders and freezes. |
| `disputeColor` | `Color` | Highlight color used for disputed caution tapes and warnings. Defaults to `#FF3366`. |
| `connectorRadius` | `double` | The corner radius of orthogonal connection lines. Defaults to `8.0`. |
| `primaryColor` | `Color` | Main highlight color for winning paths and indicators. Defaults to `#0066FF`. |
| `secondaryColor` | `Color` | Accent highlight color. Defaults to `#00E5FF`. |
| `backgroundColor` | `Color?` | Overall background color. If null (and `backgroundGradient` is null), no background is painted (transparent). Defaults to `#070B19`. |
| `backgroundGradient` | `Gradient?` | Optional custom background gradient. Overrides `backgroundColor` if set. |
| `useGradientBackground` | `bool` | Whether to render the `backgroundColor` as a premium radial gradient. If false, renders as a solid color. Defaults to `true`. |
| `surfaceColor` | `Color` | Tab bar background fill color. Defaults to `#131A30`. |
| `cardWidth` | `double?` | Custom card width (defaults to dynamic calculation if null). |
| `cardHeight` | `double?` | Custom card height (defaults to dynamic calculation if null). |
| `horizontalGap` | `double?` | Custom horizontal gap between rounds (defaults to dynamic calculation if null). |
| `verticalGap` | `double` | Custom vertical gap between cards in the same round. Defaults to `16.0`. |
| `topOffset` | `double` | Custom top offset for drawing the bracket. Defaults to `25.0`. |
| `lineThickness` | `double` | Default connection line thickness. Defaults to `2.0`. |
| `activeLineThickness` | `double` | Active connection line thickness. Defaults to `3.0`. |
| `activeGlowWidth` | `double` | Active connection line glow width. Defaults to `8.0`. |
| `activeGlowOpacity` | `double` | Active connection line glow opacity. Defaults to `0.15`. |
| `connectorStyle` | `ConnectorStyle` | The design style of connecting lines: `ConnectorStyle.curved`, `ConnectorStyle.sharp`, or `ConnectorStyle.straight`. Defaults to `ConnectorStyle.curved`. |
| `lineType` | `ConnectorLineType` | Choose line animation style: `ConnectorLineType.solid` or `ConnectorLineType.flowing` (moving dashes). Defaults to `ConnectorLineType.solid`. |
| `dashLength` | `double` | Length of active dashes in flowing lines. Defaults to `12.0`. |
| `dashGap` | `double` | Gap between active dashes in flowing lines. Defaults to `8.0`. |
| `dashSpeedMultiplier` | `double` | Speed multiplier for the flowing animation. Defaults to `1.0`. |
| `searchHighlightQuery` | `String?` | Competitor name query. If set, connector lines along paths containing this competitor name are highlighted with `accentColor`. |
| `accentColor` | `Color` | Highlight color used for matching searched competitor paths. Defaults to `#FFB300`. |
| `pulseGlow` | `bool` | Whether to enable pulsing glow effect animations on active lines. Defaults to `true`. |
| `pulseDuration` | `Duration` | Speed/duration of the pulsing animation loop. Defaults to `Duration(seconds: 2)`. |
| `useLineGradients` | `bool` | Whether to apply a premium color gradient transition (`primaryColor` -> `secondaryColor`) to active connector paths. Defaults to `true`. |
| `roundHeaderBuilder` | `Widget Function(BuildContext, int)?` | Optional callback to build and render custom column headers directly above each round in the bracket canvas. |
| `tabBarBorderColor` | `Color?` | Custom border color for the round tabs. Defaults to `Colors.white.withValues(alpha: 0.05)`. |
| `tabBarBackgroundColor` | `Color?` | Custom background color for the round tabs. Defaults to `surfaceColor.withValues(alpha: 0.6)`. |
| `tabBarBorderRadius` | `double` | Custom border radius for the round tabs container. Defaults to `12.0`. |
| `tabBarIndicatorDecoration` | `Decoration?` | Custom decoration for the sliding round tab indicator. |
| `tabBarHeight` | `double` | Custom height of the round tabs bar. Defaults to `42.0`. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
