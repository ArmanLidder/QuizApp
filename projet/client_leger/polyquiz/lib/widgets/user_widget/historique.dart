import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/constants/eventNameTomessage.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/LanguageService.dart';

import '../../services/theme_service.dart';
import 'package:intl/intl.dart';

import '../../services/translationService.dart';
class Event {
  final String eventType;
  final String timestamp;

  Event({required this.eventType, required this.timestamp});
}

class LoginEvenementRow extends StatelessWidget {
  final String date;
  final String label;
  final Color color;
  final ThemeService themeService = ThemeService.instance;

  LoginEvenementRow({
    required this.date,
    required this.label,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: this.color, fontWeight: FontWeight.bold),
        ),
        Text("   "),
        Text(date, style: TextStyle(color: themeService.mainAccent.value)),
      ],
    );
  }

}

  class GameEvenementRow extends StatelessWidget {
    final String date;
    final String label;
    final Color color;
    final String gameMode;
    final ThemeService themeService = ThemeService.instance;
    GameEvenementRow({
      required this.date,
      required this.label,
      required this.gameMode,
      this.color = Colors.black,
    });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: this.color, fontWeight: FontWeight.bold),
        ),
        Text(" - "),
        Text(date, style: TextStyle(color: themeService.mainAccent.value)),
        Text(", Gamemode: "),
        Text(gameMode)

      ],
    );
  }
}

class Historique extends StatelessWidget {
  final List<GameHistory> gameHistory;
  final List<LoginHistory> loginHistory;
  final ThemeService themeService = ThemeService.instance;
  final LanguageService ls = LanguageService.instance;
  Map get profileText => TranslationService.instance.text['PROFILE'];

  Historique({required this.gameHistory, required this.loginHistory});

    List<Event> gameEvents(){
      return gameHistory.map((game) {
        String result = resultTypeToString[game.result]!;
        return Event(eventType: result, timestamp: game.timestamp);
      }).toList();
    }
    List<Event> loginEvents(){
        return loginHistory.map((login) {
          DateTime dateTime =  login.timestamp.toDate();
        String eventType = loginEventTypeToString[login.eventType]!;
        return Event(eventType: eventType, timestamp: DateFormat('yyyy-MM dd-hh:mm').format(dateTime));
      }).toList();}


  List<Widget> _generateLoginRows(List<Event> events) {
    return events.map((event) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: LoginEvenementRow(
          date: event.timestamp,
          label: event.eventType,
          color: Colors.black,
        )
      );
    }).toList();
  }

  List<Widget> _generateGameRows(List<Event> events) {
    return events.map((event) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: GameEvenementRow(
          date: event.timestamp,
          label: event.eventType,
          gameMode: "Classic", // Replace with actual game mode if available
          color: Colors.black,
        )
      );
    }).toList();
  }
  
  
    @override
    Widget build(BuildContext context) {
      return Obx(
            () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileText['CONNECTION_HISTORY'],
            style: TextStyle(
              color: themeService.mainAccent.value,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: _generateLoginRows(loginEvents()),
          ),
          Text(
            profileText['GAME_HISTORY'],
            style: TextStyle(
              color: themeService.mainAccent.value,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: _generateGameRows(gameEvents()),
          ),
        ],
      ));
    }
  }

