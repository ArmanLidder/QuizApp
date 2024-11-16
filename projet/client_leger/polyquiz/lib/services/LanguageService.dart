import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/translationService.dart';

const Map <String,String> nameToAbr = {"English":"en","Français":"fr", "Toki Pona": "tp"};
const Map <String,String> abrToName = {"en":"English","fr":"Français", "tp":"Toki Pona"};

class LanguageService extends GetxService {
  static LanguageService get instance => Get.find<LanguageService>();

  final TranslationService ts = TranslationService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggedInUserService _loggedInUserService = Get.find<LoggedInUserService>();

  late RxString languageAbr = "".obs;
  Future<void> setLanguage(String newLanguageName) async {
    languageAbr.value = nameToAbr[newLanguageName]!;
    ts.currentLanguageAbbr = nameToAbr[newLanguageName] ?? '';
    await _updateLanguageInFirebase(nameToAbr[newLanguageName]!);
  }

  Future<void> loadLanguage() async {
    languageAbr.value = languageToString[_loggedInUserService.user!.settings.language]!;
    ts.currentLanguage = _loggedInUserService.user!.settings.language;
  }

  Future<void> _updateLanguageInFirebase(String newLanguage) async {
    final userId = _loggedInUserService.getUid();
    if (userId == null) {
      throw Exception("User is not logged in.");
    }
    await _firestore.collection('users').doc(userId).update({
      "settings.language": newLanguage,
    });
  }

  String welcomeMessage(String username) {
    switch (languageAbr.value) {
      case "fr":
        return "Bienvenue $username !";
      case "tp":
        return "O $username!";
      case "en":
      default:
        return "Welcome $username!";
    }
  }

  String get joinGameLabel {
    const labels = {
      "en": "Join Game",
      "fr": "Joindre une partie",
      "tp": "tawa e musi",
    };
    return labels[languageAbr.value] ?? "Join Game";
  }

  String get createGameLabel {
    const labels = {
      "en": "Create Game",
      "fr": "Créer une partie",
      "tp": "kama e musi",
    };
    return labels[languageAbr.value] ?? "Create Game";
  }

  String get storeLabel {
    const labels = {
      "en": "Store",
      "fr": "Magasin",
      "tp": "tomo kala",
    };
    return labels[languageAbr.value] ?? "Store";
  }

  String get playOfflineLabel {
    const labels = {
      "en": "Play Offline",
      "fr": "Jouer hors ligne",
      "tp": "musi ala pi ilo linja",
    };
    return labels[languageAbr.value] ?? "Play Offline";
  }
  String profileLabel(String username) {
    switch (languageAbr.value) {
      case "fr":
        return "Profil de $username";
      case "tp":
        return "lipu pi $username";
      case "en":
      default:
        return "Profile of $username";
    }
  }
  List<String> get medalLevels {
    const levels = {
      "en": ["None", "Bronze", "Silver", "Gold", "Platinum"],
      "fr": ["Aucun", "Bronze", "Argent", "Or", "Platine"],
      "tp": ["ala", "kule kepeken jelo", "kule kepeken walo", "kule kepeken suli", "kule pi ma pi suli"],
    };
    return levels[languageAbr.value] ?? ["None", "Bronze", "Silver", "Gold", "Platinum"];
  }
  String get moneyLabel {
    switch (languageAbr.value) {
      case "fr":
        return "Argent";
      case "tp":
        return "mani";
      case "en":
      default:
        return "Money";
    }
  }

  Map<String, String> get statisticsLabels {
    switch (languageAbr.value) {
      case "fr":
        return {
          "stats": "Statistiques",
          "gamesPlayed": "Parties jouées",
          "gamesWon": "Parties gagnées",
          "correctAnswersPerGame": "Bonne réponse par partie",
          "averageTimePerGame": "Temps moyen par partie",
        };
      case "tp":
        return {
          "stats": "lipu pi toki",
          "gamesPlayed": "toki tawa",
          "gamesWon": "toki tawa pona",
          "correctAnswersPerGame": "kule wile lon toki tawa",
          "averageTimePerGame": "kule tawa poka toki tawa",
        };
      case "en":
      default:
        return {
          "stats": "Statistics",
          "gamesPlayed": "Games Played",
          "gamesWon": "Games Won",
          "correctAnswersPerGame": "Correct Answers Per Game",
          "averageTimePerGame": "Average Time Per Game",
        };
    }
  }
  String get secondsLabel {
    switch (languageAbr.value) {
      case "fr":
        return "secondes";
      case "tp":
        return "tenpo mun";
      case "en":
      default:
        return "seconds";
    }
  }
  String get friendsLabel {
    switch (languageAbr.value) {
      case "fr":
        return "Amis";
      case "tp":
        return "mani";
      case "en":
      default:
        return "Friends";
    }
  }
  String get filterByUsernameText {
    switch (languageAbr.value) {
      case 'fr':
        return 'Filtrer par nom d\'utilisateur';
      case 'en':
        return 'Filter by username';
      case 'tp': // Toki Pona
        return 'Kule tawa nimi pi użytkama';
      default:
        return 'Filter by username'; // Default to English if no language is set
    }
  }
// Pending label getter
  String get pendingLabel {
    switch (languageAbr.value) {
      case "fr":
        return "En attente";
      case "tp":
        return "tenpo tawa";
      case "en":
      default:
        return "Pending";
    }
  }
  String get addLabel {
    switch (languageAbr.value) {
      case "fr":
        return "Ajouter";
      case "tp":
        return "lon";
      case "en":
      default:
        return "Add";
    }
  }
  List<String> get achievementsList {
    switch (languageAbr.value) {
      case "fr":
        return [
          "Gagner une partie en Ligne",
          "Gagner une partie en Équipe",
          "Gagner 5 parties",
          "Gagner 10 parties",
          "Atteindre le prestige bronze",
          "Atteindre le prestige argent",
          "Atteindre le prestige or",
          "Atteindre le prestige platine",
        ];
      case "tp":
        return [
          "kule e jan en tan insa linja",
          "kule e jan en tan insa poki",
          "kule 5 insa linja",
          "kule 10 insa linja",
          "tawa tan prestige kili",
          "tawa tan prestige palisa",
          "tawa tan prestige mani",
          "tawa tan prestige walo",
        ];
      case "en":
      default:
        return [
          "Win an online game",
          "Win a team game",
          "Win 5 games",
          "Win 10 games",
          "Reach bronze prestige",
          "Reach silver prestige",
          "Reach gold prestige",
          "Reach platinum prestige",
        ];
    }
  }
  Map<String, String> get eventMessage {
    switch (languageAbr.value) {
      case "fr":
        return {
          "win": "partie gagnée",
          "loss": "partie perdue",
          "login": "connexion",
          "logout": "déconnexion",
        };
      case "tp":
        return {
          "win": "kule insa linja",
          "loss": "kule insa poki",
          "login": "kule e tomo",
          "logout": "tawa tomo",
        };
      case "en":
      default:
        return {
          "win": "game won",
          "loss": "game lost",
          "login": "login",
          "logout": "logout",
        };
    }
  }
}
