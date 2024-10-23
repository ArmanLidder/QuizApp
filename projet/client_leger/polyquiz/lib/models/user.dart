
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