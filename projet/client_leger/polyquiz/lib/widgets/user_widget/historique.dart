import 'package:flutter/material.dart';

class EvenementRow extends StatelessWidget {
  final String date;
  final String label;
  final Color color; // Optional color attribute

  EvenementRow(
      {required this.date, required this.label, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(date),
      Text("   "),
      Text(label,
          style: TextStyle(color: this.color, fontWeight: FontWeight.bold))
    ]);
  }
}

class Historique extends StatelessWidget {
  final List<EvenementRow> events; // List of EvenementRow widgets

  Historique({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
      children: [
        Text(
          "Historique",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16), // Space between title and list
        Column(
          children: events, // Add the list of events
        ),
      ],
    );
  }
}
