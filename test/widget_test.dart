import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_map/road_map.dart';

class Team {
  final String teamName;
  final String country;
  final bool isWalkOver;

  const Team({
    required this.teamName,
    required this.country,
    this.isWalkOver = false,
  });
}

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
        competitors: [p1, p2],
      scores: [10, 8],
      );

      expect(match1.hasWinner, true);
      expect(match1.winner!.name, 'Player 1');

      const match2 = MatchModel(
        id: 2,
        label: 'Quarter-Final',
        table: 'Table 1',
        time: '11:00 AM',
        competitors: [p1, p2],
      scores: [5, 11],
      );

      expect(match2.hasWinner, true);
      expect(match2.winner!.name, 'Player 2');
    });

    test('MatchModel winner determination by Walk Over', () {
      const p1 = Player(name: 'Player 1', flag: '🇻🇳');

      const matchWalkOver = MatchModel(
        id: 3,
        label: 'Quarter-Final',
        table: 'Table 1',
        time: '12:00 PM',
        competitors: [p1, Player.walkOver],
      scores: [0, 0],
      );

      expect(matchWalkOver.hasWinner, true);
      expect(matchWalkOver.winner!.name, 'Player 1');
    });

    test('MatchModel supports custom Team model', () {
      const t1 = Team(teamName: 'Team Vietnam', country: '🇻🇳');
      const t2 = Team(teamName: 'Team USA', country: '🇺🇸');
      const walkOverTeam = Team(teamName: 'Walk Over Team', country: '🌍', isWalkOver: true);

      const match = MatchModel<Team>(
        id: 4,
        label: 'Team Final',
        table: 'Table 1',
        time: '08:00 PM',
        competitors: [t1, t2],
      scores: [5, 3],
      );

      expect(match.hasWinner, true);
      expect(match.winner!.teamName, 'Team Vietnam');

      const matchWalkOver = MatchModel<Team>(
        id: 5,
        label: 'Team Semi',
        table: 'Table 2',
        time: '06:00 PM',
        competitors: [t1, walkOverTeam],
      scores: [0, 0],
      );

      expect(matchWalkOver.hasWinner, true);
      expect(matchWalkOver.winner!.teamName, 'Team Vietnam');
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
      competitors: [p1, p2],
      scores: [10, 7],
    );

    const m2 = MatchModel(
      id: 2,
      label: 'Semi 2',
      table: 'T2',
      time: '15:30',
      competitors: [p3, p4],
      scores: [5, 10],
    );

    const grandFinal = MatchModel(
      id: 3,
      label: 'Championship Match',
      table: 'T1',
      time: '18:00',
      competitors: [Player(name: 'Finalist 1', flag: '🇪🇸'), Player(name: 'Finalist 2', flag: '🇩🇪')],
      scores: [11, 9],
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
            getWinnerName: (m) => m.winner?.name ?? '',
            getPlayer1Name: (m) => m.competitors.isNotEmpty ? m.competitors.first.name : '',
            getPlayer2Name: (m) => m.competitors.length > 1 ? m.competitors.last.name : '',
            itemBuilder: (context, match) {
              return SizedBox(
                key: ValueKey('match-${match.id}'),
                width: 200,
                height: 100,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(match.competitors.isNotEmpty ? match.competitors.first.name : ''),
                      Text('vs'),
                      Text(match.competitors.length > 1 ? match.competitors.last.name : ''),
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
