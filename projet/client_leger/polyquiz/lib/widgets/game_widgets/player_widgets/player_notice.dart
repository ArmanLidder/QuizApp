import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

class PlayerNotice extends StatelessWidget {
  final message;
  final GameInterfaceManagementService? gameInterfaceManagementService;
  final ThemeService _themeService = ThemeService.instance;

  PlayerNotice({
    Key? key,
    required this.message,
    this.gameInterfaceManagementService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AnimatedBuilder(
            animation: gameInterfaceManagementService!.gameService,
            builder: (BuildContext context, Widget? snapshot) {
              if (gameInterfaceManagementService?.gameService.lastQrlScore !=
                  null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      TranslationService.instance.languageValue.value ==
                              Language.fr
                          ? 'Vous avez recu ${gameInterfaceManagementService?.gameService.lastQrlScore} points'
                          : "You've received ${gameInterfaceManagementService?.gameService.lastQrlScore} points",
                      style: TextStyle(
                          fontSize: 16, color: _themeService.mainAccent.value),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '${message}',
                      style: TextStyle(
                          fontSize: 16, color: _themeService.mainAccent.value),
                    ),
                  ),
                );
              }
            }));
  }
}
