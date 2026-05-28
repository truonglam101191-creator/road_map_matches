import 'package:road_map/animated_tournament_bracket.dart';

class Team {
  final String name;
  final String logo;
  final bool isWalkOver;
  final bool isCheckedIn;

  const Team({
    required this.name,
    required this.logo,
    this.isWalkOver = false,
    this.isCheckedIn = false,
  });

  static const walkOver = Team(
    name: 'Walk Over Team',
    logo: '👥',
    isWalkOver: true,
  );
}

class BracketData {
  // Tab 1: Upper Bracket Matches
  static const List<MatchModel> round1Tab1 = [
    MatchModel(
      id: 1,
      label: 'Match 1',
      table: 'Table 1',
      time: 'Sun 10:20 PM',
      competitors: [Player(name: 'David Alcaide Bermudez', flag: '🇪🇸')],
      scores: [0],
      status: MatchStatus.completed,
    ),
    MatchModel(
      id: 2,
      label: 'Match 2',
      table: 'Table 1',
      time: 'Sat 10:18 PM',
      competitors: [Player(name: 'Billy Thorpe', flag: '🇺🇸', isCheckedIn: true), Player(name: 'Skyler Woodward', flag: '🇺🇸', isCheckedIn: true)],
      scores: [1, 7],
      status: MatchStatus.inProgress,
    ),
    MatchModel(
      id: 3,
      label: 'Match 3',
      table: 'Table 1',
      time: 'Sat 06:43 PM',
      competitors: [Player(name: 'Kelly Fisher', flag: '🇬🇧'), Player(name: 'Justin Sajich', flag: '🇦🇺')],
      scores: [3, 7],
      status: MatchStatus.dispute,
    ),
    MatchModel(
      id: 4,
      label: 'Match 4',
      table: 'Table 1',
      time: 'Sun 08:42 PM',
      competitors: [Player(name: 'Alex Kazakis', flag: '🇬🇷')],
      scores: [0],
      status: MatchStatus.completed,
    ),
    MatchModel(
      id: 5,
      label: 'Match 5',
      table: 'Table 1',
      time: 'Sun 08:42 PM',
      competitors: [Player(name: 'Naoyuki Oi', flag: '🇯🇵')],
      scores: [0],
      status: MatchStatus.completed,
    ),
    MatchModel(
      id: 6,
      label: 'Match 6',
      table: 'Table 1',
      time: 'Sat 07:59 PM',
      competitors: [Player(name: 'Eklent Kaçi', flag: '🇦🇱'), Player(name: 'Petri Makkonen', flag: '🇫🇮')],
      scores: [7, 3],
    ),
    MatchModel(
      id: 7,
      label: 'Match 7',
      table: 'Table 1',
      time: 'Sun 12:11 PM',
      competitors: [Player(name: 'Niels Feijen', flag: '🇳🇱'), Player(name: 'Jeffrey De Luna', flag: '🇵🇭')],
      scores: [7, 3],
    ),
    MatchModel(
      id: 8,
      label: 'Match 8',
      table: 'Table 1',
      time: 'Sun 12:11 PM',
      competitors: [Player(name: 'Jayson Shaw', flag: '🇬🇧')],
      scores: [0],
    ),
  ];

  static const List<MatchModel> round2Tab1 = [
    MatchModel(
      id: 17,
      label: 'Match 17',
      table: 'Table 1',
      time: 'Sun 10:20 PM',
      competitors: [Player(name: 'David Alcaide Bermudez', flag: '🇪🇸'), Player(name: 'Skyler Woodward', flag: '🇺🇸')],
      scores: [3, 7],
    ),
    MatchModel(
      id: 18,
      label: 'Match 18',
      table: 'Table 1',
      time: 'Mon 06:35 PM',
      competitors: [Player(name: 'Justin Sajich', flag: '🇦🇺'), Player(name: 'Alex Kazakis', flag: '🇬🇷')],
      scores: [3, 7],
    ),
    MatchModel(
      id: 19,
      label: 'Match 19',
      table: 'Table 1',
      time: 'Sun 08:42 PM',
      competitors: [Player(name: 'Naoyuki Oi', flag: '🇯🇵'), Player(name: 'Eklent Kaçi', flag: '🇦🇱')],
      scores: [5, 7],
    ),
    MatchModel(
      id: 20,
      label: 'Match 20',
      table: 'Table 1',
      time: 'Mon 03:49 PM',
      competitors: [Player(name: 'Niels Feijen', flag: '🇳🇱'), Player(name: 'Jayson Shaw', flag: '🇬🇧')],
      scores: [7, 6],
    ),
  ];

  static const List<MatchModel> round3Tab1 = [
    MatchModel(
      id: 25,
      label: 'Match 25',
      table: 'Table 1',
      time: 'Tue 03:42 PM',
      competitors: [Player(name: 'Skyler Woodward', flag: '🇺🇸'), Player(name: 'Alex Kazakis', flag: '🇬🇷')],
      scores: [3, 7],
    ),
    MatchModel(
      id: 26,
      label: 'Match 26',
      table: 'Table 1',
      time: 'Mon 09:06 PM',
      competitors: [Player(name: 'Eklent Kaçi', flag: '🇦🇱'), Player(name: 'Niels Feijen', flag: '🇳🇱')],
      scores: [7, 0],
    ),
  ];

  static const List<MatchModel> round4Tab1 = [
    MatchModel(
      id: 29,
      label: 'Match 29',
      table: 'Table 1',
      time: 'Tue 06:44 PM',
      competitors: [Player(name: 'Alex Kazakis', flag: '🇬🇷'), Player(name: 'Eklent Kaçi', flag: '🇦🇱')],
      scores: [7, 6],
    ),
  ];

  // Tab 2: Lower Bracket Matches
  static const List<MatchModel> round1Tab2 = [
    MatchModel(
      id: 9,
      label: 'Match 9',
      table: 'Table 1',
      time: 'Sun 02:28 PM',
      competitors: [Player(name: 'Fedor Gorst', flag: '🇷🇺')],
      scores: [0],
      status: MatchStatus.completed,
    ),
    MatchModel(
      id: 10,
      label: 'Match 10',
      table: 'Table 1',
      time: 'Sun 06:57 PM',
      competitors: [Player(name: 'Shane Van Boening', flag: '🇺🇸'), Player(name: 'Jakub Koniar', flag: '🇸🇰')],
      scores: [7, 4],
    ),
    MatchModel(
      id: 11,
      label: 'Match 11',
      table: 'Table 1',
      time: 'Sun 01:16 PM',
      competitors: [Player(name: 'Mieszko Fortuński', flag: '🇵🇱'), Player(name: 'Kristina Tkach', flag: '🇷🇺')],
      scores: [7, 2],
    ),
    MatchModel(
      id: 12,
      label: 'Match 12',
      table: 'Table 1',
      time: 'Sun 01:16 PM',
      competitors: [Player(name: 'Max Lechner', flag: '🇦🇹')],
      scores: [0],
      status: MatchStatus.completed,
    ),
    MatchModel(
      id: 13,
      label: 'Match 13',
      table: 'Table 1',
      time: 'Sun 04:11 PM',
      competitors: [Player(name: 'Joshua Filler', flag: '🇩🇪')],
      scores: [0],
      status: MatchStatus.completed,
    ),
    MatchModel(
      id: 14,
      label: 'Match 14',
      table: 'Table 1',
      time: 'Sat 09:08 PM',
      competitors: [Player(name: 'Chris Melling', flag: '🇬🇧'), Player(name: 'Sanjin Pehlivanovic', flag: '🇧🇦')],
      scores: [7, 4],
    ),
    MatchModel(
      id: 15,
      label: 'Match 15',
      table: 'Table 1',
      time: 'Sun 02:28 PM',
      competitors: [Player(name: 'Denis Grabe', flag: '🇪🇪'), Player(name: 'Roberto Gomez', flag: '🇵🇭')],
      scores: [7, 6],
    ),
    MatchModel(
      id: 16,
      label: 'Match 16',
      table: 'Table 1',
      time: 'Sun 02:28 PM',
      competitors: [Player(name: 'Albin Ouschan', flag: '🇦🇹')],
      scores: [0],
      status: MatchStatus.completed,
    ),
  ];

  static const List<MatchModel> round2Tab2 = [
    MatchModel(
      id: 21,
      label: 'Match 21',
      table: 'Table 1',
      time: 'Mon 07:54 PM',
      competitors: [Player(name: 'Fedor Gorst', flag: '🇷🇺'), Player(name: 'Shane Van Boening', flag: '🇺🇸')],
      scores: [1, 7],
    ),
    MatchModel(
      id: 22,
      label: 'Match 22',
      table: 'Table 1',
      time: 'Mon 12:59 PM',
      competitors: [Player(name: 'Mieszko Fortuński', flag: '🇵🇱'), Player(name: 'Max Lechner', flag: '🇦🇹')],
      scores: [5, 7],
    ),
    MatchModel(
      id: 23,
      label: 'Match 23',
      table: 'Table 1',
      time: 'Sun 04:11 PM',
      competitors: [Player(name: 'Joshua Filler', flag: '🇩🇪'), Player(name: 'Chris Melling', flag: '🇬🇧')],
      scores: [7, 5],
    ),
    MatchModel(
      id: 24,
      label: 'Match 24',
      table: 'Table 1',
      time: 'Mon 02:28 PM',
      competitors: [Player(name: 'Denis Grabe', flag: '🇪🇪'), Player(name: 'Albin Ouschan', flag: '🇦🇹')],
      scores: [7, 3],
    ),
  ];

  static const List<MatchModel> round3Tab2 = [
    MatchModel(
      id: 27,
      label: 'Match 27',
      table: 'Table 1',
      time: 'Tue 02:27 PM',
      competitors: [Player(name: 'Shane Van Boening', flag: '🇺🇸'), Player(name: 'Max Lechner', flag: '🇦🇹')],
      scores: [7, 4],
    ),
    MatchModel(
      id: 28,
      label: 'Match 28',
      table: 'Table 1',
      time: 'Tue 01:09 PM',
      competitors: [Player(name: 'Joshua Filler', flag: '🇩🇪'), Player(name: 'Denis Grabe', flag: '🇪🇪')],
      scores: [7, 5],
    ),
  ];

  static const List<MatchModel> round4Tab2 = [
    MatchModel(
      id: 30,
      label: 'Match 30',
      table: 'Table 1',
      time: 'Tue 08:41 PM',
      competitors: [Player(name: 'Shane Van Boening', flag: '🇺🇸'), Player(name: 'Joshua Filler', flag: '🇩🇪')],
      scores: [7, 6],
    ),
  ];

  // Grand Final Match 31
  static const MatchModel grandFinal = MatchModel(
    id: 31,
    label: 'Match 31',
    table: 'Table 1',
    time: 'Tue 10:14 PM',
    competitors: [Player(name: 'Alex Kazakis', flag: '🇬🇷'), Player(name: 'Shane Van Boening', flag: '🇺🇸')],
      scores: [9, 0],
  );

  // --- TEAMS BRACKET MOCK DATA ---
  static const List<MatchModel<Team>> teamRound1 = [
    MatchModel<Team>(
      id: 101,
      label: 'QF 1',
      table: 'Table 1',
      time: 'Mon 07:00 PM',
      competitors: [
        Team(name: 'Team Vietnam', logo: '🇻🇳', isCheckedIn: true),
        Team(name: 'Team USA', logo: '🇺🇸', isCheckedIn: true),
      ],
      scores: [5, 3],
    ),
    MatchModel<Team>(
      id: 102,
      label: 'QF 2',
      table: 'Table 2',
      time: 'Mon 07:00 PM',
      competitors: [
        Team(name: 'Team Spain', logo: '🇪🇸'),
        Team(name: 'Team Germany', logo: '🇩🇪'),
      ],
      scores: [5, 2],
    ),
    MatchModel<Team>(
      id: 103,
      label: 'QF 3',
      table: 'Table 3',
      time: 'Mon 08:00 PM',
      competitors: [
        Team(name: 'Team Japan', logo: '🇯🇵'),
        Team(name: 'Team Korea', logo: '🇰🇷'),
      ],
      scores: [5, 4],
    ),
    MatchModel<Team>(
      id: 104,
      label: 'QF 4',
      table: 'Table 4',
      time: 'Mon 08:00 PM',
      competitors: [
        Team(name: 'Team UK', logo: '🇬🇧'),
      ],
      scores: [0],
      status: MatchStatus.completed,
    ),
  ];

  static const List<MatchModel<Team>> teamRound2 = [
    MatchModel<Team>(
      id: 105,
      label: 'SF 1',
      table: 'Table 1',
      time: 'Tue 07:00 PM',
      competitors: [
        Team(name: 'Team Vietnam', logo: '🇻🇳'),
        Team(name: 'Team Spain', logo: '🇪🇸'),
      ],
      scores: [6, 4],
    ),
    MatchModel<Team>(
      id: 106,
      label: 'SF 2',
      table: 'Table 2',
      time: 'Tue 07:00 PM',
      competitors: [
        Team(name: 'Team Japan', logo: '🇯🇵'),
        Team(name: 'Team UK', logo: '🇬🇧'),
      ],
      scores: [3, 6],
    ),
  ];

  static const MatchModel<Team> teamGrandFinal = MatchModel<Team>(
    id: 107,
    label: 'Team Final',
    table: 'Table 1',
    time: 'Wed 08:00 PM',
    competitors: [
      Team(name: 'Team Vietnam', logo: '🇻🇳'),
      Team(name: 'Team UK', logo: '🇬🇧'),
    ],
    scores: [7, 5],
  );

  // --- MIXED BRACKET MOCK DATA (Competitors can be Player or Team!) ---
  static const List<MatchModel<dynamic>> mixRound1 = [
    MatchModel<dynamic>(
      id: 201,
      label: 'Mix SF 1',
      table: 'Table 1',
      time: 'Thu 07:00 PM',
      competitors: [
        Player(name: 'David Alcaide', flag: '🇪🇸'),
        Team(name: 'Team USA', logo: '🇺🇸', isCheckedIn: true),
      ],
      scores: [7, 9],
    ),
    MatchModel<dynamic>(
      id: 202,
      label: 'Mix SF 2',
      table: 'Table 2',
      time: 'Thu 08:00 PM',
      competitors: [
        Team(name: 'Team Vietnam', logo: '🇻🇳', isCheckedIn: true),
        Player(name: 'Shane Van Boening', flag: '🇺🇸'),
      ],
      scores: [9, 6],
    ),
  ];

  static const MatchModel<dynamic> mixGrandFinal = MatchModel<dynamic>(
    id: 203,
    label: 'Mix Final',
    table: 'Table 1',
    time: 'Fri 08:00 PM',
    competitors: [
      Team(name: 'Team USA', logo: '🇺🇸'),
      Team(name: 'Team Vietnam', logo: '🇻🇳'),
    ],
    scores: [8, 10],
  );
}
