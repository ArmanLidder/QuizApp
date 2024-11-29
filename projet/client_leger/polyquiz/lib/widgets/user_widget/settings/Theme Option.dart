import 'package:flutter/material.dart';
import 'package:get/get.dart';  // Assuming GetX is used for state management
import 'package:polyquiz/services/theme_service.dart';

import '../../../services/translationService.dart';

class ThemeColorOption extends StatelessWidget {
  final String themeName; // The theme name to display and select
  final Color color;     // The color of the circle
  ThemeService themeService = ThemeService.instance;
  Map get settingsText=> TranslationService.instance.text['SETTINGS'];


  ThemeColorOption({
    required this.themeName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the widget rebuilds on themeName change
    return Obx(() {
      // When themeName in themeService changes, this block will rebuild.
      bool isSelected = themeName == themeService.themeName.value;
      return GestureDetector(
        onTap: () => themeService.setTheme(themeName),  // When tapped, set the theme
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Ensure the border is circular
                border: Border.all(
                  color: isSelected ? themeService.mainAccent.value : Colors.transparent, // Use accent color if selected
                  width: 3.0, // Border width
                ),
              ),
              child: CircleAvatar(
                backgroundColor: color, // Set the background color to the passed color
                radius: 32, // Set radius for the circle
                child: isSelected // If theme is selected, show a check icon inside the circle
                    ? Icon(
                  Icons.check,
                  color: themeService.mainAccent.value,
                  size: 20,
                )
                    : null,
              ),
            ),
            SizedBox(height: 8),  // Space between circle and label
            // Label under the circle
            Text(
              settingsText[themeName],
              style: TextStyle(fontSize: 14,
              color:  themeService.mainAccent.value),
            ),
          ],
        ),
      );
    });
  }
}
