import 'package:flutter/material.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

class StatitisticsBlorb extends StatelessWidget {
  final num nPlayedGames;
  final num nWonGames;
  final num avgGoodAnswers;
  final num avgGameTime;
  final ThemeService themeService = ThemeService.instance;
  final LanguageService ls = LanguageService.instance;

  Map get profileText => TranslationService.instance.text["PROFILE"];

  StatitisticsBlorb({
    required this.nPlayedGames,
    required this.nWonGames,
    required this.avgGoodAnswers,
    required this.avgGameTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Align(
          alignment: Alignment.centerLeft,
            child: Text(
                profileText['STATISTICS'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: themeService.mainAccent.value,
                ),
              )
          ),
            SizedBox(
              width: 450,
              child: GridView(
                shrinkWrap: true, // Ensures GridView takes only necessary space
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Sets 2 columns
                  mainAxisSpacing: 60.0, // Space between rows
                  crossAxisSpacing: 30.0, // Space between columns
                  mainAxisExtent: 70.0, // Ensures consistent row height
                ),
                children: [
                  StatRow(profileText['GAMES_PLAYED'], nPlayedGames),
                  StatRow(profileText['GAMES_WON'], nWonGames),
                  StatRow(profileText['AVG_CORRECT_ANSWERS'], avgGoodAnswers),
                  StatRow(profileText['AVG_GAME_TIME'], avgGameTime, " "+ profileText['SECONDS']),
                ],
            ),)
          ],
        );
  }
}

Widget StatRow(String label, num value, [String postStatString = ""]) {
  final ThemeService themeService = ThemeService.instance;


  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeService.mainAccent.value,
        ),
      ),
      SizedBox(height: 4),
      Text(
        value.toString() + postStatString,
        style: TextStyle(
          fontSize: 22,
          color: themeService.mainAccent.value,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
