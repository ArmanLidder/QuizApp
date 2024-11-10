import 'package:flutter/material.dart';

class StatitisticsBlorb extends StatelessWidget {
  final num nPlayedGames;
  final num nWonGames;
  final num avgGoodAnswers;
  final num avgGameTime;

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
                "Statistiques",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                  StatRow("Parties Jouées:", nPlayedGames),
                  StatRow("Parties Gagnées:", nWonGames),
                  StatRow("Bonnes réponses par partie:", avgGoodAnswers),
                  StatRow("Temps moyen par partie:", avgGameTime, " secondes"),
                ],
            ),)
          ],
        );
  }
}

Widget StatRow(String label, num value, [String postStatString = ""]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4),
      Text(
        value.toString() + postStatString,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
