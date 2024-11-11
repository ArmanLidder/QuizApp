import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/themesNamesToColorArray.dart';

class ThemeService extends GetxService{

  // Static instance of ThemeService
  static final ThemeService instance = Get.find<ThemeService>();

  final RxString themeName = 'default'.obs;
  // Observable colors
  final Rx<Color> mainBackground = Colors.white.obs;
  final Rx<Color> mainAccent = Colors.black.obs;
  final Rx<Color> secondaryBackground = Colors.blue[500]!.obs;
  final Rx<Color> secondaryAccent = Colors.black.obs;  // Function to update all colors
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
    print("setting theme: " + themeName);
    this.themeName.value = themeName;
    if (themeColors.containsKey(themeName)) {
      List<Color> colors = themeColors[themeName]!;
      mainBackground.value = colors[0];
      mainAccent.value = colors[1];
      secondaryBackground.value = colors[2];
      secondaryAccent.value = colors[3];
    } else {
      throw ArgumentError('Theme name "$themeName" not found');
    }
  }
}
