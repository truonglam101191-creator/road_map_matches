import 'animated_tournament_bracket.dart';

/// Helper utility for organizing tournament brackets, seeding, and drawing.
class TournamentDrawEngine {
  /// Generates the standard tournament bracket seeding position order for a given power-of-2 size.
  ///
  /// For example:
  /// - size = 2: [1, 2]
  /// - size = 4: [1, 4, 3, 2]
  /// - size = 8: [1, 8, 5, 4, 3, 6, 7, 2]
  /// - size = 16: [1, 16, 9, 8, 5, 12, 13, 4, 3, 14, 11, 6, 7, 10, 15, 2]
  static List<int> generateSeedingOrder(int size) {
    if (size <= 0) return [];
    // Ensure size is a power of 2
    int p = 1;
    while (p < size) {
      p *= 2;
    }

    List<int> order = [1];
    while (order.length < p) {
      final nextLength = order.length * 2;
      final nextOrder = List<int>.filled(nextLength, 0);
      final sum = nextLength + 1;

      for (int i = 0; i < order.length; i++) {
        final x = order[i];
        if (i % 2 == 0) {
          nextOrder[i * 2] = x;
          nextOrder[i * 2 + 1] = sum - x;
        } else {
          nextOrder[i * 2] = sum - x;
          nextOrder[i * 2 + 1] = x;
        }
      }
      order = nextOrder;
    }
    return order;
  }

  /// Calculates the number of BYE (miễn đấu) slots required for N players.
  static int calculateByes(int N) {
    if (N <= 1) return 0;
    final int nextPowerOfTwoVal = nextPowerOfTwo(N);
    return nextPowerOfTwoVal - N;
  }

  /// Finds the next power of 2 greater than or equal to N.
  static int nextPowerOfTwo(int N) {
    if (N <= 1) return 1;
    int p = 1;
    while (p < N) {
      p *= 2;
    }
    return p;
  }

  /// Automatically generates the complete tournament round tree (List of Match Lists)
  /// starting from a raw list of players/competitors.
  ///
  /// - [players]: List of participants. Can be of type [Player] or custom types.
  /// - [seeds]: Optional list of seeded player names or objects in order of priority (Seed 1, Seed 2...).
  ///   Seeded players are placed in ideal bracket positions so they do not meet early.
  /// - [matchLabelPrefix]: Prefix for match labels (e.g. "Trận" or "Match").
  static List<List<MatchModel<P>>> buildInitialBracket<P>({
    required List<P> players,
    List<P>? seeds,
    String matchLabelPrefix = 'M',
    String Function(P)? getPlayerName,
    bool includeFinal = true,
  }) {
    final nameGetter =
        getPlayerName ??
        (p) {
          if (p is Player) return p.name;
          try {
            return (p as dynamic).name.toString();
          } catch (_) {
            return p.toString();
          }
        };

    final int totalCount = players.length;
    if (totalCount == 0) return [];

    final int bracketSize = nextPowerOfTwo(totalCount);
    final int numByes = bracketSize - totalCount;

    // Create a copy of seeds and normal players
    final List<P> seededList = seeds != null ? List<P>.from(seeds) : [];
    final List<P> unseededList = List<P>.from(players);
    for (final seed in seededList) {
      unseededList.removeWhere((p) => nameGetter(p) == nameGetter(seed));
    }

    // Generate bracket position map using seeding order
    // seedingOrder contains values like [1, 8, 5, 4, 3, 6, 7, 2]
    final List<int> seedingOrder = generateSeedingOrder(bracketSize);

    // Prepare list of size bracketSize
    // We place seeded players at their corresponding seed positions first.
    // The rest of the spots are filled with unseeded players, and the remaining spots are BYEs.
    // BYEs are paired with the highest seeds. So the spots that correspond to lowest seeds (which pair with highest seeds) are filled with BYE.
    final List<P?> bracketSlots = List<P?>.filled(bracketSize, null);

    // Let's identify which seed rank gets a BYE.
    // If there are B BYEs, they should be paired with the highest seeds.
    // For a seed S, its opponent in Round 1 is at seed rank (bracketSize + 1 - S).
    // So the B lowest seed ranks (from bracketSize - B + 1 to bracketSize) should be BYEs.
    final Set<int> byeSeedRanks = {};
    for (int i = 0; i < numByes; i++) {
      byeSeedRanks.add(bracketSize - i);
    }

    // Now distribute players into the slots
    int unseededIndex = 0;
    for (int i = 0; i < bracketSize; i++) {
      final int seedRank = seedingOrder[i];
      if (byeSeedRanks.contains(seedRank)) {
        // This slot is a BYE
        bracketSlots[i] = null;
      } else {
        // Place seeded player if available
        if (seedRank - 1 < seededList.length) {
          bracketSlots[i] = seededList[seedRank - 1];
        } else {
          // Place unseeded player
          if (unseededIndex < unseededList.length) {
            bracketSlots[i] = unseededList[unseededIndex++];
          } else {
            bracketSlots[i] = null;
          }
        }
      }
    }

    // Generate Round 1 Matches
    final List<MatchModel<P>> round1Matches = [];
    int matchId = 1;

    for (int i = 0; i < bracketSize; i += 2) {
      final comp1 = bracketSlots[i];
      final comp2 = bracketSlots[i + 1];

      final competitors = <P>[];
      final scores = <int>[];
      MatchStatus status = MatchStatus.scheduled;

      if (comp1 != null) competitors.add(comp1);
      if (comp2 != null) competitors.add(comp2);

      // Walkover logic if one competitor is BYE
      if (comp1 != null && comp2 == null) {
        scores.addAll([1, 0]); // 1-0 for comp1
        status = MatchStatus.completed;
      } else if (comp1 == null && comp2 != null) {
        scores.addAll([0, 1]); // 0-1 for comp2
        status = MatchStatus.completed;
      } else {
        scores.addAll([0, 0]);
      }

      round1Matches.add(
        MatchModel<P>(
          id: matchId++,
          label: '$matchLabelPrefix$matchId',
          table: 'Tàn ${((matchId - 1) / 2).ceil()}',
          time: 'TBD',
          competitors: competitors,
          scores: scores,
          status: status,
        ),
      );
    }

    final List<List<MatchModel<P>>> rounds = [round1Matches];

    // Generate subsequent rounds with placeholder matches
    int currentRoundMatchCount = round1Matches.length;
    final int limit = includeFinal ? 1 : 2;
    while (currentRoundMatchCount > limit) {
      currentRoundMatchCount ~/= 2;
      final List<MatchModel<P>> nextRoundMatches = [];
      for (int i = 0; i < currentRoundMatchCount; i++) {
        nextRoundMatches.add(
          MatchModel<P>(
            id: matchId++,
            label: '$matchLabelPrefix$matchId',
            table: 'TBD',
            time: 'TBD',
            competitors: const [],
            scores: const [0, 0],
            status: MatchStatus.scheduled,
          ),
        );
      }
      rounds.add(nextRoundMatches);
    }

    return rounds;
  }
}
