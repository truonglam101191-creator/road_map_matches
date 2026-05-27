import 'dart:ui';
import 'package:flutter/material.dart';
import 'bracket_data.dart';
import 'package:road_map/animated_tournament_bracket.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pool Tournament Road Map Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0066FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF131A30),
        ),
      ),
      home: const TournamentBracketDemo(),
    );
  }
}

class TournamentBracketDemo extends StatefulWidget {
  const TournamentBracketDemo({super.key});

  @override
  State<TournamentBracketDemo> createState() => _TournamentBracketDemoState();
}

class _TournamentBracketDemoState extends State<TournamentBracketDemo> {
  MatchModel? _selectedMatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Exclude header from the plugin, build it cleanly in the app layer!
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                _buildHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedTournamentBracket<MatchModel>(
                    branch1Rounds: const [
                      BracketData.round1Tab1,
                      BracketData.round1Tab1,
                      BracketData.round2Tab1,
                      BracketData.round3Tab1,
                      BracketData.round4Tab1,
                    ],
                    grandFinal: BracketData.grandFinal,

                    // Expose getters for glowing victory connection lines!
                    hasWinner: (match) => match.hasWinner,
                    getWinnerName: (match) => match.winner.name,
                    getPlayer1Name: (match) => match.player1.name,
                    getPlayer2Name: (match) => match.player2.name,

                    // Custom Tab Label Builder demonstrating full visual control!
                    tabBuilder: (context, index, isSelected) {
                      final titles = [
                        'Round 1',
                        'Last 16',
                        'Quarter',
                        'Semi',
                        'Final',
                      ];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.flash_on,
                              size: 9,
                              color: Color(0xFFFFB300),
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            index < titles.length
                                ? titles[index]
                                : 'Round ${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    },

                    // Build custom premium match cards!
                    itemBuilder: (context, match) {
                      return _buildMatchCard(match);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Detail Match Modal Overlay managed here in the application layer!
          if (_selectedMatch != null) _buildMatchDetailOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PREDATOR WORLD 10-BALL CHAMPIONSHIP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.blueAccent.shade100,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tournament Road Map',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFB300),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final bool isFinal = match.id == 31;
    final bool isWinner1 =
        match.hasWinner && match.winner.name == match.player1.name;
    final bool isWinner2 =
        match.hasWinner && match.winner.name == match.player2.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMatch = match;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10162B).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: match.status == MatchStatus.dispute
                ? Colors.redAccent.withValues(alpha: 0.6)
                : match.status == MatchStatus.inProgress
                ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                : isFinal
                ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            width:
                match.status == MatchStatus.dispute ||
                    match.status == MatchStatus.inProgress ||
                    isFinal
                ? 1.5
                : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Column(
            children: [
              // Pill tag bar
              Container(
                height: 18,
                color: match.status == MatchStatus.dispute
                    ? Colors.redAccent.withValues(alpha: 0.15)
                    : match.status == MatchStatus.inProgress
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.1)
                    : isFinal
                    ? const Color(0xFFFFB300).withValues(alpha: 0.1)
                    : const Color(0xFF141C35),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isFinal
                                ? const Color(0xFFFFB300)
                                : const Color(
                                    0xFF0066FF,
                                  ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            match.label,
                            style: TextStyle(
                              color: isFinal
                                  ? Colors.black
                                  : const Color(0xFF82B1FF),
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (match.status == MatchStatus.dispute) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning,
                                  size: 7,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'TRANH CHẤP',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (match.status == MatchStatus.inProgress) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00E5FF,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00E5FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    Text(
                      match.table,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 7.5,
                      ),
                    ),
                    Text(
                      match.time,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Players
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPlayerRow(
                        match.player1,
                        match.score1,
                        isWinner1,
                        match.hasWinner,
                      ),
                      Container(
                        height: 0.5,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                      _buildPlayerRow(
                        match.player2,
                        match.score2,
                        isWinner2,
                        match.hasWinner,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    Player player,
    int score,
    bool isWinner,
    bool hasPlayed,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            shape: BoxShape.circle,
          ),
          child: Text(player.flag, style: const TextStyle(fontSize: 10)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: player.isWalkOver
                        ? Colors.white.withValues(alpha: 0.25)
                        : isWinner
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.55),
                    fontSize: 9.5,
                    fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
                    fontStyle: player.isWalkOver
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
              if (player.isCheckedIn) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 9, color: Colors.greenAccent),
              ],
            ],
          ),
        ),
        if (!player.isWalkOver)
          Container(
            width: 18,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isWinner
                  ? const Color(0xFF0066FF)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                color: isWinner
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: 9.5,
                fontWeight: isWinner ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMatchDetailOverlay() {
    final MatchModel match = _selectedMatch!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMatch = null;
          });
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A30).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 25,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              match.label.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedMatch = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailMeta(
                            Icons.table_restaurant,
                            match.table,
                            'ARENA TABLE',
                          ),
                          _buildDetailMeta(
                            Icons.access_time_filled,
                            match.time,
                            'SCHEDULE',
                          ),
                          _buildDetailMeta(
                            match.status == MatchStatus.dispute
                                ? Icons.warning
                                : match.status == MatchStatus.inProgress
                                ? Icons.play_arrow
                                : match.status == MatchStatus.completed
                                ? Icons.check_circle
                                : Icons.schedule,
                            match.status == MatchStatus.dispute
                                ? 'Disputed'
                                : match.status == MatchStatus.inProgress
                                ? 'Live Scoring'
                                : match.status == MatchStatus.completed
                                ? 'Completed'
                                : 'Scheduled',
                            'MATCH STATUS',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailPlayerCard(
                        match.player1,
                        match.score1,
                        match.winner.name == match.player1.name,
                        match.hasWinner,
                      ),
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.bolt,
                        color: Color(0xFFFFB300),
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailPlayerCard(
                        match.player2,
                        match.score2,
                        match.winner.name == match.player2.name,
                        match.hasWinner,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMeta(IconData icon, String value, String title) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPlayerCard(
    Player player,
    int score,
    bool isWinner,
    bool hasPlayed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFF0066FF).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner
              ? const Color(0xFF0066FF).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(player.flag, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        color: player.isWalkOver
                            ? Colors.white24
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: isWinner
                            ? FontWeight.w900
                            : FontWeight.w600,
                        fontStyle: player.isWalkOver
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    if (player.isCheckedIn) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.greenAccent.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: 7,
                              color: Colors.greenAccent,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'CHECKED-IN',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 6,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (isWinner && !player.isWalkOver)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'WINNER',
                      style: TextStyle(
                        color: Colors.blueAccent.shade100,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!player.isWalkOver)
            Text(
              '$score',
              style: TextStyle(
                color: isWinner ? const Color(0xFF00E5FF) : Colors.white30,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}
