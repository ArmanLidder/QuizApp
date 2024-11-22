import 'package:get/get.dart';
import 'package:polyquiz/constants/text/EnglishTextValue.dart';
import 'package:polyquiz/constants/text/FrenchTextValue.dart';
import 'package:polyquiz/models/user.dart';

class TranslationService extends GetxController {
  static TranslationService get instance => Get.find();
  Rx<Language> languageValue = Language.fr.obs;
  Language _currentLanguage = Language.fr;
  final frenchText = frenchTextValues;
  final englishText = englishTextValues;

  Language getEnumFromAbbreviation(String abbr) {
    switch (abbr) {
      case 'en':
        return Language.en;
      case 'tp':
        return Language.tp;
      case 'fr':
      default:
        return Language.fr;
    }
  }

  String get currentLanguageAbbr {
    switch(this._currentLanguage) {
      case Language.en:
        return 'en';
      case Language.fr:
        return 'fr';
      case Language.tp:
        return 'tp';
    }
    return 'fr';

  }

  void set currentLanguageAbbr(String abbr) {
    final value = getEnumFromAbbreviation(abbr);
    _currentLanguage = value;
    languageValue.value = value;
  }

  void set currentLanguage(Language language) {
    _currentLanguage = language;
    languageValue.value = language;
  }

  Map get text {
    switch (_currentLanguage) {
      case Language.en:
        return this.englishText;
      case Language.fr:
      default:
        return this.frenchText;
    }
  }
}