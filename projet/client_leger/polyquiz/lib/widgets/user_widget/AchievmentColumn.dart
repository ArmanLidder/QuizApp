import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';

import '../../models/user.dart';
import '../../services/LanguageService.dart';
import '../../services/user_service.dart';

class AchievementColumn extends StatelessWidget {
  final List<num> completedAchievements;
  final LanguageService ls = LanguageService.instance;

  AchievementColumn({required this.completedAchievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (index) {
        bool isCompleted = completedAchievements.contains(index+1);
        return Column(
          children: [
          AchievementBox(
          label: ls.achievementsList[index], // Use the index number as the title
          isDone: isCompleted,
        ),
          SizedBox(height: 5,)]);
      }),
    );
  }
}


class AchievementBox extends StatelessWidget {
  final String label;
  final bool isDone;

  AchievementBox({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Take up as much width as possible
      padding: const EdgeInsets.all(8.0), // Padding inside the box
      decoration: BoxDecoration(
        color: this.isDone ? Color(0xFFF9FF8A) : Colors.grey,        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(color: Colors.grey[400]!), // Optional border color
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align content to the start
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis, // Text will be truncated if too long
            ),
          ),
        ],
      ),
    );
  }
}