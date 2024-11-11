import 'package:flutter/material.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';

class PlayerNotice extends StatelessWidget {
  final message;
  final GameInterfaceManagementService? gameInterfaceManagementService;

  const PlayerNotice({
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
                      'Vous avez recu ${gameInterfaceManagementService?.gameService.lastQrlScore}% des points',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '${message}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
            }));
  }
}
