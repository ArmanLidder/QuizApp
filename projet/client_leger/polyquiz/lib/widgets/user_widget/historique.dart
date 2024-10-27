import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';

class Event {
  final String eventType;
  final DateTime timestamp;

  Event({required this.eventType, required this.timestamp});
}

class EvenementRow extends StatelessWidget {
  final String date;
  final String label;
  final Color color;

  EvenementRow({
    required this.date,
    required this.label,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(date),
        Text("   "),
        Text(
          label,
          style: TextStyle(color: this.color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class Historique extends StatelessWidget {
  final List<GameHistory> gameHistory;
  final List<LoginHistory> loginHistory;

  Historique({required this.gameHistory, required this.loginHistory});

  List<EvenementRow> _generateEventRows() {
    // Map each GameHistory to an Event with eventType "Game"
    List<Event> gameEvents = gameHistory.map((game) {
      return Event(eventType: 'Game', timestamp: game.timestamp.toDate());
    }).toList();

    // Map each LoginHistory to an Event with eventType "Login"
    List<Event> loginEvents = loginHistory.map((login) {
      return Event(eventType: 'Login', timestamp: login.timestamp.toDate());
    }).toList();

    // Merge both lists of events
    List<Event> allEvents = [...gameEvents, ...loginEvents];

    // Sort events by timestamp
    allEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Generate EvenementRow widgets for each event
    return allEvents.map((event) {
      String date = "${event.timestamp.toLocal()}".split(' ')[0];
      String label = event.eventType;
      Color color = event.eventType == 'Login' ? Colors.blue : Colors.green;

      return EvenementRow(date: date, label: label, color: color);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Historique",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),
        Column(
          children: _generateEventRows(),
        ),
      ],
    );
  }
}
