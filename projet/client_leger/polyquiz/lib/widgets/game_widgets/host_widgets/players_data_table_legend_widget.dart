import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';

class PlayersDataTableLegend extends StatelessWidget {
  PlayersDataTableLegend({super.key});
  ThemeService _themeService = ThemeService.instance;

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
              text: 'Inactif',
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
              text: 'A intéragi',
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
              text: 'A validé',
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
              text: 'A quitté',
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
              text: 'Fin de partie',
              style: TextStyle(color: _themeService.mainAccent.value))
        ])),
        SizedBox(
          width: 30.0,
        ),
      ],
    );
  }
}
