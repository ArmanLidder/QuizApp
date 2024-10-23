import 'package:flutter/material.dart';

class StatitisticsBlorb extends StatelessWidget {
  final int nPlayedGames;
  final int nWonGames;
  final int avgGoodAnswers;
  final int avgGameTime;

  StatitisticsBlorb({
    required this.nPlayedGames,
    required this.nWonGames,
    required this.avgGoodAnswers,
    required this.avgGameTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Statistiques",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          StatRow("parties Jouées: ", nPlayedGames),
          StatRow("parties Gagnées: ", nWonGames),
          StatRow("bonnes réponses par partie: ", avgGoodAnswers),
          StatRow("temps moyen par partie: ", avgGameTime, " secondes "),
        ],
      ),
    );
  }
}

Widget StatRow(String label, int value, [String postStatString = ""]) {
  return Row(
    children: [
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 8), // Adds some space between the label and value.
      Text(value.toString()),
      Text(postStatString),
    ],
  );
}
