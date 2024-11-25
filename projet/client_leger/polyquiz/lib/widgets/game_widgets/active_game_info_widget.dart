import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

class ActiveGameInfoWidget extends StatefulWidget {
  final String quizTitle;
  final String minRank;
  final String allowedPlayers;
  final String playerNum;
  final String gameMode;
  final String price;
  const ActiveGameInfoWidget({
    Key? key,
    required this.quizTitle,
    required this.minRank,
    required this.allowedPlayers,
    required this.playerNum,
    required this.gameMode,
    required this.price,
  }) : super(key: key);

  @override
  State<ActiveGameInfoWidget> createState() => _ActiveGameInfoWidgetState();
}

class _ActiveGameInfoWidgetState extends State<ActiveGameInfoWidget> {
  Map get activeText => TranslationService.instance.text['ACTIVE_GAME_LIST'];
  ThemeService themeService = ThemeService.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.quizTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: themeService.mainAccent.value),
                ),
              ),
              Expanded(
                child: Text(
                    "${activeText['MINIMUM_PRESTIGE']}: ${widget.minRank}",
                    style: TextStyle(
                        fontSize: 16, color: themeService.mainAccent.value)),
              ),
              Expanded(
                  child: Text(widget.allowedPlayers,
                      style: TextStyle(
                          fontSize: 16, color: themeService.mainAccent.value))),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: widget.playerNum,
                      style: TextStyle(
                          fontSize: 16, color: themeService.mainAccent.value)),
                  WidgetSpan(
                      child: Icon(Icons.people_outline,
                          color: themeService.mainAccent.value))
                ])),
              ),
              Expanded(
                child: Text("${activeText['GAME_MODE']}: ${widget.gameMode}",
                    style: TextStyle(
                        fontSize: 16, color: themeService.mainAccent.value)),
              ),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: widget.price,
                      style: TextStyle(
                          fontSize: 16, color: themeService.mainAccent.value)),
                  WidgetSpan(
                      child: Icon(Icons.monetization_on_outlined,
                          color: themeService.mainAccent.value))
                ])),
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
