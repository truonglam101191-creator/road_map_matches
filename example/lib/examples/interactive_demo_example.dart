import 'package:flutter/material.dart';
import 'package:road_map/animated_tournament_bracket.dart';
import '../bracket_data.dart';

class InteractiveDemoExample extends StatefulWidget {
  const InteractiveDemoExample({super.key});

  @override
  State<InteractiveDemoExample> createState() => _InteractiveDemoExampleState();
}

class _InteractiveDemoExampleState extends State<InteractiveDemoExample> {
  MatchModel<dynamic>? _selectedMatch;
  int _selectedCategoryTab = 0; // 0: Singles, 1: Teams, 2: Mix

  ConnectorStyle _connectorStyle = ConnectorStyle.curved;
  ConnectorLineType _lineType = ConnectorLineType.solid;
  double _dashLength = 12.0;
  double _dashGap = 8.0;
  double _dashSpeedMultiplier = 1.0;
  bool _pulseGlow = true;
  bool _useLineGradients = true;
  double _lineThickness = 2.0;
  double _activeLineThickness = 3.0;
  double _activeGlowWidth = 8.0;
  bool _showSettings = true;

  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<List<MatchModel<dynamic>>> _getBranchRounds() {
    switch (_selectedCategoryTab) {
      case 0:
        return [
          BracketData.round1Tab1,
          BracketData.round2Tab1,
          BracketData.round3Tab1,
          BracketData.round4Tab1,
        ];
      case 1:
        return [BracketData.teamRound1, BracketData.teamRound2];
      case 2:
      default:
        return [BracketData.mixRound1];
    }
  }

  MatchModel<dynamic>? _getGrandFinal() {
    switch (_selectedCategoryTab) {
      case 0:
        return BracketData.grandFinal;
      case 1:
        return BracketData.teamGrandFinal;
      case 2:
      default:
        return BracketData.mixGrandFinal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        title: const Text('Interactive Bracket Demo'),
        backgroundColor: const Color(0xFF131A30),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showSettings ? Icons.tune : Icons.settings,
              color: _showSettings ? const Color(0xFF00E5FF) : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                _buildCategorySelector(),
                const SizedBox(height: 8),
                _buildSettingsPanel(),
                Expanded(
                  child: AnimatedTournamentBracket<MatchModel<dynamic>>(
                    key: ValueKey(
                      '$_selectedCategoryTab-$_connectorStyle-$_pulseGlow-$_useLineGradients-$_lineThickness-$_activeLineThickness-$_activeGlowWidth-$_lineType-$_searchQuery-$_dashLength-$_dashGap-$_dashSpeedMultiplier',
                    ),
                    branch1Rounds: _getBranchRounds(),
                    grandFinal: _getGrandFinal(),
                    connectorStyle: _connectorStyle,
                    lineType: _lineType,
                    dashLength: _dashLength,
                    dashGap: _dashGap,
                    dashSpeedMultiplier: _dashSpeedMultiplier,
                    searchHighlightQuery: _searchQuery,
                    pulseGlow: _pulseGlow,
                    useLineGradients: _useLineGradients,
                    lineThickness: _lineThickness,
                    activeLineThickness: _activeLineThickness,
                    activeGlowWidth: _activeGlowWidth,
                    roundHeaderBuilder: (context, roundIndex) {
                      final rounds = _getBranchRounds();
                      final totalRounds =
                          rounds.length + (_getGrandFinal() != null ? 1 : 0);

                      String roundName = '';
                      int matchCount = 0;

                      if (roundIndex == totalRounds - 1) {
                        roundName = 'Chung Kết (Final)';
                        matchCount = 1;
                      } else {
                        final titles = _selectedCategoryTab == 0
                            ? ['Vòng R16', 'Tứ Kết (QF)', 'Bán Kết (SF)']
                            : _selectedCategoryTab == 1
                            ? ['Tứ Kết (QF)', 'Bán Kết (SF)']
                            : ['Bán Kết (SF)'];

                        if (roundIndex < titles.length) {
                          roundName = titles[roundIndex];
                        } else {
                          roundName = 'Vòng ${roundIndex + 1}';
                        }
                        matchCount = rounds[roundIndex].length;
                      }

                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131A30).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFF00E5FF,
                            ).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFF00E5FF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$roundName • $matchCount Trận',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    hasWinner: (match) => match.hasWinner,
                    getWinnerName: (match) => _getCompetitorName(match.winner),
                    getPlayer1Name: (match) => match.competitors.isNotEmpty
                        ? _getCompetitorName(match.competitors.first)
                        : '',
                    getPlayer2Name: (match) => match.competitors.length > 1
                        ? _getCompetitorName(match.competitors.last)
                        : '',
                    tabBuilder: (context, index, isSelected) {
                      final List<String> titles;
                      if (_selectedCategoryTab == 0) {
                        titles = [
                          'Round 1',
                          'Last 16',
                          'Quarter',
                          'Semi',
                          'Final',
                        ];
                      } else if (_selectedCategoryTab == 1) {
                        titles = ['Quarter', 'Semi', 'Final'];
                      } else {
                        titles = ['Semi', 'Final'];
                      }
                      return Text(
                        index < titles.length
                            ? titles[index]
                            : 'Round ${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                        ),
                      );
                    },
                    itemBuilder: (context, match) => _buildMatchCard(match),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMatch != null) _buildMatchDetailOverlay(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      'Singles (Đấu đơn)',
      'Teams (Đồng đội)',
      'Mix (Hỗn hợp)',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF131A30).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: List.generate(categories.length, (index) {
            final isSelected = _selectedCategoryTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryTab = index;
                    _selectedMatch = null;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF0066FF), Color(0xFF00E5FF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: _showSettings
          ? (_lineType == ConnectorLineType.flowing ? 370 : 260)
          : 0,
      child: ClipRRect(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF131A30).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'TÙY CHỈNH ROAD MAP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Gradients',
                          style: TextStyle(fontSize: 9, color: Colors.white70),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 20,
                          width: 35,
                          child: Switch(
                            value: _useLineGradients,
                            activeThumbColor: const Color(0xFF00E5FF),
                            onChanged: (val) {
                              setState(() {
                                _useLineGradients = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Pulsing',
                          style: TextStyle(fontSize: 9, color: Colors.white70),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 20,
                          width: 35,
                          child: Switch(
                            value: _pulseGlow,
                            activeThumbColor: const Color(0xFF00E5FF),
                            onChanged: (val) {
                              setState(() {
                                _pulseGlow = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Kiểu nối:',
                      style: TextStyle(fontSize: 9.5, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    ...ConnectorStyle.values.map((style) {
                      final isSel = _connectorStyle == style;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            style.name == 'curved'
                                ? 'Uốn cong'
                                : style.name == 'sharp'
                                ? 'Góc nhọn'
                                : 'Đường thẳng',
                            style: TextStyle(
                              fontSize: 9,
                              color: isSel ? Colors.white : Colors.white60,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: const Color(0xFF0066FF),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _connectorStyle = style;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Hiệu ứng nét:',
                      style: TextStyle(fontSize: 9.5, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    ...ConnectorLineType.values.map((type) {
                      final isSel = _lineType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            type == ConnectorLineType.flowing
                                ? 'Chạy nét (Flowing)'
                                : 'Liền nét (Solid)',
                            style: TextStyle(
                              fontSize: 9,
                              color: isSel ? Colors.white : Colors.white60,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: const Color(0xFF0066FF),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _lineType = type;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Tìm đấu thủ:',
                      style: TextStyle(fontSize: 9.5, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Nhập tên đấu thủ để highlight đường đi...',
                            hintStyle: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9.5,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF00E5FF),
                              size: 14,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                    },
                                    child: const Icon(
                                      Icons.clear,
                                      color: Colors.white54,
                                      size: 14,
                                    ),
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8,
                            ),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF00E5FF),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Độ dày nét: ${_lineThickness.toStringAsFixed(1)}px',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                          Slider(
                            value: _lineThickness,
                            min: 1.0,
                            max: 6.0,
                            activeColor: const Color(0xFF0066FF),
                            onChanged: (val) {
                              setState(() {
                                _lineThickness = val;
                                _activeLineThickness = val + 1.0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Độ rộng hào quang: ${_activeGlowWidth.toStringAsFixed(1)}px',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                          Slider(
                            value: _activeGlowWidth,
                            min: 2.0,
                            max: 16.0,
                            activeColor: const Color(0xFF00E5FF),
                            onChanged: (val) {
                              setState(() {
                                _activeGlowWidth = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_lineType == ConnectorLineType.flowing) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 0.5,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Độ dài nét đứt: ${_dashLength.toStringAsFixed(1)}px',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white70,
                              ),
                            ),
                            Slider(
                              value: _dashLength,
                              min: 4.0,
                              max: 30.0,
                              activeColor: const Color(0xFF0066FF),
                              onChanged: (val) {
                                setState(() {
                                  _dashLength = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Khoảng cách nét: ${_dashGap.toStringAsFixed(1)}px',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white70,
                              ),
                            ),
                            Slider(
                              value: _dashGap,
                              min: 2.0,
                              max: 20.0,
                              activeColor: const Color(0xFF00E5FF),
                              onChanged: (val) {
                                setState(() {
                                  _dashGap = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tốc độ chạy nét: ${_dashSpeedMultiplier.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white70,
                              ),
                            ),
                            Slider(
                              value: _dashSpeedMultiplier,
                              min: 0.2,
                              max: 3.0,
                              activeColor: const Color(0xFFFFB300),
                              onChanged: (val) {
                                setState(() {
                                  _dashSpeedMultiplier = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: SizedBox(), // spacer
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final bool isWinner1 =
        match.hasWinner &&
        match.winner?.name ==
            (match.competitors.isNotEmpty ? match.competitors.first.name : '');
    final bool isWinner2 =
        match.hasWinner &&
        match.winner?.name ==
            (match.competitors.length > 1 ? match.competitors.last.name : '');

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
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 18,
              color: match.status == MatchStatus.dispute
                  ? Colors.redAccent.withValues(alpha: 0.15)
                  : match.status == MatchStatus.inProgress
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.1)
                  : const Color(0xFF141C35),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.label,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    match.table,
                    style: const TextStyle(color: Colors.white30, fontSize: 8),
                  ),
                  Text(
                    match.time,
                    style: const TextStyle(color: Colors.white30, fontSize: 8),
                  ),
                ],
              ),
            ),
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
                      match.competitors.isNotEmpty
                          ? match.competitors[0]
                          : (match.hasWinner
                                ? Player.walkOver
                                : const Player(name: 'TBD', flag: '❓')),
                      match.scores.isNotEmpty ? match.scores[0] : 0,
                      isWinner1,
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                    _buildPlayerRow(
                      match.competitors.length > 1
                          ? match.competitors[1]
                          : (match.hasWinner
                                ? Player.walkOver
                                : const Player(name: 'TBD', flag: '❓')),
                      match.scores.length > 1 ? match.scores[1] : 0,
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
  }

  Widget _buildPlayerRow(dynamic competitor, int score, bool isWinner) {
    final name = _getCompetitorName(competitor);
    final logo = _getCompetitorLogo(competitor);
    final isWalkOver = _isCompetitorWalkOver(competitor);
    final isCheckedIn = _isCompetitorCheckedIn(competitor);

    return Row(
      children: [
        Text(logo, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isWalkOver
                  ? Colors.white24
                  : isWinner
                  ? Colors.white
                  : Colors.white60,
              fontSize: 9.5,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (isCheckedIn)
          const Icon(Icons.verified, size: 9, color: Colors.greenAccent),
        const SizedBox(width: 4),
        if (!isWalkOver)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isWinner ? const Color(0xFF0066FF) : Colors.white10,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$score',
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildMatchDetailOverlay() {
    final match = _selectedMatch!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMatch = null),
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131A30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    match.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bàn đấu: ${match.table} • Thời gian: ${match.time}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _selectedMatch = null),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCompetitorName(dynamic competitor) {
    if (competitor == null) return 'TBD';
    if (competitor is Player) return competitor.name;
    if (competitor is Team) return competitor.name;
    return 'TBD';
  }

  String _getCompetitorLogo(dynamic competitor) {
    if (competitor == null) return '❓';
    if (competitor is Player) return competitor.flag;
    if (competitor is Team) return competitor.logo;
    return '❓';
  }

  bool _isCompetitorCheckedIn(dynamic competitor) {
    if (competitor is Player) return competitor.isCheckedIn;
    if (competitor is Team) return competitor.isCheckedIn;
    return false;
  }

  bool _isCompetitorWalkOver(dynamic competitor) {
    if (competitor is Player) return competitor.isWalkOver;
    if (competitor is Team) return competitor.isWalkOver;
    return false;
  }
}
