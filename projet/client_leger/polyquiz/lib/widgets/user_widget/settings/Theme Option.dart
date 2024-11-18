import 'package:flutter/material.dart';
import 'package:get/get.dart';  // Assuming GetX is used for state management
import 'package:polyquiz/services/theme_service.dart';

class ThemeColorOption extends StatelessWidget {
  final String themeName; // The theme name to display and select
  final Color color;     // The color of the circle
  ThemeService themeService = ThemeService.instance;

  // Constructor
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
            CircleAvatar(
              backgroundColor: color,  // Set the background color to the passed color
              radius: 32,  // Set radius for the circle
              child: isSelected  // If theme is selected, show a check icon inside the circle
                  ? Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
                  : null,
            ),
            SizedBox(height: 8),  // Space between circle and label
            // Label under the circle
            Text(
              themeName,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    });
  }
}
