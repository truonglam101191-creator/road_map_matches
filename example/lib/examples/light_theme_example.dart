import 'package:flutter/material.dart';
import 'package:road_map/animated_tournament_bracket.dart';
import '../bracket_data.dart';

class LightThemeExample extends StatelessWidget {
  const LightThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    // We will use the Singles round branch data but with a gorgeous light theme configuration!
    final branchRounds = [
      BracketData.round1Tab1,
      BracketData.round2Tab1,
      BracketData.round3Tab1,
      BracketData.round4Tab1,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Premium Light Theme',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SafeArea(
        child: AnimatedTournamentBracket<MatchModel<dynamic>>(
          branch1Rounds: branchRounds,
          grandFinal: BracketData.grandFinal,

          // Theme configurations
          primaryColor: const Color(0xFF4F46E5), // Indigo
          secondaryColor: const Color(0xFF06B6D4), // Cyan
          backgroundColor: const Color(0xFFF4F6F9), // Light bg
          surfaceColor: Colors.white, // Tab bar white bg
          defaultLineColor: const Color(0xFFE2E8F0), // Subtle slate gray line
          accentColor: const Color(0xFFF59E0B), // Amber
          tabBarBorderColor: const Color(0xFFE2E8F0),
          tabBarBackgroundColor: Colors.white,
          tabBarBorderRadius: 10,
          tabBarHeight: 46,

          // Callback tracers
          hasWinner: (m) => m.hasWinner,
          getWinnerName: (m) => m.winner?.name ?? '',
          getPlayer1Name: (m) =>
              m.competitors.isNotEmpty ? m.competitors.first.name : '',
          getPlayer2Name: (m) =>
              m.competitors.length > 1 ? m.competitors.last.name : '',

          // Custom tab rendering for light theme
          tabBuilder: (context, index, isSelected) {
            final titles = [
              'Vòng 1',
              'Last 16',
              'Tứ Kết',
              'Bán Kết',
              'Chung Kết',
            ];
            return Text(
              index < titles.length ? titles[index] : 'Vòng ${index + 1}',
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            );
          },

          // Match card rendering styled specifically for light mode
          itemBuilder: (context, match) {
            final isWinner1 =
                match.hasWinner &&
                match.winner?.name ==
                    (match.competitors.isNotEmpty
                        ? match.competitors.first.name
                        : '');
            final isWinner2 =
                match.hasWinner &&
                match.winner?.name ==
                    (match.competitors.length > 1
                        ? match.competitors.last.name
                        : '');

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: match.status == MatchStatus.inProgress
                      ? const Color(0xFF4F46E5).withValues(alpha: 0.3)
                      : const Color(0xFFE2E8F0),
                  width: match.status == MatchStatus.inProgress ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      color: match.status == MatchStatus.inProgress
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            match.label,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            match.time,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLightPlayerRow(
                              match.competitors.isNotEmpty
                                  ? match.competitors.first.name
                                  : 'TBD',
                              match.scores.isNotEmpty ? match.scores.first : 0,
                              isWinner1,
                            ),
                            Container(
                              height: 1,
                              color: const Color(0xFFF1F5F9),
                            ),
                            _buildLightPlayerRow(
                              match.competitors.length > 1
                                  ? match.competitors.last.name
                                  : 'TBD',
                              match.scores.length > 1 ? match.scores.last : 0,
                              isWinner2,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildLightPlayerRow(String name, int score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isWinner
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
              fontSize: 10,
              fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: isWinner ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              color: isWinner ? Colors.white : const Color(0xFF475569),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
