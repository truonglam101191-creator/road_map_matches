import 'package:flutter/material.dart';
import 'package:road_map/animated_tournament_bracket.dart';

// 1. Simple custom match model
class SimpleMatch {
  final int id;
  final String player1;
  final String player2;
  final String winner;
  final int score1;
  final int score2;

  const SimpleMatch({
    required this.id,
    required this.player1,
    required this.player2,
    required this.winner,
    required this.score1,
    required this.score2,
  });
}

class MinimalBoilerplateExample extends StatelessWidget {
  const MinimalBoilerplateExample({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Mock 2 rounds of data
    final List<List<SimpleMatch>> rounds = [
      [
        const SimpleMatch(
          id: 1,
          player1: 'Alice',
          player2: 'Bob',
          winner: 'Alice',
          score1: 9,
          score2: 5,
        ),
        const SimpleMatch(
          id: 2,
          player1: 'Charlie',
          player2: 'David',
          winner: 'David',
          score1: 4,
          score2: 9,
        ),
      ],
      [
        const SimpleMatch(
          id: 3,
          player1: 'Alice',
          player2: 'David',
          winner: 'Alice',
          score1: 10,
          score2: 8,
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Minimal Boilerplate')),
      body: SafeArea(
        child: AnimatedTournamentBracket<SimpleMatch>(
          branch1Rounds: rounds,

          // Trace lines by matching player names
          hasWinner: (m) => m.winner.isNotEmpty,
          getWinnerName: (m) => m.winner,
          getPlayer1Name: (m) => m.player1,
          getPlayer2Name: (m) => m.player2,

          // Simple Card Builder
          itemBuilder: (context, match) {
            return Card(
              color: const Color(0xFF131A30),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _playerRow(
                      match.player1,
                      match.score1,
                      match.winner == match.player1,
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    _playerRow(
                      match.player2,
                      match.score2,
                      match.winner == match.player2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _playerRow(String name, int score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            color: isWinner ? Colors.white : Colors.white54,
            fontSize: 11,
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            color: isWinner ? Colors.green : Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
