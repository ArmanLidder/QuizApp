import 'package:get/get.dart';
import 'package:polyquiz/constants/textValues.dart';
import 'package:polyquiz/models/user.dart';

class TranslationService extends GetxController {
  static TranslationService get instance => Get.find();
  Language _currentLanguage = Language.fr;
  final frenchText = frenchTextValues;
  final englishText = englishTextValues;

  void set currentLanguage(Language language) {
    _currentLanguage = language;
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