import 'package:flutter/material.dart';
import 'package:road_map/road_map.dart';

class DrawEngineAndZoomExample extends StatefulWidget {
  const DrawEngineAndZoomExample({super.key});

  @override
  State<DrawEngineAndZoomExample> createState() => _DrawEngineAndZoomExampleState();
}

class _DrawEngineAndZoomExampleState extends State<DrawEngineAndZoomExample> {
  // Input list of players
  final List<String> _rawPlayers = [
    'Nguyễn Văn A',
    'Trần Thị B',
    'Lê Hoàng C',
    'Phạm Minh D',
    'Hoàng Anh E',
    'Vũ Đức F',
    'Ngô Quốc G',
    'Đặng Thanh H',
    'Bùi Tiến I',
    'Đỗ Ngọc J',
    'Hồ Gia K',
    'Phan Duy L',
  ];

  final List<String> _seeds = [
    'Nguyễn Văn A', // Seed 1
    'Trần Thị B',   // Seed 2
    'Lê Hoàng C',   // Seed 3
    'Phạm Minh D',   // Seed 4
  ];

  late List<List<MatchModel<Player>>> _rounds;
  MatchModel<Player>? _grandFinal;
  MatchModel<Player>? _thirdPlaceMatch;

  @override
  void initState() {
    super.initState();
    _generateBracket();
  }

  void _generateBracket() {
    // 1. Convert raw names to Player models
    final players = _rawPlayers.map((name) {
      final isSeed = _seeds.contains(name);
      return Player(
        name: name,
        flag: isSeed ? '⭐️' : '👤',
        isCheckedIn: isSeed, // Autochecked seeds for demonstration
      );
    }).toList();

    final seedsList = _seeds.map((name) {
      return Player(name: name, flag: '⭐️', isCheckedIn: true);
    }).toList();

    // 2. Build rounds using TournamentDrawEngine
    final generatedRounds = TournamentDrawEngine.buildInitialBracket<Player>(
      players: players,
      seeds: seedsList,
      matchLabelPrefix: 'Trận ',
      includeFinal: false,
    );

    setState(() {
      _rounds = generatedRounds;
      
      // Initialize Grand Final and Third Place
      int nextId = 100;
      
      _grandFinal = MatchModel<Player>(
        id: nextId++,
        label: 'Chung Kết',
        table: 'Bàn Chính',
        time: 'Chủ Nhật 20:00',
        competitors: const [],
        scores: const [0, 0],
        status: MatchStatus.scheduled,
      );

      _thirdPlaceMatch = MatchModel<Player>(
        id: nextId++,
        label: 'Tranh Hạng 3',
        table: 'Bàn Phụ',
        time: 'Chủ Nhật 18:00',
        competitors: const [],
        scores: const [0, 0],
        status: MatchStatus.scheduled,
      );
    });
  }

  // Advancing winners logic
  void _updateMatch(MatchModel<Player> updatedMatch, int roundIndex, int matchIndex) {
    setState(() {
      _rounds[roundIndex][matchIndex] = updatedMatch;
      _advanceWinners();
    });
  }

  void _updateGrandFinal(MatchModel<Player> updatedMatch) {
    setState(() {
      _grandFinal = updatedMatch;
    });
  }

  void _updateThirdPlace(MatchModel<Player> updatedMatch) {
    setState(() {
      _thirdPlaceMatch = updatedMatch;
    });
  }

  void _advanceWinners() {
    // Process each round from first to semi
    for (int r = 0; r < _rounds.length - 1; r++) {
      final currentRound = _rounds[r];
      final nextRound = _rounds[r + 1];

      for (int m = 0; m < nextRound.length; m++) {
        if (m * 2 < currentRound.length && m * 2 + 1 < currentRound.length) {
          final parent1 = currentRound[m * 2];
          final parent2 = currentRound[m * 2 + 1];

          final competitors = <Player>[];
          if (parent1.hasWinner && parent1.winner != null) {
            competitors.add(parent1.winner!);
          }
          if (parent2.hasWinner && parent2.winner != null) {
            competitors.add(parent2.winner!);
          }

          // Preserve scores and status unless competitors changed
          final existing = nextRound[m];
          bool competitorsChanged = existing.competitors.length != competitors.length;
          if (!competitorsChanged) {
            for (int i = 0; i < competitors.length; i++) {
              if (existing.competitors[i].name != competitors[i].name) {
                competitorsChanged = true;
                break;
              }
            }
          }

          if (competitorsChanged) {
            nextRound[m] = MatchModel<Player>(
              id: existing.id,
              label: existing.label,
              table: existing.table,
              time: existing.time,
              competitors: competitors,
              scores: List.filled(competitors.length, 0),
              status: MatchStatus.scheduled,
            );
          }
        }
      }
    }

    // Now advance to Grand Final & Third Place from the last round of _rounds (semifinals)
    final semiRound = _rounds.last;
    if (semiRound.length >= 2) {
      final semi1 = semiRound[0];
      final semi2 = semiRound[1];

      // Finalists
      final finalists = <Player>[];
      if (semi1.hasWinner && semi1.winner != null) finalists.add(semi1.winner!);
      if (semi2.hasWinner && semi2.winner != null) finalists.add(semi2.winner!);

      bool gfChanged = _grandFinal!.competitors.length != finalists.length;
      if (!gfChanged) {
        for (int i = 0; i < finalists.length; i++) {
          if (_grandFinal!.competitors[i].name != finalists[i].name) {
            gfChanged = true;
            break;
          }
        }
      }

      if (gfChanged) {
        _grandFinal = MatchModel<Player>(
          id: _grandFinal!.id,
          label: _grandFinal!.label,
          table: _grandFinal!.table,
          time: _grandFinal!.time,
          competitors: finalists,
          scores: List.filled(finalists.length, 0),
          status: MatchStatus.scheduled,
        );
      }

      // Losers for Third Place
      final losers = <Player>[];
      if (semi1.hasWinner) {
        final loser = semi1.competitors.firstWhere((p) => p.name != semi1.winner?.name, orElse: () => Player.walkOver);
        if (!loser.isWalkOver) losers.add(loser);
      }
      if (semi2.hasWinner) {
        final loser = semi2.competitors.firstWhere((p) => p.name != semi2.winner?.name, orElse: () => Player.walkOver);
        if (!loser.isWalkOver) losers.add(loser);
      }

      bool tpChanged = _thirdPlaceMatch!.competitors.length != losers.length;
      if (!tpChanged) {
        for (int i = 0; i < losers.length; i++) {
          if (_thirdPlaceMatch!.competitors[i].name != losers[i].name) {
            tpChanged = true;
            break;
          }
        }
      }

      if (tpChanged) {
        _thirdPlaceMatch = MatchModel<Player>(
          id: _thirdPlaceMatch!.id,
          label: _thirdPlaceMatch!.label,
          table: _thirdPlaceMatch!.table,
          time: _thirdPlaceMatch!.time,
          competitors: losers,
          scores: List.filled(losers.length, 0),
          status: MatchStatus.scheduled,
        );
      }
    }
  }

  void _showMatchDetailDialog(MatchModel<Player> match, int? roundIndex, int? matchIndex) {
    final isGF = roundIndex == null && matchIndex == null; // Grand Final
    final isTP = roundIndex == null && matchIndex == 1;   // Third Place

    final p1 = match.competitors.isNotEmpty ? match.competitors[0] : null;
    final p2 = match.competitors.length > 1 ? match.competitors[1] : null;

    final score1Controller = TextEditingController(text: match.scores.isNotEmpty ? match.scores[0].toString() : '0');
    final score2Controller = TextEditingController(text: match.scores.length > 1 ? match.scores[1].toString() : '0');
    
    MatchStatus tempStatus = match.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF131A30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.sports_esports, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 10),
                  Text(
                    'Chi Tiết ${match.label}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Competitor 1 Row
                    if (p1 != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${p1.flag} ${p1.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: score1Controller,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white24),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Competitor 2 Row
                    if (p2 != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${p2.flag} ${p2.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: score2Controller,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white24),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (p1 == null && p2 == null) ...[
                      const Text(
                        'Chờ xác định đấu thủ từ vòng trước.',
                        style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Status Dropdown
                    DropdownButtonFormField<MatchStatus>(
                      initialValue: tempStatus,
                      dropdownColor: const Color(0xFF131A30),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái Trận đấu',
                        labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      ),
                      items: MatchStatus.values.map((status) {
                        return DropdownMenuItem<MatchStatus>(
                          value: status,
                          child: Text(
                            status.name.toUpperCase(),
                            style: TextStyle(
                              color: status == MatchStatus.dispute 
                                  ? const Color(0xFFFF3366) 
                                  : (status == MatchStatus.inProgress ? const Color(0xFF00E5FF) : Colors.white),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            tempStatus = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('HỦY', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final int s1 = int.tryParse(score1Controller.text) ?? 0;
                    final int s2 = int.tryParse(score2Controller.text) ?? 0;

                    final updated = MatchModel<Player>(
                      id: match.id,
                      label: match.label,
                      table: match.table,
                      time: match.time,
                      competitors: match.competitors,
                      scores: [s1, s2],
                      status: tempStatus,
                    );

                    if (isGF) {
                      _updateGrandFinal(updated);
                    } else if (isTP) {
                      _updateThirdPlace(updated);
                    } else {
                      _updateMatch(updated, roundIndex!, matchIndex!);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('LƯU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = _rawPlayers.length;
    final int byes = TournamentDrawEngine.calculateByes(count);

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        title: const Text('Draw Engine & 2D Zoom Demo'),
        backgroundColor: const Color(0xFF131A30),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Panel (Glassmorphism design)
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF131A30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BỐC THĂM TỰ ĐỘNG & BẢN ĐỒ THU PHÓNG 2D',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Số lượng VĐV: $count. Số suất miễn đấu (BYE): $byes. Hạt giống: ${_seeds.length}.',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nhấp vào một Thẻ trận đấu để cập nhật Tỷ số, Trạng thái Check-in, Bỏ cuộc (Walkover) hoặc Tranh chấp (Dispute) để xem hiệu ứng đường nối đóng băng thời gian thực!',
                  style: TextStyle(color: Colors.white38, fontSize: 10.5, height: 1.3),
                ),
              ],
            ),
          ),
          
          // Bracket rendering area
          Expanded(
            child: AnimatedTournamentBracket<MatchModel<Player>>(
              branch1Rounds: _rounds,
              grandFinal: _grandFinal,
              thirdPlaceMatch: _thirdPlaceMatch,
              defaultViewMode: BracketViewMode.interactive2D, // Zoom/Pan mode by default
              showViewModeToggle: true, // Let user switch between 2D Map and Swipe mode
              
              // Map dispute color and status
              getMatchStatus: (m) => m.status,
              disputeColor: const Color(0xFFFF3366),
              
              hasWinner: (m) => m.hasWinner,
              getWinnerName: (m) => m.winner?.name ?? '',
              getPlayer1Name: (m) => m.competitors.isNotEmpty ? m.competitors.first.name : '',
              getPlayer2Name: (m) => m.competitors.length > 1 ? m.competitors.last.name : '',
              
              primaryColor: const Color(0xFF0066FF),
              secondaryColor: const Color(0xFF00E5FF),
              accentColor: const Color(0xFFFFB300),
              surfaceColor: const Color(0xFF131A30),
              backgroundColor: const Color(0xFF070B19),
              
              roundHeaderBuilder: (context, roundIndex) {
                final titles = [
                  'Vòng 1 (Vòng 16)',
                  'Tứ Kết (QF)',
                  'Bán Kết (SF)',
                  'Chung Kết (GF) & Trạng 3',
                ];
                final title = roundIndex < titles.length ? titles[roundIndex] : 'Vòng ${roundIndex + 1}';
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A30),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              
              itemBuilder: (context, match) {
                // Find if match is in rounds
                int? foundRoundIndex;
                int? foundMatchIndex;
                
                for (int r = 0; r < _rounds.length; r++) {
                  final idx = _rounds[r].indexOf(match);
                  if (idx != -1) {
                    foundRoundIndex = r;
                    foundMatchIndex = idx;
                    break;
                  }
                }

                // If not in rounds, check final and third place
                final bool isGF = match.id == _grandFinal?.id;
                final bool isTP = match.id == _thirdPlaceMatch?.id;

                return PremiumMatchCard(
                  match: match,
                  primaryColor: const Color(0xFF0066FF),
                  secondaryColor: const Color(0xFF00E5FF),
                  surfaceColor: const Color(0xFF131A30),
                  accentColor: const Color(0xFFFFB300),
                  disputeColor: const Color(0xFFFF3366),
                  onTap: () {
                    if (isGF) {
                      _showMatchDetailDialog(_grandFinal!, null, null);
                    } else if (isTP) {
                      _showMatchDetailDialog(_thirdPlaceMatch!, null, 1);
                    } else {
                      _showMatchDetailDialog(match, foundRoundIndex, foundMatchIndex);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
