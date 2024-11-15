import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/theme_service.dart';

class StatitisticsBlorb extends StatelessWidget {
  final num nPlayedGames;
  final num nWonGames;
  final num avgGoodAnswers;
  final num avgGameTime;
  final ThemeService themeService = ThemeService.instance;
  final LanguageService ls = LanguageService.instance;

  StatitisticsBlorb({
    required this.nPlayedGames,
    required this.nWonGames,
    required this.avgGoodAnswers,
    required this.avgGameTime,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Align(
          alignment: Alignment.centerLeft,
            child: Text(
                ls.statisticsLabels["stats"]!,
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
                  StatRow(ls.statisticsLabels["gamesPlayed"]!, nPlayedGames),
                  StatRow(ls.statisticsLabels["gamesWon"]!, nWonGames),
                  StatRow(ls.statisticsLabels["correctAnswersPerGame"]!, avgGoodAnswers),
                  StatRow(ls.statisticsLabels["averageTimePerGame"]!, avgGameTime, " "+ ls.secondsLabel),
                ],
            ),)
          ],
        );
    });
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
