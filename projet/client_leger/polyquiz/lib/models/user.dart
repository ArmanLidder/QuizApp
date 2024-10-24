
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
        gameMode: json['gamemode'] as String,
    );
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
    else theme = Theme.light;

    String languageValue = json['language'];
    Language language;
    if (languageValue == 'en') language = Language.en;
    else if (languageValue == 'fr') language = Language.fr;
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
      default:
        themeValue = 'light';
    }

    String languageValue;
    switch (this.language) {
      case Language.en:
        languageValue = 'en';
        break;
      case Language.fr:
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
}

enum Language {
  en,
  fr
}