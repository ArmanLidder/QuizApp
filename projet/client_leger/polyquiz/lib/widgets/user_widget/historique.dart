import 'package:flutter/material.dart';
import 'package:polyquiz/constants/eventNameTomessage.dart';
import 'package:polyquiz/models/user.dart';

import '../../services/theme_service.dart';

class Event {
  final String eventType;
  final String timestamp;

  Event({required this.eventType, required this.timestamp});
}

class EvenementRow extends StatelessWidget {
  final String date;
  final String label;
  final Color color;
  final ThemeService themeService = ThemeService.instance;

  EvenementRow({
    required this.date,
    required this.label,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(date, style: TextStyle(color: themeService.mainAccent.value)),
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
  final ThemeService themeService = ThemeService.instance;

  Historique({required this.gameHistory, required this.loginHistory});

    List<Event> gameEvents(){
      return gameHistory.map((game) {
        String result = resultTypeToString[game.result]!;

        return Event(eventType: result, timestamp: game.timestamp);
      }).toList();
    }
    List<Event> loginEvents(){
        return loginHistory.map((login) {
        String eventType = loginEventTypeToString[login.eventType]!;
        return Event(eventType: eventType, timestamp: login.timestamp);
      }).toList();}

    List<EvenementRow> _generateEventRows(List<Event> allEvents) {
      // Sort events by timestamp
      allEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return allEvents.map((event) {
        String date = "${event.timestamp}".split(' ')[0];
        String? label = eventMessage[event.eventType] ?? "nullEventMessage" ;
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
            "Historique des connections",
            style: TextStyle(
              color: themeService.mainAccent.value,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: _generateEventRows(loginEvents()),
          ),
          Text(
            "Historique des parties",
            style: TextStyle(
              color: themeService.mainAccent.value,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: _generateEventRows(gameEvents()),
          ),
        ],
      );
    }
  }

