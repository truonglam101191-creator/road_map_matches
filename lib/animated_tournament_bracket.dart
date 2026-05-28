import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Enum representing the execution status of a match based on the tournament workflow.
enum MatchStatus { scheduled, inProgress, completed, dispute }

/// Style of connection lines between rounds
enum ConnectorStyle { curved, sharp, straight }

enum ConnectorLineType { solid, flowing }

/// Convenience model representing a player in a tournament (can be used as a default).
class Player {
  final String name;
  final String flag;
  final bool isWalkOver;
  final bool isCheckedIn; // QR check-in status

  const Player({
    required this.name,
    required this.flag,
    this.isWalkOver = false,
    this.isCheckedIn = false,
  });

  static const walkOver = Player(
    name: 'Walk Over',
    flag: '👤',
    isWalkOver: true,
    isCheckedIn: false,
  );
}

/// Convenience model representing a match in a tournament (can be used as a default).
class MatchModel<P> {
  final int id;
  final String label;
  final String table;
  final String time;
  final List<P> competitors;
  final List<int> scores;
  final MatchStatus status; // Match execution status

  const MatchModel({
    required this.id,
    required this.label,
    required this.table,
    required this.time,
    required this.competitors,
    required this.scores,
    this.status = MatchStatus.scheduled,
  });

  bool get hasWinner {
    if (status == MatchStatus.completed) return true;
    if (scores.length >= 2 && (scores[0] != 0 || scores[1] != 0)) return true;
    for (final competitor in competitors) {
      if (_isWalkOver(competitor)) return true;
    }
    return false;
  }

  P? get winner {
    if (competitors.isEmpty) return null;
    if (competitors.length == 1) return competitors[0];

    final competitor1 = competitors[0];
    final competitor2 = competitors[1];

    if (_isWalkOver(competitor1) && !_isWalkOver(competitor2)) {
      return competitor2;
    }
    if (_isWalkOver(competitor2) && !_isWalkOver(competitor1)) {
      return competitor1;
    }

    final score1 = scores.isNotEmpty ? scores[0] : 0;
    final score2 = scores.length > 1 ? scores[1] : 0;

    return score1 >= score2 ? competitor1 : competitor2;
  }

  static bool _isWalkOver(dynamic p) {
    if (p == null) return false;
    if (p is Player) return p.isWalkOver;
    try {
      return (p as dynamic).isWalkOver == true;
    } catch (_) {
      return false;
    }
  }
}

/// A high-performance CustomPainter that draws orthogonal victory-glow connecting lines
/// between match cards of generic type T, dynamically morphing their coordinates in real time.
class BracketPainter<T> extends CustomPainter {
  final double cardWidth;
  final double cardHeight;
  final double horizontalGap;
  final double verticalGap;
  final double topOffset;
  final List<List<T>> branchRounds;
  final T? finalMatch;
  final double pageOffset;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color defaultLineColor;
  final double connectorRadius;
  final double lineThickness;
  final double activeLineThickness;
  final double activeGlowWidth;
  final double activeGlowOpacity;

  final ConnectorStyle connectorStyle;
  final ConnectorLineType lineType;
  final double dashLength;
  final double dashGap;
  final double dashSpeedMultiplier;
  final String? searchHighlightQuery;
  final double pulseValue;
  final double flowValue;
  final bool useLineGradients;

  // Optional connection line highlighting callbacks
  final bool Function(T match)? hasWinner;
  final String Function(T match)? getWinnerName;
  final String Function(T match)? getPlayer1Name;
  final String Function(T match)? getPlayer2Name;

  BracketPainter({
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.topOffset,
    required this.branchRounds,
    required this.finalMatch,
    required this.pageOffset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.defaultLineColor,
    required this.connectorRadius,
    required this.lineThickness,
    required this.activeLineThickness,
    required this.activeGlowWidth,
    required this.activeGlowOpacity,
    required this.connectorStyle,
    required this.lineType,
    required this.dashLength,
    required this.dashGap,
    required this.dashSpeedMultiplier,
    this.searchHighlightQuery,
    required this.pulseValue,
    required this.flowValue,
    required this.useLineGradients,
    this.hasWinner,
    this.getWinnerName,
    this.getPlayer1Name,
    this.getPlayer2Name,
  });

  double getActiveY(int round, int index) {
    final numRounds = branchRounds.length + (finalMatch != null ? 1 : 0);
    if (finalMatch != null && round == numRounds - 1) {
      return getActiveY(round - 1, 0);
    }
    if (round == 0) {
      return topOffset + index * (cardHeight + verticalGap) + cardHeight / 2;
    }

    final parent1Y = getActiveY(round - 1, index * 2);
    final parent2Y = getActiveY(round - 1, index * 2 + 1);
    final expandedY = (parent1Y + parent2Y) / 2;
    final compactY =
        topOffset + index * (cardHeight + verticalGap) + cardHeight / 2;

    final t = (pageOffset - (round - 1)).clamp(0.0, 1.0);
    return ui.lerpDouble(expandedY, compactY, t)!;
  }

  void _drawPath(Canvas canvas, Path path, Paint paint) {
    if (lineType == ConnectorLineType.flowing &&
        paint.style == PaintingStyle.stroke) {
      final double totalPattern = dashLength + dashGap;
      final double shift =
          (flowValue * dashSpeedMultiplier * totalPattern) % totalPattern;

      for (final ui.PathMetric metric in path.computeMetrics()) {
        double length = metric.length;
        double distance = shift;
        while (distance < length) {
          final double end = (distance + dashLength).clamp(0.0, length);
          final ui.Path segment = metric.extractPath(distance, end);
          canvas.drawPath(segment, paint);
          distance += totalPattern;
        }
      }
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final defaultPaint = Paint()
      ..color = defaultLineColor
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = activeLineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeGlowPaint = Paint()
      ..color = primaryColor.withValues(
        alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
      )
      ..strokeWidth = activeGlowWidth * (0.8 + 0.4 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < branchRounds.length - 1; i++) {
      _drawRoundConnections(
        canvas,
        i,
        branchRounds[i],
        branchRounds[i + 1],
        defaultPaint,
        activePaint,
        activeGlowPaint,
      );
    }

    if (finalMatch != null) {
      _drawFinalConnection(
        canvas,
        branchRounds.length - 1,
        branchRounds.last,
        finalMatch as T,
        defaultPaint,
        activePaint,
        activeGlowPaint,
      );
    }
  }

  void _drawRoundConnections(
    Canvas canvas,
    int roundIndex,
    List<T> currentRound,
    List<T> nextRound,
    Paint defaultPaint,
    Paint activePaint,
    Paint activeGlowPaint,
  ) {
    final cardX = roundIndex * (cardWidth + horizontalGap);
    final nextCardX = (roundIndex + 1) * (cardWidth + horizontalGap);

    final startX = cardX + cardWidth;
    final endX = nextCardX;
    final midX = startX + horizontalGap / 2;

    for (int j = 0; j < nextRound.length; j++) {
      if (j * 2 >= currentRound.length || j * 2 + 1 >= currentRound.length) {
        continue;
      }
      final childMatch = nextRound[j];
      final parentMatch1 = currentRound[j * 2];
      final parentMatch2 = currentRound[j * 2 + 1];

      final yTop = getActiveY(roundIndex, j * 2);
      final yBottom = getActiveY(roundIndex, j * 2 + 1);
      final yChild = getActiveY(roundIndex + 1, j);

      bool isTopActive = false;
      bool isBottomActive = false;
      bool isTopSearchHighlight = false;
      bool isBottomSearchHighlight = false;

      if (hasWinner != null &&
          getWinnerName != null &&
          getPlayer1Name != null &&
          getPlayer2Name != null) {
        final winner1 = getWinnerName!(parentMatch1);
        final winner2 = getWinnerName!(parentMatch2);

        final childP1 = getPlayer1Name!(childMatch);
        final childP2 = getPlayer2Name!(childMatch);

        isTopActive =
            hasWinner!(parentMatch1) &&
            winner1.isNotEmpty &&
            (childP1 == winner1 || childP2 == winner1);

        isBottomActive =
            hasWinner!(parentMatch2) &&
            winner2.isNotEmpty &&
            (childP1 == winner2 || childP2 == winner2);

        if (searchHighlightQuery != null && searchHighlightQuery!.isNotEmpty) {
          final winner1Lower = winner1.toLowerCase();
          final winner2Lower = winner2.toLowerCase();
          final q = searchHighlightQuery!.toLowerCase();
          isTopSearchHighlight =
              isTopActive &&
              winner1Lower.isNotEmpty &&
              winner1Lower.contains(q);
          isBottomSearchHighlight =
              isBottomActive &&
              winner2Lower.isNotEmpty &&
              winner2Lower.contains(q);
        }
      }

      final Path topPath = Path()..moveTo(startX, yTop);
      final Path bottomPath = Path()..moveTo(startX, yBottom);

      if (connectorStyle == ConnectorStyle.straight) {
        topPath.lineTo(endX, yChild);
        bottomPath.lineTo(endX, yChild);
      } else {
        final double r = connectorStyle == ConnectorStyle.sharp
            ? 0.0
            : connectorRadius;
        final double maxVLimitTop = (yChild - yTop).abs() / 2;
        final double maxVLimitBottom = (yChild - yBottom).abs() / 2;
        final double maxVLimit = maxVLimitTop < maxVLimitBottom
            ? maxVLimitTop
            : maxVLimitBottom;
        final double maxHLimit = horizontalGap / 2;
        final double clampedR = r.clamp(
          0.0,
          maxVLimit < maxHLimit ? maxVLimit : maxHLimit,
        );

        final double dyTop = yChild - yTop;
        final double signTop = dyTop == 0 ? 1.0 : dyTop.sign;
        if (dyTop.abs() < 0.01) {
          topPath.lineTo(midX + clampedR, yTop);
        } else {
          topPath.lineTo(midX - clampedR, yTop);
          topPath.quadraticBezierTo(
            midX,
            yTop,
            midX,
            yTop + clampedR * signTop,
          );
          topPath.lineTo(midX, yChild - clampedR * signTop);
          topPath.quadraticBezierTo(midX, yChild, midX + clampedR, yChild);
        }

        final double dyBottom = yChild - yBottom;
        final double signBottom = dyBottom == 0 ? 1.0 : dyBottom.sign;
        if (dyBottom.abs() < 0.01) {
          bottomPath.lineTo(midX + clampedR, yBottom);
        } else {
          bottomPath.lineTo(midX - clampedR, yBottom);
          bottomPath.quadraticBezierTo(
            midX,
            yBottom,
            midX,
            yBottom + clampedR * signBottom,
          );
          bottomPath.lineTo(midX, yChild - clampedR * signBottom);
          bottomPath.quadraticBezierTo(midX, yChild, midX + clampedR, yChild);
        }
      }

      Paint topActivePaint = activePaint;
      Paint topActiveGlowPaint = activeGlowPaint;

      if (isTopSearchHighlight) {
        topActivePaint = Paint()
          ..color = accentColor
          ..strokeWidth = activeLineThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        topActiveGlowPaint = Paint()
          ..color = accentColor.withValues(
            alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
          )
          ..strokeWidth = activeGlowWidth * (0.8 + 0.4 * pulseValue)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
      }

      if (isTopActive) {
        if (useLineGradients) {
          topActivePaint.shader = ui.Gradient.linear(
            Offset(startX, yTop),
            Offset(endX, yChild),
            [primaryColor, isTopSearchHighlight ? accentColor : secondaryColor],
          );
          topActiveGlowPaint.shader = ui.Gradient.linear(
            Offset(startX, yTop),
            Offset(endX, yChild),
            [
              primaryColor.withValues(
                alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
              ),
              (isTopSearchHighlight ? accentColor : secondaryColor).withValues(
                alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
              ),
            ],
          );
        } else {
          topActivePaint.shader = null;
          topActiveGlowPaint.shader = null;
        }
        _drawPath(canvas, topPath, topActiveGlowPaint);
        _drawPath(canvas, topPath, topActivePaint);
      } else {
        _drawPath(canvas, topPath, defaultPaint);
      }

      Paint bottomActivePaint = activePaint;
      Paint bottomActiveGlowPaint = activeGlowPaint;

      if (isBottomSearchHighlight) {
        bottomActivePaint = Paint()
          ..color = accentColor
          ..strokeWidth = activeLineThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        bottomActiveGlowPaint = Paint()
          ..color = accentColor.withValues(
            alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
          )
          ..strokeWidth = activeGlowWidth * (0.8 + 0.4 * pulseValue)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
      }

      if (isBottomActive) {
        if (useLineGradients) {
          bottomActivePaint.shader = ui.Gradient.linear(
            Offset(startX, yBottom),
            Offset(endX, yChild),
            [
              primaryColor,
              isBottomSearchHighlight ? accentColor : secondaryColor,
            ],
          );
          bottomActiveGlowPaint.shader = ui.Gradient.linear(
            Offset(startX, yBottom),
            Offset(endX, yChild),
            [
              primaryColor.withValues(
                alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
              ),
              (isBottomSearchHighlight ? accentColor : secondaryColor)
                  .withValues(
                    alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
                  ),
            ],
          );
        } else {
          bottomActivePaint.shader = null;
          bottomActiveGlowPaint.shader = null;
        }
        _drawPath(canvas, bottomPath, bottomActiveGlowPaint);
        _drawPath(canvas, bottomPath, bottomActivePaint);
      } else {
        _drawPath(canvas, bottomPath, defaultPaint);
      }

      if (connectorStyle != ConnectorStyle.straight) {
        final double r = connectorStyle == ConnectorStyle.sharp
            ? 0.0
            : connectorRadius;
        final double maxVLimitTop = (yChild - yTop).abs() / 2;
        final double maxVLimitBottom = (yChild - yBottom).abs() / 2;
        final double maxVLimit = maxVLimitTop < maxVLimitBottom
            ? maxVLimitTop
            : maxVLimitBottom;
        final double maxHLimit = horizontalGap / 2;
        final double clampedR = r.clamp(
          0.0,
          maxVLimit < maxHLimit ? maxVLimit : maxHLimit,
        );

        final Path sharedPath = Path()
          ..moveTo(midX + clampedR, yChild)
          ..lineTo(endX, yChild);

        final bool isChildActive = isTopActive || isBottomActive;
        final bool isSharedHighlight =
            isTopSearchHighlight || isBottomSearchHighlight;

        if (isChildActive) {
          Paint sharedActivePaint = activePaint;
          Paint sharedActiveGlowPaint = activeGlowPaint;

          if (isSharedHighlight) {
            sharedActivePaint = Paint()
              ..color = accentColor
              ..strokeWidth = activeLineThickness
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;
            sharedActiveGlowPaint = Paint()
              ..color = accentColor.withValues(
                alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
              )
              ..strokeWidth = activeGlowWidth * (0.8 + 0.4 * pulseValue)
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;
          }

          if (useLineGradients) {
            sharedActivePaint.shader = ui.Gradient.linear(
              Offset(startX, yChild),
              Offset(endX, yChild),
              [primaryColor, isSharedHighlight ? accentColor : secondaryColor],
            );
            sharedActiveGlowPaint.shader = ui.Gradient.linear(
              Offset(startX, yChild),
              Offset(endX, yChild),
              [
                primaryColor.withValues(
                  alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
                ),
                (isSharedHighlight ? accentColor : secondaryColor).withValues(
                  alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
                ),
              ],
            );
          } else {
            sharedActivePaint.shader = null;
            sharedActiveGlowPaint.shader = null;
          }
          _drawPath(canvas, sharedPath, sharedActiveGlowPaint);
          _drawPath(canvas, sharedPath, sharedActivePaint);
        } else {
          _drawPath(canvas, sharedPath, defaultPaint);
        }
      }
    }
  }

  void _drawFinalConnection(
    Canvas canvas,
    int roundIndex,
    List<T> currentRound,
    T grandFinal,
    Paint defaultPaint,
    Paint activePaint,
    Paint activeGlowPaint,
  ) {
    final cardX = roundIndex * (cardWidth + horizontalGap);
    final nextCardX = (roundIndex + 1) * (cardWidth + horizontalGap);

    final startX = cardX + cardWidth;
    final endX = nextCardX;

    final ySemi = getActiveY(roundIndex, 0);
    final yFinal = getActiveY(roundIndex + 1, 0);

    final semiMatch = currentRound[0];
    bool isSemiWinnerActive = false;
    bool isSemiWinnerHighlight = false;

    if (hasWinner != null &&
        getWinnerName != null &&
        getPlayer1Name != null &&
        getPlayer2Name != null) {
      final semiWinner = getWinnerName!(semiMatch);
      final finalP1 = getPlayer1Name!(grandFinal);
      final finalP2 = getPlayer2Name!(grandFinal);

      isSemiWinnerActive =
          hasWinner!(semiMatch) &&
          semiWinner.isNotEmpty &&
          (finalP1 == semiWinner || finalP2 == semiWinner);

      if (searchHighlightQuery != null && searchHighlightQuery!.isNotEmpty) {
        final semiWinnerLower = semiWinner.toLowerCase();
        final q = searchHighlightQuery!.toLowerCase();
        isSemiWinnerHighlight =
            isSemiWinnerActive &&
            semiWinnerLower.isNotEmpty &&
            semiWinnerLower.contains(q);
      }
    }

    final Path finalPath = Path()
      ..moveTo(startX, ySemi)
      ..lineTo(endX, yFinal);

    if (isSemiWinnerActive) {
      Paint finalActivePaint = activePaint;
      Paint finalActiveGlowPaint = activeGlowPaint;

      if (isSemiWinnerHighlight) {
        finalActivePaint = Paint()
          ..color = accentColor
          ..strokeWidth = activeLineThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        finalActiveGlowPaint = Paint()
          ..color = accentColor.withValues(
            alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
          )
          ..strokeWidth = activeGlowWidth * (0.8 + 0.4 * pulseValue)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
      }

      if (useLineGradients) {
        finalActivePaint.shader = ui.Gradient.linear(
          Offset(startX, ySemi),
          Offset(endX, yFinal),
          [primaryColor, isSemiWinnerHighlight ? accentColor : secondaryColor],
        );
        finalActiveGlowPaint.shader =
            ui.Gradient.linear(Offset(startX, ySemi), Offset(endX, yFinal), [
              primaryColor.withValues(
                alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
              ),
              (isSemiWinnerHighlight ? accentColor : secondaryColor).withValues(
                alpha: activeGlowOpacity * (0.6 + 0.4 * pulseValue),
              ),
            ]);
      } else {
        finalActivePaint.shader = null;
        finalActiveGlowPaint.shader = null;
      }
      _drawPath(canvas, finalPath, finalActiveGlowPaint);
      _drawPath(canvas, finalPath, finalActivePaint);
    } else {
      _drawPath(canvas, finalPath, defaultPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BracketPainter<T> oldDelegate) {
    return oldDelegate.cardWidth != cardWidth ||
        oldDelegate.cardHeight != cardHeight ||
        oldDelegate.horizontalGap != horizontalGap ||
        oldDelegate.verticalGap != verticalGap ||
        oldDelegate.topOffset != topOffset ||
        oldDelegate.pageOffset != pageOffset ||
        oldDelegate.branchRounds != branchRounds ||
        oldDelegate.finalMatch != finalMatch ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.defaultLineColor != defaultLineColor ||
        oldDelegate.connectorRadius != connectorRadius ||
        oldDelegate.lineThickness != lineThickness ||
        oldDelegate.activeLineThickness != activeLineThickness ||
        oldDelegate.activeGlowWidth != activeGlowWidth ||
        oldDelegate.activeGlowOpacity != activeGlowOpacity ||
        oldDelegate.connectorStyle != connectorStyle ||
        oldDelegate.lineType != lineType ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.dashSpeedMultiplier != dashSpeedMultiplier ||
        oldDelegate.searchHighlightQuery != searchHighlightQuery ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.flowValue != flowValue ||
        oldDelegate.useLineGradients != useLineGradients;
  }
}

/// A premium, highly customizable generic tournament bracket widget supporting any match model T.
class AnimatedTournamentBracket<T> extends StatefulWidget {
  /// Rounds list for the first branch (Upper).
  final List<List<T>> branch1Rounds;

  /// The final championship match that connects the branch winners.
  final T? grandFinal;

  /// Custom Card layout builder. EXTREMELY powerful for complete custom interfaces.
  final Widget Function(BuildContext context, T match) itemBuilder;

  /// Optional custom round titles.
  final List<String>? roundTitles;

  /// Custom Tab item builder. Allows developers to fully customize the round tab labels!
  final Widget Function(BuildContext context, int index, bool isSelected)?
  tabBuilder;

  /// A builder callback to fully override and customize the entire Round Tab Bar.
  /// Receives:
  /// - [pageOffset]: the exact fractional swipe progress (0.0 to N-1).
  /// - [activeRound]: the current centered round index.
  /// - [onTabTap]: call this function to animate the bracket to a specific round index.
  final Widget Function(
    BuildContext context,
    double pageOffset,
    int activeRound,
    void Function(int index) onTabTap,
  )?
  tabBarBuilder;

  /// Optional connection line highlighting callbacks.
  final bool Function(T match)? hasWinner;
  final String Function(T match)? getWinnerName;
  final String Function(T match)? getPlayer1Name;
  final String Function(T match)? getPlayer2Name;

  /// Design system theme colors
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color defaultLineColor;

  /// The radius for connection line corners. Defaults to 8.0 (subtle).
  final double connectorRadius;

  /// Optional custom layout parameters.
  final double? cardWidth;
  final double? cardHeight;
  final double? horizontalGap;
  final double verticalGap;
  final double topOffset;

  /// Custom connection line styling properties.
  final double lineThickness;
  final double activeLineThickness;
  final double activeGlowWidth;
  final double activeGlowOpacity;
  final ConnectorStyle connectorStyle;

  /// Style of connection lines (solid, flowing dashed pattern).
  final ConnectorLineType lineType;

  /// Length of active dashes in flowing lines. Defaults to 12.0.
  final double dashLength;

  /// Gap between active dashes in flowing lines. Defaults to 8.0.
  final double dashGap;

  /// Speed multiplier for the flowing animation. Defaults to 1.0.
  final double dashSpeedMultiplier;

  /// Player or competitor name to trace and highlight gold.
  final String? searchHighlightQuery;

  /// Whether to pulse/glow the active connection paths.
  final bool pulseGlow;

  /// Duration/speed of the pulsing glow animation.
  final Duration pulseDuration;

  /// Whether to draw gradient connection lines from source to destination matches.
  final bool useLineGradients;

  /// Optional builder to draw headers directly above each round column in the canvas.
  final Widget Function(BuildContext context, int roundIndex)?
  roundHeaderBuilder;

  /// Custom Tab Bar styling properties.
  final Color? tabBarBorderColor;
  final Color? tabBarBackgroundColor;
  final double tabBarBorderRadius;
  final Decoration? tabBarIndicatorDecoration;
  final double tabBarHeight;

  const AnimatedTournamentBracket({
    super.key,
    required this.branch1Rounds,
    this.grandFinal,
    required this.itemBuilder,
    this.roundTitles,
    this.tabBuilder,
    this.tabBarBuilder,
    this.hasWinner,
    this.getWinnerName,
    this.getPlayer1Name,
    this.getPlayer2Name,
    this.primaryColor = const Color(0xFF0066FF),
    this.secondaryColor = const Color(0xFF00E5FF),
    this.backgroundColor = const Color(0xFF070B19),
    this.surfaceColor = const Color(0xFF131A30),
    this.accentColor = const Color(0xFFFFB300),
    this.defaultLineColor = const Color(0x33FFFFFF),
    this.connectorRadius = 8.0,
    this.cardWidth,
    this.cardHeight,
    this.horizontalGap,
    this.verticalGap = 16.0,
    this.topOffset = 25.0,
    this.lineThickness = 2.0,
    this.activeLineThickness = 3.0,
    this.activeGlowWidth = 8.0,
    this.activeGlowOpacity = 0.15,
    this.connectorStyle = ConnectorStyle.curved,
    this.lineType = ConnectorLineType.solid,
    this.dashLength = 12.0,
    this.dashGap = 8.0,
    this.dashSpeedMultiplier = 1.0,
    this.searchHighlightQuery,
    this.pulseGlow = true,
    this.pulseDuration = const Duration(seconds: 2),
    this.useLineGradients = true,
    this.roundHeaderBuilder,
    this.tabBarBorderColor,
    this.tabBarBackgroundColor,
    this.tabBarBorderRadius = 12.0,
    this.tabBarIndicatorDecoration,
    this.tabBarHeight = 42.0,
  });

  @override
  State<AnimatedTournamentBracket<T>> createState() =>
      _AnimatedTournamentBracketState<T>();
}

class _AnimatedTournamentBracketState<T>
    extends State<AnimatedTournamentBracket<T>>
    with TickerProviderStateMixin {
  late final AnimationController _snapAnimationController;
  late final CurvedAnimation _snapAnimation;
  late final AnimationController _pulseController;
  double _pageOffset = 0.0;
  int _activeRound = 0;
  double _snapStartOffset = 0.0;
  double _snapTargetOffset = 0.0;

  int get numRounds =>
      widget.branch1Rounds.length + (widget.grandFinal != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _snapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapAnimation = CurvedAnimation(
      parent: _snapAnimationController,
      curve: Curves.easeOutCubic,
    );
    _snapAnimation.addListener(() {
      setState(() {
        _pageOffset = ui.lerpDouble(
          _snapStartOffset,
          _snapTargetOffset,
          _snapAnimation.value,
        )!;
        _activeRound = _pageOffset.round();
      });
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );
    if (widget.pulseGlow) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTournamentBracket<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseDuration != oldWidget.pulseDuration) {
      _pulseController.duration = widget.pulseDuration;
    }
    if (widget.pulseGlow != oldWidget.pulseGlow) {
      if (widget.pulseGlow) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _snapAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double getActiveY(
    int round,
    int index,
    double pageOffset,
    double cardHeight,
    double verticalGap,
    double topOffset,
  ) {
    if (widget.grandFinal != null && round == numRounds - 1) {
      return getActiveY(
        round - 1,
        0,
        pageOffset,
        cardHeight,
        verticalGap,
        topOffset,
      );
    }
    if (round == 0) {
      return topOffset + index * (cardHeight + verticalGap) + cardHeight / 2;
    }

    final parent1Y = getActiveY(
      round - 1,
      index * 2,
      pageOffset,
      cardHeight,
      verticalGap,
      topOffset,
    );
    final parent2Y = getActiveY(
      round - 1,
      index * 2 + 1,
      pageOffset,
      cardHeight,
      verticalGap,
      topOffset,
    );
    final expandedY = (parent1Y + parent2Y) / 2;
    final compactY =
        topOffset + index * (cardHeight + verticalGap) + cardHeight / 2;

    final t = (pageOffset - (round - 1)).clamp(0.0, 1.0);
    return ui.lerpDouble(expandedY, compactY, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final branchRounds = widget.branch1Rounds;
    final finalMatch = widget.grandFinal;

    return Stack(
      children: [
        // Background Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.5),
                radius: 1.2,
                colors: [
                  widget.backgroundColor.withValues(alpha: 0.85),
                  widget.backgroundColor,
                ],
              ),
            ),
          ),
        ),

        // Main bracket screen contents
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              widget.tabBarBuilder != null
                  ? widget.tabBarBuilder!(context, _pageOffset, _activeRound, (
                      index,
                    ) {
                      _snapStartOffset = _pageOffset;
                      _snapTargetOffset = index.toDouble();
                      _snapAnimationController.forward(from: 0.0);
                    })
                  : _buildRoundTabs(),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth =
                        widget.cardWidth ?? (constraints.maxWidth * 0.89);
                    final double cardHeight =
                        widget.cardHeight ?? (cardWidth / 2.5);
                    final double horizontalGap =
                        widget.horizontalGap ?? (constraints.maxWidth * 0.12);
                    final double verticalGap = widget.verticalGap;
                    final double topOffset =
                        widget.topOffset +
                        (widget.roundHeaderBuilder != null ? 40.0 : 0.0);

                    final double colWidth = cardWidth + horizontalGap;
                    final double canvasWidth = colWidth * numRounds + 40;

                    final heights = List.generate(numRounds, (colIndex) {
                      final int itemCount =
                          (widget.grandFinal != null &&
                              colIndex == numRounds - 1)
                          ? 1
                          : branchRounds[colIndex].length;
                      return itemCount * cardHeight +
                          (itemCount - 1).clamp(0, itemCount) * verticalGap +
                          topOffset +
                          80;
                    });

                    double getActiveContentHeight(double pageOffset) {
                      if (numRounds <= 1) {
                        return heights.isNotEmpty ? heights[0] : 0.0;
                      }
                      int i = pageOffset.floor().clamp(0, numRounds - 2);
                      double t = pageOffset - i;
                      return ui.lerpDouble(heights[i], heights[i + 1], t)!;
                    }

                    final double canvasHeight = getActiveContentHeight(
                      _pageOffset,
                    );

                    final double screenPadding =
                        (constraints.maxWidth - cardWidth) / 2;
                    final double horizontalOffset =
                        screenPadding - _pageOffset * colWidth;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (details) {
                        _snapAnimationController.stop();
                        _snapStartOffset = _pageOffset;
                      },
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _pageOffset =
                              (_pageOffset - details.primaryDelta! / colWidth)
                                  .clamp(0.0, (numRounds - 1).toDouble());
                          _activeRound = _pageOffset.round();
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        final double velocity = details.primaryVelocity ?? 0.0;
                        int targetPage = _pageOffset.round();

                        if (velocity < -400) {
                          targetPage = (_pageOffset.floor() + 1).clamp(
                            0,
                            numRounds - 1,
                          );
                        } else if (velocity > 400) {
                          targetPage = (_pageOffset.ceil() - 1).clamp(
                            0,
                            numRounds - 1,
                          );
                        }

                        _snapStartOffset = _pageOffset;
                        _snapTargetOffset = targetPage.toDouble();
                        _snapAnimationController.forward(from: 0.0);
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          height: canvasHeight,
                          child: _buildAnimatedBracketCanvas(
                            branchRounds: branchRounds,
                            finalMatch: finalMatch,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            horizontalGap: horizontalGap,
                            verticalGap: verticalGap,
                            topOffset: topOffset,
                            colWidth: colWidth,
                            canvasWidth: canvasWidth,
                            canvasHeight: canvasHeight,
                            horizontalOffset: horizontalOffset,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoundTabs() {
    final List<String> titles =
        widget.roundTitles ??
        List.generate(numRounds, (colIndex) {
          if (colIndex == numRounds - 1) return 'Final';
          if (colIndex == numRounds - 2) return 'Semi final';
          if (colIndex == numRounds - 3) return 'Quarter final';
          return 'Round ${colIndex + 1}';
        });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: widget.tabBarHeight,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              widget.tabBarBackgroundColor ??
              widget.surfaceColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(widget.tabBarBorderRadius),
          border: Border.all(
            color:
                widget.tabBarBorderColor ??
                Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth) / numRounds;
            return Stack(
              children: [
                // Sliding indicator
                Positioned(
                  left: _pageOffset * tabWidth,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration:
                        widget.tabBarIndicatorDecoration ??
                        BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.primaryColor,
                              widget.secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            (widget.tabBarBorderRadius - 4).clamp(
                              0.0,
                              double.infinity,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                  ),
                ),

                // Labels
                Row(
                  children: List.generate(numRounds, (index) {
                    final bool isCurrent = _activeRound == index;
                    return SizedBox(
                      width: tabWidth,
                      child: GestureDetector(
                        onTap: () {
                          _snapStartOffset = _pageOffset;
                          _snapTargetOffset = index.toDouble();
                          _snapAnimationController.forward(from: 0.0);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: widget.tabBuilder != null
                              ? widget.tabBuilder!(context, index, isCurrent)
                              : Text(
                                  titles[index]
                                      .replaceAll(' sixteen', ' 16')
                                      .replaceAll(' final', ''),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.white
                                        : Colors.white60,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedBracketCanvas({
    required List<List<T>> branchRounds,
    required T? finalMatch,
    required double cardWidth,
    required double cardHeight,
    required double horizontalGap,
    required double verticalGap,
    required double topOffset,
    required double colWidth,
    required double canvasWidth,
    required double canvasHeight,
    required double horizontalOffset,
  }) {
    return SizedBox.expand(
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: horizontalOffset,
              top: 0,
              bottom: 0,
              width: canvasWidth,
              child: Stack(
                children: [
                  // Vector Painted Lines
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: BracketPainter<T>(
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            horizontalGap: horizontalGap,
                            verticalGap: verticalGap,
                            topOffset: topOffset,
                            branchRounds: branchRounds,
                            finalMatch: finalMatch,
                            pageOffset: _pageOffset,
                            primaryColor: widget.primaryColor,
                            secondaryColor: widget.secondaryColor,
                            accentColor: widget.accentColor,
                            defaultLineColor: widget.defaultLineColor,
                            connectorRadius: widget.connectorRadius,
                            lineThickness: widget.lineThickness,
                            activeLineThickness: widget.activeLineThickness,
                            activeGlowWidth: widget.activeGlowWidth,
                            activeGlowOpacity: widget.activeGlowOpacity,
                            connectorStyle: widget.connectorStyle,
                            lineType: widget.lineType,
                            dashLength: widget.dashLength,
                            dashGap: widget.dashGap,
                            dashSpeedMultiplier: widget.dashSpeedMultiplier,
                            searchHighlightQuery: widget.searchHighlightQuery,
                            pulseValue: widget.pulseGlow
                                ? _pulseController.value
                                : 0.0,
                            flowValue: widget.pulseGlow
                                ? (_pulseController.status ==
                                          AnimationStatus.reverse
                                      ? 2.0 - _pulseController.value
                                      : _pulseController.value)
                                : 0.0,
                            useLineGradients: widget.useLineGradients,
                            hasWinner: widget.hasWinner,
                            getWinnerName: widget.getWinnerName,
                            getPlayer1Name: widget.getPlayer1Name,
                            getPlayer2Name: widget.getPlayer2Name,
                          ),
                        );
                      },
                    ),
                  ),

                  // Round Column Headers
                  if (widget.roundHeaderBuilder != null)
                    ...List.generate(numRounds, (roundIndex) {
                      return Positioned(
                        left: roundIndex * colWidth,
                        top: topOffset - 35,
                        width: cardWidth,
                        height: 30,
                        child: widget.roundHeaderBuilder!(context, roundIndex),
                      );
                    }),
                  // Dynamic Cards for all rounds except the Grand Final
                  ...List.generate(branchRounds.length, (roundIndex) {
                    final roundMatches = branchRounds[roundIndex];
                    return List.generate(roundMatches.length, (matchIndex) {
                      final match = roundMatches[matchIndex];
                      final double y = getActiveY(
                        roundIndex,
                        matchIndex,
                        _pageOffset,
                        cardHeight,
                        verticalGap,
                        topOffset,
                      );
                      return Positioned(
                        left: roundIndex * colWidth,
                        top: y - cardHeight / 2,
                        width: cardWidth,
                        height: cardHeight,
                        child: widget.itemBuilder(context, match),
                      );
                    });
                  }).expand((widgets) => widgets),

                  // Final Card
                  if (finalMatch != null)
                    Positioned(
                      left: (numRounds - 1) * colWidth,
                      top:
                          getActiveY(
                            numRounds - 1,
                            0,
                            _pageOffset,
                            cardHeight,
                            verticalGap,
                            topOffset,
                          ) -
                          cardHeight / 2,
                      width: cardWidth,
                      height: cardHeight,
                      child: widget.itemBuilder(context, finalMatch),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
