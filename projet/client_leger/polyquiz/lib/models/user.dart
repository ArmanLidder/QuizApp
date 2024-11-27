
class User {
  final String uid;
  final String email;
  final String username;
  final String avatar;
  final List<String> friends;
  final num currency;
  final List<num> achievements;
  final num level;
  final num prestige;
  final bool isConnected;
  final UserStats stats;
  final List<LoginHistory> loginHistory;
  final List<GameHistory> gameHistory;
  final List<FriendRequest> friendRequests;
  final UserSettings settings;

  User({
    required this.uid,
    required this.email,
    required this.username,
    required this.avatar,
    required this.friends,
    required this.currency,
    required this.achievements,
    required this.level,
    required this.prestige,
    required this.isConnected,
    required this.stats,
    required this.loginHistory,
    required this.gameHistory,
    required this.friendRequests,
    required this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final friends = (json['friends'] as List<dynamic>).map((friend) => friend as String).toList();
    final achievements = (json['achievements'] as List<dynamic>).map((achievement) => achievement as num).toList();
    final loginHistory = (json['loginHistory'] as List<dynamic>).map((loginHistoryValue) => LoginHistory.fromJson(loginHistoryValue)).toList();
    final gameHistory = (json['gameHistory'] as List<dynamic>).map((gameHistoryValue) => GameHistory.fromJson(gameHistoryValue)).toList();
    final friendRequests = (json['friendRequests'] as List<dynamic>).map((friendRequest) => FriendRequest.fromJson(friendRequest)).toList();
    final user = User(
        uid: json['uid'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        avatar: json['avatar'] as String,
        friends: friends,
        currency: json['currency'] as num,
        achievements: achievements,
        level: json['level'] as num,
        prestige: json['prestige'] as num,
        isConnected: json['isConnected'] as bool,
        stats: UserStats.fromJson(json['stats']),
        loginHistory: loginHistory,
        gameHistory: gameHistory,
        friendRequests: friendRequests,
        settings: UserSettings.fromJson(json['settings']),
    );
    return user;
  }
}

class UserStats {
  final num gamesPlayed;
  final num gamesWon;
  final num avgCorrectAnswers;
  final num avgGameTime;

  UserStats({required this.gamesPlayed, required this.gamesWon, required this.avgCorrectAnswers, required this.avgGameTime});

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
        gamesPlayed: json['gamesPlayed'] as num,
        gamesWon: json['gamesWon'] as num,
        avgCorrectAnswers: json['avgCorrectAnswers'] as num,
        avgGameTime: json['avgGameTime'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'avgCorrectAnswers': avgCorrectAnswers,
      'avgGameTime': avgGameTime,
    };
  }
}

class LoginHistory {
  final EventType eventType;
  final dynamic timestamp;

  LoginHistory({required this.eventType, required this.timestamp});

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    EventType eventType;
    switch (json['eventType']) {
      case 'login':
        eventType = EventType.login;
        break;
      case 'logout':
      default:
        eventType = EventType.logout;
    }

    return LoginHistory(
        eventType: eventType,
        timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    String eventTypeValue;
    switch (this.eventType) {
      case EventType.login:
        eventTypeValue = "login";
        break;
      case EventType.logout:
      default:
        eventTypeValue = 'logout';
    }
    return {
      'eventType': eventTypeValue,
      'timestamp': timestamp,
    };
  }
}

enum EventType {
  login,
  logout
}


class GameHistory {
  final Result result;
  final dynamic timestamp;
  final num score;
  final String gameMode;

  GameHistory({required this.result, required this.timestamp, required this.score, required this.gameMode});

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    Result result;
    switch (json['result']) {
      case 'win':
        result = Result.win;
        break;
      case 'loss':
      default:
        result = Result.loss;
    }

    return GameHistory(
        result: result,
        timestamp: json['timestamp'],
        score: json['score'] as num,
        gameMode: json['gameMode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    String resultValue;
    switch (result) {
      case Result.win:
        resultValue = 'win';
        break;
      case Result.loss:
      default:
        resultValue = 'loss';
    }
    return {
      'result': resultValue,
      'score': score,
      'gameMode': gameMode,
    };
  }
}

enum Result {
  win,
  loss
}

class FriendRequest {
  final String fromUserId;
  final String toUserId;

  FriendRequest({required this.fromUserId, required this.toUserId});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(fromUserId: json['fromUserId'] as String, toUserId: json['toUserId'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
    };
  }
}

class UserSettings {
  final Theme theme;
  final Language language;
  final bool notificationsEnabled;

  UserSettings({required this.theme, required this.language, required this.notificationsEnabled});

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    String themeValue = json['theme'];
    Theme theme;
    if (themeValue == 'light') theme = Theme.light;
    else if (themeValue == 'dark') theme = Theme.dark;
    else if (themeValue == 'disco') theme = Theme.disco;
    else if (themeValue == 'bluePink') theme = Theme.blueGrey;
    else theme = Theme.light;

    String languageValue = json['language'];
    Language language;
    if (languageValue == 'en') language = Language.en;
    else if (languageValue == 'fr') language = Language.fr;
    else if (languageValue == 'tp') language = Language.tp;

    else language = Language.fr;

    return UserSettings(
        theme: theme,
        language: language,
        notificationsEnabled: json['notificationsEnabled'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    String themeValue;
    switch (this.theme) {
      case Theme.dark:
        themeValue = 'dark';
        break;
      case Theme.light:
        themeValue = 'light';
        break;
      case Theme.disco:
        themeValue = 'disco';
        break;
      case Theme.blueGrey:
        themeValue = 'blueGrey';
        break;
      default:
        themeValue = 'light';
    }

    String languageValue;
    switch (this.language) {
      case Language.en:
        languageValue = 'en';
        break;
      case Language.fr:
        languageValue='fr';
        break;
      case Language.tp:
        languageValue = 'tp';
        break;
      default:
        languageValue = 'fr';
    }

    return {
      'theme': themeValue,
      'language': languageValue,
      'notificaitionsEnabled': notificationsEnabled,
    };
  }
}

enum Theme {
  light,
  dark,
  disco,
  blueGrey
}

enum Language {
  en,
  fr,
  tp
}


Map<Language,String> languageToString = {
  Language.tp: "tp",
  Language.en : "en",
  Language.fr : "fr",
};