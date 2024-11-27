import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

class PlayerNotice extends StatelessWidget {
  final message;
  final GameInterfaceManagementService? gameInterfaceManagementService;
  final ThemeService _themeService = ThemeService.instance;
  Map get text => TranslationService.instance.text;
  Map get observerText => text['OBSERVER'];

  PlayerNotice({
    Key? key,
    required this.message,
    this.gameInterfaceManagementService,
  }) : super(key: key);

  Widget getPointage() => Text(
    TranslationService.instance.languageValue.value ==
        Language.fr
        ? 'Vous avez recu ${gameInterfaceManagementService?.gameService.lastQrlScore} %'
        : "You've received ${gameInterfaceManagementService?.gameService.lastQrlScore} %",
    style: TextStyle(
        fontSize: 16, color: _themeService.mainAccent.value),
  );

  Widget getWaitingMessage() => Text(
    '${message}',
    style: TextStyle(
        fontSize: 16, color: _themeService.mainAccent.value),
  );

  Widget getMainContent() {
    bool isObserver = this.gameInterfaceManagementService?.gameService.isObserverMode ?? false;
    bool hasEvaluated = gameInterfaceManagementService?.gameService.lastQrlScore != null;
    String obsQrlAnswer = "${observerText['QRL_PLAYER_ANSWER']}${this.gameInterfaceManagementService?.gameService.obsQrlAnswer}";
    Widget content = hasEvaluated ? getPointage() : getWaitingMessage();

    if (!isObserver) return content;

    return Column(
      children: [
        Text(obsQrlAnswer, style: TextStyle(fontSize: 16, color: _themeService.mainAccent.value)),
        content,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AnimatedBuilder(
            animation: gameInterfaceManagementService!.gameService,
            builder: (BuildContext context, Widget? snapshot) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: getMainContent(),
                  ),
                );
            }
        )
    );
  }
}
