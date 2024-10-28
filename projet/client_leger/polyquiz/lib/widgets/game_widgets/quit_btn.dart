import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/socket_service.dart';

class QuitBtn extends StatelessWidget {
  final bool isHost;
  final int roomId;
  final GlobalNavigationService _globalNavigationService =
      GlobalNavigationService();
  final SocketService _socketService = SocketService();

  QuitBtn({Key? key, required this.isHost, required this.roomId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (this.isHost) {
          this._socketService.sendMessage(SocketEvent.HOST_LEFT, roomId);
          print('HOST LEFT');
        } else {
          this._socketService.sendMessage(SocketEvent.PLAYER_LEFT, roomId);
          print('PLAYER LEFT');
        }
        _globalNavigationService.navigateTo('/home');
      },
      child: Text(
        'Quitter',
        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20),
      ),
      style: TextButton.styleFrom(
          textStyle: TextStyle(fontWeight: FontWeight.normal),
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Color.fromRGBO(246, 53, 53, 1)),
    );
  }
}
