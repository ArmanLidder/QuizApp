import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

const Map <String,String> nameToAbr = {"English":"en","Français":"fr"};
const Map <String,String> abrToName = {"en":"English","fr":"Français"};

class LanguageService extends GetxService {
  static LanguageService get instance => Get.find<LanguageService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggedInUserService _loggedInUserService = Get.find<LoggedInUserService>();

  final RxString languageAbr = "".obs;
  Future<void> setLanguage(String newThemeName) async {
    print(newThemeName);
    languageAbr.value = nameToAbr[newThemeName]!;
    await _updateLanguageInFirebase(nameToAbr[newThemeName]!);
  }

  // Get the theme from Firebase (e.g., during initialization)
  Future<void> loadLanguage() async {
    final userId = _loggedInUserService.getUid();
    if (userId == null) {
      throw Exception("User is not logged in.");
    }
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data()?['theme'] != null) {
      languageAbr.value = userDoc.data()?['theme'];
    } else {
      languageAbr.value = "default"; // Fallback to default
    }
  }

  // Private method to update the theme in Firebase
  Future<void> _updateLanguageInFirebase(String newLanguage) async {
    final userId = _loggedInUserService.getUid();
    if (userId == null) {
      throw Exception("User is not logged in.");
    }
    await _firestore.collection('users').doc(userId).update({
      "settings.language": newLanguage,
    });
  }
}
