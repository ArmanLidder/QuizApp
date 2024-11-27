import 'package:flutter/material.dart';
import 'package:polyquiz/services/translationService.dart';

import '../../services/LanguageService.dart';
import '../../services/theme_service.dart';


String prestigeText(int prestige){
  Map trs = TranslationService.instance.text["PROFILE"];
  String prestigeText = '🚫 ' + trs["NONE"]!; // Default text
  if (prestige! >= 200) {
    prestigeText = '🏅 ' + trs["PLATINUM"]!;
  } else if (prestige! >= 150) {
    prestigeText = '🥇 ' + trs["GOLD"]!;
  } else if (prestige! >= 100) {
    prestigeText = '🥈 ' + trs["SILVER"]!;
  } else if (prestige! >= 50) {
    prestigeText = '🥉 ' + trs["BRONZE"]!;
  }
  return prestigeText;
}

class PrestigeIndicator extends StatelessWidget {
  final num? prestige;
  final ThemeService themeService = ThemeService.instance;
  final LanguageService ls = LanguageService.instance;

  PrestigeIndicator({required this.prestige});


  @override
  Widget build(BuildContext context) {

    return Chip(
      color: WidgetStatePropertyAll(const Color.fromRGBO(132, 124, 243, 1)),
      label: Row(
        mainAxisSize: MainAxisSize.min, // Only take up the space needed
        children: [
          SizedBox(width: 4), // Space between icon and text
          Text("Prestige: " + prestigeText(prestige! as int),
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white)), // Adjust font size for better fit
        ],
      ),
      backgroundColor: themeService.mainBackground.value.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: themeService.mainBackground.value),
      ),
    );
  }
}
