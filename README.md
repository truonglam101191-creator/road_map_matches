# road_map

A premium, responsive, and highly customizable generic tournament bracket (road map) library for Flutter. It supports dynamic infinite rounds, interactive swipe navigation, customizable branch layouts, and high-performance glowing victory connection lines.

<p align="center">
  <img src="https://raw.githubusercontent.com/truonglam101191-creator/road_map_matches/main/screenshots/demo.gif" alt="Interactive Swipe & Tab Navigation Demo" width="300" />
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
- 📱 **Interactive Swipe & Tab Navigation**: Swipe horizontally or tap tabs with premium sliding indicator to navigate rounds effortlessly.
- ⚡ **Highly Customizable**: Complete control over round tab labels, theme colors, connector corner radius, and match card widgets.
- 🎨 **Adaptive Layout**: Smoothly morphs vertical alignments to support infinite rounds without overflow.

---

## Installation

Add `road_map` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  road_map: ^1.0.0
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

```dart
import 'package:flutter/material.dart';
import 'package:road_map/road_map.dart';

class TournamentBracketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 4 rounds of matches for Branch 1
    final List<List<MyMatch>> branch1 = [
      [/* Round 1 Matches */],
      [/* Round 2 Matches */],
      [/* Round 3 Matches */],
      [/* Round 4 Matches */],
    ];

    final MyMatch grandFinal = MyMatch(
      id: 99,
      label: 'Grand Final',
      player1: 'Player A',
      player2: 'Player B',
    );

    return Scaffold(
      body: SafeArea(
        child: AnimatedTournamentBracket<MyMatch>(
          branch1Rounds: branch1,
          grandFinal: grandFinal,

          // Callbacks to determine glowing connection lines
          hasWinner: (match) => match.hasWinner,
          getWinnerName: (match) => match.winner ?? '',
          getPlayer1Name: (match) => match.player1,
          getPlayer2Name: (match) => match.player2,

          // Build your own custom match cards
          itemBuilder: (context, match) {
            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF131A30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(match.player1, style: TextStyle(color: Colors.white)),
                  Divider(color: Colors.white10),
                  Text(match.player2, style: TextStyle(color: Colors.white)),
                ],
              ),
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
| `itemBuilder` | `Widget Function(BuildContext, T)` | Required. Callback builder to construct your custom match card widgets. |
| `roundTitles` | `List<String>?` | Optional. Custom names for each round tab (e.g. `['Round 1', 'Quarter-Finals', ...]`). |
| `tabBuilder` | `Widget Function(BuildContext, int, bool)?` | Optional. Callback to build highly custom tab labels. |
| `hasWinner` | `bool Function(T)?` | Optional. Returns whether a match has concluded with a winner. |
| `getWinnerName` | `String Function(T)?` | Optional. Returns the name of the winning player to highlight the line. |
| `getPlayer1Name` | `String Function(T)?` | Optional. Returns player 1's name to trace the path. |
| `getPlayer2Name` | `String Function(T)?` | Optional. Returns player 2's name to trace the path. |
| `connectorRadius` | `double` | The corner radius of orthogonal connection lines. Defaults to `8.0`. |
| `primaryColor` | `Color` | Main highlight color for winning paths and indicators. Defaults to `#0066FF`. |
| `secondaryColor` | `Color` | Accent highlight color. Defaults to `#00E5FF`. |
| `backgroundColor` | `Color` | Overall background gradient starting color. Defaults to `#070B19`. |
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
| `tabBarBorderColor` | `Color?` | Custom border color for the round tabs. Defaults to `Colors.white.withValues(alpha: 0.05)`. |
| `tabBarBackgroundColor` | `Color?` | Custom background color for the round tabs. Defaults to `surfaceColor.withValues(alpha: 0.6)`. |
| `tabBarBorderRadius` | `double` | Custom border radius for the round tabs container. Defaults to `12.0`. |
| `tabBarIndicatorDecoration` | `Decoration?` | Custom decoration for the sliding round tab indicator. |
| `tabBarHeight` | `double` | Custom height of the round tabs bar. Defaults to `42.0`. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
