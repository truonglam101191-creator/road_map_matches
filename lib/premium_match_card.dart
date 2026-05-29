import 'package:flutter/material.dart';
import 'animated_tournament_bracket.dart';

/// A premium, beautiful default match card widget to display competitor and status information.
/// Integrated with [MatchModel] and [Player] properties, including ELO ratings,
/// check-in QR check-ins, dispute indicators, and live scoring animations.
class PremiumMatchCard extends StatefulWidget {
  final MatchModel<dynamic> match;
  final String? Function(dynamic)? getPlayerName;
  final String? Function(dynamic)? getPlayerFlag;
  final int? Function(dynamic)? getPlayerElo;
  final bool Function(dynamic)? getPlayerCheckIn;
  final bool Function(dynamic)? getPlayerWalkOver;
  
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color disputeColor;
  final VoidCallback? onTap;

  const PremiumMatchCard({
    super.key,
    required this.match,
    this.getPlayerName,
    this.getPlayerFlag,
    this.getPlayerElo,
    this.getPlayerCheckIn,
    this.getPlayerWalkOver,
    this.primaryColor = const Color(0xFF0066FF),
    this.secondaryColor = const Color(0xFF00E5FF),
    this.surfaceColor = const Color(0xFF131A30),
    this.accentColor = const Color(0xFFFFB300),
    this.disputeColor = const Color(0xFFFF3366),
    this.onTap,
  });

  @override
  State<PremiumMatchCard> createState() => _PremiumMatchCardState();
}

class _PremiumMatchCardState extends State<PremiumMatchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.match.status == MatchStatus.inProgress) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PremiumMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.match.status == MatchStatus.inProgress &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.match.status != MatchStatus.inProgress &&
        _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _name(dynamic p) {
    if (widget.getPlayerName != null) return widget.getPlayerName!(p) ?? '';
    if (p is Player) return p.name;
    try {
      return (p as dynamic).name.toString();
    } catch (_) {
      return p?.toString() ?? 'TBD';
    }
  }

  String _flag(dynamic p) {
    if (widget.getPlayerFlag != null) return widget.getPlayerFlag!(p) ?? '👤';
    if (p is Player) return p.flag;
    try {
      return (p as dynamic).flag.toString();
    } catch (_) {
      return '👤';
    }
  }

  int? _elo(dynamic p) {
    if (widget.getPlayerElo != null) return widget.getPlayerElo!(p);
    try {
      return (p as dynamic).elo as int;
    } catch (_) {
      return null;
    }
  }

  bool _checkedIn(dynamic p) {
    if (widget.getPlayerCheckIn != null) return widget.getPlayerCheckIn!(p);
    if (p is Player) return p.isCheckedIn;
    try {
      return (p as dynamic).isCheckedIn == true;
    } catch (_) {
      return false;
    }
  }

  bool _walkOver(dynamic p) {
    if (widget.getPlayerWalkOver != null) return widget.getPlayerWalkOver!(p);
    if (p is Player) return p.isWalkOver;
    try {
      return (p as dynamic).isWalkOver == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final hasDispute = widget.match.status == MatchStatus.dispute;
    final isLive = widget.match.status == MatchStatus.inProgress;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.surfaceColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasDispute
                  ? widget.disputeColor.withValues(alpha: 0.8)
                  : (isLive
                      ? widget.secondaryColor.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.08)),
              width: (hasDispute || isLive) ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (hasDispute)
                BoxShadow(
                  color: widget.disputeColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              else if (isLive)
                BoxShadow(
                  color: widget.secondaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Left status indicator bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header info: Label, Table, Status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.match.label,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (widget.match.table.isNotEmpty && widget.match.table != 'TBD') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    widget.match.table,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          _buildStatusBadge(isLive),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Competitor 1
                      _buildCompetitorRow(0),

                      const SizedBox(height: 2),
                      Divider(color: Colors.white.withValues(alpha: 0.04), height: 1, thickness: 1),
                      const SizedBox(height: 2),

                      // Competitor 2
                      _buildCompetitorRow(1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.match.status) {
      case MatchStatus.scheduled:
        return Colors.white24;
      case MatchStatus.inProgress:
        return widget.secondaryColor;
      case MatchStatus.completed:
        return widget.primaryColor;
      case MatchStatus.dispute:
        return widget.disputeColor;
    }
  }

  Widget _buildStatusBadge(bool isLive) {
    if (widget.match.status == MatchStatus.dispute) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: widget.disputeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: widget.disputeColor, size: 9),
            const SizedBox(width: 2),
            Text(
              'DISPUTE',
              style: TextStyle(
                color: widget.disputeColor,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isLive) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: widget.secondaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: widget.secondaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (widget.match.status == MatchStatus.completed) {
      return Icon(
        Icons.check_circle_rounded,
        color: widget.primaryColor,
        size: 11,
      );
    }

    // Scheduled/Time
    if (widget.match.time.isNotEmpty && widget.match.time != 'TBD') {
      return Text(
        widget.match.time,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCompetitorRow(int index) {
    if (index >= widget.match.competitors.length) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chờ xác định',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '-',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    final competitor = widget.match.competitors[index];
    final name = _name(competitor);
    final flag = _flag(competitor);
    final elo = _elo(competitor);
    final isCheckedIn = _checkedIn(competitor);
    final isWalkOver = _walkOver(competitor);

    final score = index < widget.match.scores.length ? widget.match.scores[index] : 0;
    
    // Determine winner highlight
    final bool isWinner = widget.match.hasWinner && widget.match.winner != null && 
        _name(widget.match.winner) == name;

    // Dim style for walkover or loser if match completed
    final bool isDimmed = isWalkOver || (widget.match.hasWinner && !isWinner);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Name, Flag, ELO, Check-In
          Expanded(
            child: Row(
              children: [
                Text(
                  flag,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDimmed ? Colors.white30 : null,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isWinner
                          ? Colors.white
                          : (isDimmed
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.75)),
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                      decoration: isWalkOver ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (elo != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($elo)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 8.5,
                    ),
                  ),
                ],
                if (isCheckedIn && !isWalkOver) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Đã check-in sân thi đấu',
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: widget.secondaryColor.withValues(alpha: 0.8),
                      size: 10,
                    ),
                  ),
                ],
                if (isWalkOver) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'WO',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Score
          const SizedBox(width: 8),
          Text(
            isWalkOver ? 'L' : '$score',
            style: TextStyle(
              color: isWinner
                  ? widget.secondaryColor
                  : (isDimmed
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.6)),
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
