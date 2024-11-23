import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

import '../constants/themesNamesToColorArray.dart';

class ThemeService extends GetxService{

  // Static instance of ThemeService
  static final ThemeService instance = Get.find<ThemeService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

  final RxString themeName = 'default'.obs;
  // Observable colors
  final Rx<Color> mainBackground = Colors.white.obs;
  final Rx<Color> mainAccent = Colors.black.obs;
  final Rx<Color> secondaryBackground = Colors.blue[500]!.obs;
  final Rx<Color> secondaryAccent = Colors.black.obs;
  Color get mixedMain {
    return Color.lerp(mainBackground.value, mainAccent.value, 0.25)!;
  }

  // Function to update all colors
  void setColors(List<Color> colors) {
    if (colors.length == 4) {
      mainBackground.value = colors[0];
      mainAccent.value = colors[1];
      secondaryBackground.value = colors[2];
      secondaryAccent.value = colors[3];
    } else {
      throw ArgumentError('Expected exactly 4 colors in the array');
    }
  }
  void setTheme(String themeName) {
    this.themeName.value = themeName;
    if (themeColors.containsKey(themeName)) {
      List<Color> colors = themeColors[themeName]!;
      mainBackground.value = colors[0];
      mainAccent.value = colors[1];
      secondaryBackground.value = colors[2];
      secondaryAccent.value = colors[3];
      _firestore.collection('users').doc(loggedInUserService.getUid()).update({
        "settings.theme": themeName,
      });


    } else {
      throw ArgumentError('Theme name "$themeName" not found');
    }
  }
}
