
class Player {
  final String username;
  final int score;
  final int bonus;
  String status;
  bool canChat;
  String? name;

  Player({
    required this.username,
    required this.score,
    required this.bonus,
    required this.status,
    required this.canChat,
    this.name
  });

  factory Player.fromList(List<dynamic> data) {
    // Ensure the list has the expected length and types
    print(data);
    print('the data length is ${data.length}');
    if (!(data.length == 5 || data.length == 6)) {
      throw ArgumentError('Player data must have exactly 5 or 6 elements.');
    }

    if (data.length == 5) return Player(
      username: data[0] as String,
      score: data[1] as int,
      bonus: data[2] as int,
      status: data[3] as String,
      canChat: data[4] as bool,
    );

    return Player(
      username: data[0] as String,
      score: data[1] as int,
      bonus: data[2] as int,
      status: data[3] as String,
      canChat: data[4] as bool,
      name: data[5] as String,
    );
  }

  List<dynamic> toList() {
    return [
      username,
      score,
      bonus,
      status,
      canChat,
    ];
  }
}

class HostCurrentGameInterface {
  int roomId;
  String timerText;
  bool isGameOver;
  int currentTime;
  List<Player> leftPlayers;
  List<Player> players;
  List<int> histogramDataChangingResponses;
  bool isHostEvaluating;
  String gameStats;
  bool isPaused;
  bool isPanicMode;
  bool isValidated;

  HostCurrentGameInterface({
    required this.roomId,
    required this.timerText,
    required this.isGameOver,
    required this.currentTime,
    required this.leftPlayers,
    required this.players,
    required this.histogramDataChangingResponses,
    required this.isHostEvaluating,
    required this.gameStats,
    required this.isPaused,
    required this.isPanicMode,
    required this.isValidated,
  });

  factory HostCurrentGameInterface.fromJson(Map<String, dynamic> json) {
    return HostCurrentGameInterface(
      roomId: json['roomId'] as int,
      timerText: json['timerText'] as String,
      isGameOver: json['isGameOver'] as bool,
      currentTime: json['currentTime'] as int,
      leftPlayers: (json['leftPlayers'] as List<dynamic>).map((player) => Player.fromList(player as List<dynamic>)).toList(),
      players: (json['players'] as List<dynamic>).map((player) => Player.fromList(player)).toList(),
      histogramDataChangingResponses: (json['histogramDataChangingResponses'] as List).map((e) => (e ?? 0) as int).toList(),
      isHostEvaluating: json['isHostEvaluating'] as bool,
      gameStats: json['gameStats'] as String,
      isPaused: json['isPaused'] as bool,
      isPanicMode: json['isPanicMode'] as bool,
      isValidated: json['isValidated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'timerText': timerText,
      'isGameOver': isGameOver,
      'currentTime': currentTime,
      'leftPlayers': leftPlayers.map((player) => player.toList()).toList(),
      'players': players.map((player) => player.toList()).toList(),
      'histogramDataChangingResponses': histogramDataChangingResponses,
      'isHostEvaluating': isHostEvaluating,
      'gameStats': gameStats,
      'isPaused': isPaused,
      'isPanicMode': isPanicMode,
      'isValidated': isValidated,
    };
  }
}

class PlayerScore {
  final String username;
  final int score;

  PlayerScore({
    required this.username,
    required this.score,
  });

  // Factory constructor to create a PlayerScore instance from a List
  factory PlayerScore.fromList(List<dynamic> data) {
    if (data.length != 2) {
      throw ArgumentError('PlayerScore data must have exactly 2 elements.');
    }
    return PlayerScore(
      username: data[0] as String,
      score: data[1] as int,
    );
  }

  // Convert PlayerScore instance to List
  List<dynamic> toList() {
    return [username, score];
  }
}

class PlayerCurrentGameInterface {
  final int roomId;
  final bool isBonus;
  final int playerScore;
  final List<PlayerScore> players;
  final int qreAnswer;
  final String qrlAnswer;
  final List<int> choicesStatsValues;

  PlayerCurrentGameInterface({
    required this.roomId,
    required this.isBonus,
    required this.playerScore,
    required this.players,
    required this.qreAnswer,
    required this.qrlAnswer,
    required this.choicesStatsValues,
  });

  factory PlayerCurrentGameInterface.fromJson(Map<String, dynamic> json) {
    return PlayerCurrentGameInterface(
      roomId: json['roomId'] as int,
      isBonus: json['isBonus'] as bool,
      playerScore: json['playerScore'] as int,
      players: (json['players'] as List)
          .map((player) => PlayerScore.fromList(player as List<dynamic>))
          .toList(),
      qreAnswer: json['qreAnswer'] as int,
      qrlAnswer: json['qrlAnswer'] as String,
      choicesStatsValues: (json['choicesStatsValues'] as List)
          .map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'isBonus': isBonus,
      'playerScore': playerScore,
      'players': players.map((player) => player.toList()).toList(),
      'qreAnswer': qreAnswer,
      'qrlAnswer': qrlAnswer,
      'choicesStatsValues': choicesStatsValues,
    };
  }
}
