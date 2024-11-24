import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

import '../../services/LanguageService.dart';

class StarCard extends StatelessWidget {
  final String label;
  final bool isDone;
  final ThemeService _themeService = ThemeService.instance;

  StarCard({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120, // Height to accommodate longer text
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: this.isDone
            ? Color.fromARGB(255, 250, 249, 174)
            : _themeService.container.value,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDone ? Icons.star : Icons.star_border,
            size: 48,
            color: isDone ? Color(0xFFFCDB03) : _themeService.mainAccent.value,
          ),
          SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: this.isDone
                      ? Colors.brown
                      : _themeService.mainAccent.value),
              overflow: TextOverflow.visible,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class StarCardGrid extends StatelessWidget {
  final LanguageService ls = LanguageService.instance;
  Map get text => TranslationService.instance.text;
  Map get profileText => text['PROFILE'];

  StarCardGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print("starComponent build called");

      List achievementsList =
          LoggedInUserService.instance.observableAchievement.value;
      final List<String> labels =
          profileText['ALL_ACHIEVEMENTS'] as List<String>;

      return Wrap(
        spacing: 8.0, // Horizontal spacing between cards
        runSpacing: 8.0, // Vertical spacing between rows
        alignment: WrapAlignment.center, // Center-align the cards
        children: List.generate(labels.length, (index) {
          bool isDone = achievementsList.contains(index + 1);
          return StarCard(
            label: labels[index],
            isDone: isDone,
          );
        }),
      );
    });
  }
}
