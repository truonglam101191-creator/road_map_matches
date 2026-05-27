# read_map_matches

A premium, responsive, and highly customizable generic tournament bracket (road map) library for Flutter. It supports dynamic infinite rounds, interactive swipe navigation, customizable branch layouts, and high-performance glowing victory connection lines.

---

## Features

- 🏆 **Generic Type Support**: Works with any custom match model `T` by passing simple getter callbacks.
- 💫 **Glowing Victory Connectors**: Draws orthogonal connection lines between rounds with configurable active/inactive state and glowing highlight paths.
- 📱 **Interactive Swipe & Tab Navigation**: Swipe horizontally or tap tabs with premium sliding indicator to navigate rounds effortlessly.
- ⚡ **Highly Customizable**: Complete control over round tab labels, theme colors, connector corner radius, and match card widgets.
- 🔄 **Double Branches Layout**: Built-in support for multiple branches (e.g. Upper & Lower brackets) with a dynamic bottom selector.
- 🎨 **Adaptive Layout**: Smoothly morphs vertical alignments to support infinite rounds without overflow.

---

## Installation

Add `read_map_matches` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  read_map_matches: ^1.0.0
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
import 'package:read_map_matches/read_map_matches.dart';

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
| `grandFinal` | `T` | Required. The ultimate championship match connecting the branch winners. |
| `itemBuilder` | `Widget Function(BuildContext, T)` | Required. Callback builder to construct your custom match card widgets. |
| `branch2Rounds` | `List<List<T>>?` | Optional. Secondary branch rounds (e.g. Lower Branch) to support double elimination brackets. |
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

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
