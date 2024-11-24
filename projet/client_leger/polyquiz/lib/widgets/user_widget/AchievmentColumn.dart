import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import '../../services/LanguageService.dart';

class AchievementColumn extends StatelessWidget {
  final List<num> completedAchievements;
  final LanguageService ls = LanguageService.instance;

  AchievementColumn({required this.completedAchievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (index) {
        bool isCompleted = completedAchievements.contains(index + 1);
        return Column(children: [
          AchievementBox(
            label:
                ls.achievementsList[index], // Use the index number as the title
            isDone: isCompleted,
          ),
          SizedBox(
            height: 5,
          )
        ]);
      }),
    );
  }
}

class AchievementBox extends StatelessWidget {
  final String label;
  final bool isDone;
  final ThemeService _themeService = ThemeService.instance;

  AchievementBox({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Take up as much width as possible
      padding: const EdgeInsets.all(8.0), // Padding inside the box
      decoration: BoxDecoration(
        color: this.isDone
            ? Color.fromARGB(255, 250, 249, 174)
            : _themeService.container.value,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(color: Colors.grey[400]!), // Optional border color
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Align content to the start
        children: [
          Icon(
            this.isDone ? Icons.star : Icons.star_border,
            size: 24,
            color: this.isDone ? Color(0xFFFCDB03) : Colors.black54,
          ),
          SizedBox(width: 12), // Space between icon and text
          Expanded(
            child: Text(
              this.label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: this.isDone
                      ? Colors.brown
                      : _themeService.mainAccent.value),
              overflow:
                  TextOverflow.ellipsis, // Text will be truncated if too long
            ),
          ),
        ],
      ),
    );
  }
}
