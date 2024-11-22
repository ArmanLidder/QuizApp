import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

class HistogramLegend extends StatelessWidget {
  HistogramLegend({super.key});
  ThemeService _themeService = ThemeService.instance;
  Map get text => TranslationService.instance.text;
  Map get gameText => text['GAME_INTERFACE'];
  Map get histogram => gameText['HISTOGRAM'];

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
            color: Color.fromRGBO(123, 229, 117, 1),
          )),
          TextSpan(
              text: histogram['CORRECT_ANSWERS'],
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
            color: Color.fromRGBO(246, 53, 53, 1),
          )),
          TextSpan(
              text: histogram['INCORRECT_ANSWERS'],
              style: TextStyle(color: _themeService.mainAccent.value))
        ]))
      ],
    );
  }
}
