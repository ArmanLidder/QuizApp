import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

class PlayersDataTableLegend extends StatelessWidget {
  PlayersDataTableLegend({super.key});
  final ThemeService _themeService = ThemeService.instance;
  Map get text =>
      TranslationService.instance.text['GAME_INTERFACE']['PLAYER_LIST'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(246, 53, 53, 1),
          )),
          TextSpan(
              text: text['INACTIVE'],
              style: TextStyle(color: _themeService.mainAccent.value))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(255, 226, 108, 1),
          )),
          TextSpan(
              text: text['INTERACTION'],
              style: TextStyle(color: _themeService.mainAccent.value))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(123, 229, 117, 1),
          )),
          TextSpan(
              text: text['VALIDATION'],
              style: TextStyle(color: _themeService.mainAccent.value))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(31, 31, 31, 1),
          )),
          TextSpan(
              text: text['QUIT'],
              style: TextStyle(color: _themeService.mainAccent.value))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(221, 221, 221, 1),
          )),
          TextSpan(
              text: text['GAME_END'],
              style: TextStyle(color: _themeService.mainAccent.value))
        ])),
        SizedBox(
          width: 30.0,
        ),
      ],
    );
  }
}
