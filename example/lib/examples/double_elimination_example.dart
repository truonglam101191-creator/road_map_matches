import 'package:flutter/material.dart';
import 'package:road_map/animated_tournament_bracket.dart';
import '../bracket_data.dart';

class DoubleEliminationExample extends StatefulWidget {
  const DoubleEliminationExample({super.key});

  @override
  State<DoubleEliminationExample> createState() =>
      _DoubleEliminationExampleState();
}

class _DoubleEliminationExampleState extends State<DoubleEliminationExample> {
  int _activeBracketTab = 0; // 0: Winners (Upper), 1: Losers (Lower)

  List<List<MatchModel<dynamic>>> _getBracketRounds() {
    if (_activeBracketTab == 0) {
      return [
        BracketData.round1Tab1,
        BracketData.round2Tab1,
        BracketData.round3Tab1,
        BracketData.round4Tab1,
      ];
    } else {
      return [
        BracketData.round1Tab2,
        BracketData.round2Tab2,
        BracketData.round3Tab2,
        BracketData.round4Tab2,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        title: const Text('Double Elimination Demo'),
        backgroundColor: const Color(0xFF1B1D2A),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informational Header
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1B1D2A),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CẤU HÌNH DOUBLE ELIMINATION (2 LẦN THUA)',
                  style: TextStyle(
                    color: Color(0xFFFFB300),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Người chơi thua ở Nhánh Thắng (Winners Bracket) sẽ rơi xuống Nhánh Thua (Losers Bracket). Sơ đồ dưới đây hiển thị luồng di chuyển này qua các tab nhánh.',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bracket Selector Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D2A),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeBracketTab = 0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _activeBracketTab == 0
                              ? const Color(0xFF0066FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Text(
                          'Nhánh Thắng (Winners)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeBracketTab = 1),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _activeBracketTab == 1
                              ? const Color(0xFF00E5FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Text(
                          'Nhánh Thua (Losers)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bracket Widget
          Expanded(
            child: AnimatedTournamentBracket<MatchModel<dynamic>>(
              key: ValueKey(_activeBracketTab),
              branch1Rounds: _getBracketRounds(),
              grandFinal: _activeBracketTab == 0
                  ? BracketData.grandFinal
                  : null, // Grand final only in Winners branch
              primaryColor: _activeBracketTab == 0
                  ? const Color(0xFF0066FF)
                  : const Color(0xFF00E5FF),

              secondaryColor: const Color(0xFFFFB300),
              backgroundColor: const Color(0xFF0D0E15),
              surfaceColor: const Color(0xFF1B1D2A),
              useLineGradients: true,
              roundHeaderBuilder: (context, roundIndex) {
                final titles = _activeBracketTab == 0
                    ? [
                        'Vòng 1 (R16)',
                        'Tứ Kết (QF)',
                        'Bán Kết (SF)',
                        'Chung Kết Nhánh (F)',
                      ]
                    : [
                        'Vòng Thua 1',
                        'Vòng Thua 2',
                        'Tứ Kết Thua',
                        'Bán Kết Thua',
                      ];
                final title = roundIndex < titles.length
                    ? titles[roundIndex]
                    : 'Vòng ${roundIndex + 1}';
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D2A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              hasWinner: (m) => m.hasWinner,
              getWinnerName: (m) => m.winner?.name ?? '',
              getPlayer1Name: (m) =>
                  m.competitors.isNotEmpty ? m.competitors.first.name : '',
              getPlayer2Name: (m) =>
                  m.competitors.length > 1 ? m.competitors.last.name : '',
              itemBuilder: (context, match) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            match.label,
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 7.5,
                            ),
                          ),
                          Text(
                            match.time,
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 7.5,
                            ),
                          ),
                        ],
                      ),
                      _buildSimplePlayerRow(
                        match.competitors.isNotEmpty
                            ? match.competitors.first.name
                            : 'TBD',
                        match.scores.isNotEmpty ? match.scores.first : 0,
                        match.hasWinner &&
                            match.winner?.name ==
                                (match.competitors.isNotEmpty
                                    ? match.competitors.first.name
                                    : ''),
                      ),
                      _buildSimplePlayerRow(
                        match.competitors.length > 1
                            ? match.competitors.last.name
                            : 'TBD',
                        match.scores.length > 1 ? match.scores.last : 0,
                        match.hasWinner &&
                            match.winner?.name ==
                                (match.competitors.length > 1
                                    ? match.competitors.last.name
                                    : ''),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePlayerRow(String name, int score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isWinner ? Colors.white : Colors.white60,
              fontSize: 9.5,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            color: isWinner ? const Color(0xFF00E5FF) : Colors.white24,
            fontSize: 9.5,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
