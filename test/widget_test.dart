import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_map/road_map.dart';

void main() {
  group('Player & MatchModel Unit Tests', () {
    test('Player creation and Walk Over default', () {
      const player = Player(name: 'John Doe', flag: '🇺🇸');
      expect(player.name, 'John Doe');
      expect(player.flag, '🇺🇸');
      expect(player.isWalkOver, false);

      expect(Player.walkOver.isWalkOver, true);
      expect(Player.walkOver.name, 'Walk Over');
    });

    test('MatchModel winner determination by score', () {
      const p1 = Player(name: 'Player 1', flag: '🇻🇳');
      const p2 = Player(name: 'Player 2', flag: '🇺🇸');

      const match1 = MatchModel(
        id: 1,
        label: 'Quarter-Final',
        table: 'Table 1',
        time: '10:00 AM',
        player1: p1,
        player2: p2,
        score1: 10,
        score2: 8,
      );

      expect(match1.hasWinner, true);
      expect(match1.winner.name, 'Player 1');

      const match2 = MatchModel(
        id: 2,
        label: 'Quarter-Final',
        table: 'Table 1',
        time: '11:00 AM',
        player1: p1,
        player2: p2,
        score1: 5,
        score2: 11,
      );

      expect(match2.hasWinner, true);
      expect(match2.winner.name, 'Player 2');
    });

    test('MatchModel winner determination by Walk Over', () {
      const p1 = Player(name: 'Player 1', flag: '🇻🇳');

      const matchWalkOver = MatchModel(
        id: 3,
        label: 'Quarter-Final',
        table: 'Table 1',
        time: '12:00 PM',
        player1: p1,
        player2: Player.walkOver,
        score1: 0,
        score2: 0,
      );

      expect(matchWalkOver.hasWinner, true);
      expect(matchWalkOver.winner.name, 'Player 1');
    });
  });

  group('AnimatedTournamentBracket Widget Tests', () {
    // Dummy Data Setup
    const p1 = Player(name: 'David Alcaide', flag: '🇪🇸');
    const p2 = Player(name: 'Skyler Woodward', flag: '🇺🇸');
    const p3 = Player(name: 'Shane Van Boening', flag: '🇺🇸');
    const p4 = Player(name: 'Joshua Filler', flag: '🇩🇪');

    const m1 = MatchModel(
      id: 1,
      label: 'Semi 1',
      table: 'T1',
      time: '14:00',
      player1: p1,
      player2: p2,
      score1: 10,
      score2: 7,
    );

    const m2 = MatchModel(
      id: 2,
      label: 'Semi 2',
      table: 'T2',
      time: '15:30',
      player1: p3,
      player2: p4,
      score1: 5,
      score2: 10,
    );

    const grandFinal = MatchModel(
      id: 3,
      label: 'Championship Match',
      table: 'T1',
      time: '18:00',
      player1: Player(name: 'Finalist 1', flag: '🇪🇸'),
      player2: Player(name: 'Finalist 2', flag: '🇩🇪'),
      score1: 11,
      score2: 9,
    );

    final List<List<MatchModel>> singleBranchRounds = [
      [m1, m2],
    ];

    Widget buildTestBracket({
      required List<List<MatchModel>> branchRounds,
      List<String>? roundTitles,
      Widget Function(BuildContext, int, bool)? tabBuilder,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AnimatedTournamentBracket<MatchModel>(
            branch1Rounds: branchRounds,
            grandFinal: grandFinal,
            roundTitles: roundTitles,
            tabBuilder: tabBuilder,
            hasWinner: (m) => m.hasWinner,
            getWinnerName: (m) => m.winner.name,
            getPlayer1Name: (m) => m.player1.name,
            getPlayer2Name: (m) => m.player2.name,
            itemBuilder: (context, match) {
              return SizedBox(
                key: ValueKey('match-${match.id}'),
                width: 200,
                height: 100,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(match.player1.name),
                      Text('vs'),
                      Text(match.player2.name),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    testWidgets('Renders matches and tabs correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestBracket(branchRounds: singleBranchRounds),
      );

      // Verify that Round 1 matches are in the widget tree
      expect(find.text('David Alcaide'), findsOneWidget);
      expect(find.text('Skyler Woodward'), findsOneWidget);
      expect(find.text('Shane Van Boening'), findsOneWidget);
      expect(find.text('Joshua Filler'), findsOneWidget);

      // Verify default tabs
      expect(find.text('Semi'), findsOneWidget);
      expect(find.text('Final'), findsOneWidget);
    });

    testWidgets('Tapping on a round tab updates layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestBracket(branchRounds: singleBranchRounds),
      );

      // Initially, we should be in Round 1 (index 0)
      expect(find.byKey(const ValueKey('match-1')), findsOneWidget);

      // Tap on the 'Final' tab (which is the next round)
      await tester.tap(find.text('Final'));
      await tester.pumpAndSettle();

      // Check if match-3 (grand final) card is rendered
      expect(find.byKey(const ValueKey('match-3')), findsOneWidget);
    });

    testWidgets('Uses custom tabBuilder when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestBracket(
          branchRounds: singleBranchRounds,
          tabBuilder: (context, index, isSelected) {
            return Text(
              'CUSTOM-$index',
              style: const TextStyle(color: Colors.red),
            );
          },
        ),
      );

      expect(find.text('CUSTOM-0'), findsOneWidget);
      expect(find.text('CUSTOM-1'), findsOneWidget);
    });
  });
}
