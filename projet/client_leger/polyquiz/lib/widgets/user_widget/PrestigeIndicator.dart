import 'package:flutter/material.dart';

import '../../services/theme_service.dart';

class PrestigeIndicator extends StatelessWidget {
  final num? prestige;
  final ThemeService themeService = ThemeService.instance;

  PrestigeIndicator({required this.prestige});

  @override
  Widget build(BuildContext context) {
    String prestigeText = 'Aucun'; // Default text

    if (prestige! >= 200) {
      prestigeText = '🏅Platine';
    } else if (prestige! >= 150) {
      prestigeText = '🥇Or';
    } else if (prestige! >= 100) {
      prestigeText = '🥈Argent';
    } else if (prestige! >= 50) {
      prestigeText = '🥉Bronze';
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min, // Only take up the space needed
        children: [
          SizedBox(width: 4), // Space between icon and text
          Text(prestigeText, style: TextStyle(fontSize: 14)), // Adjust font size for better fit
        ],
      ),

      backgroundColor: themeService.mainBackground.value.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: themeService.mainBackground.value),
      ),    );
  }
}
