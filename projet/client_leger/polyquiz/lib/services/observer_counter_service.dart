import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'game_service.dart';
import 'package:flutter/material.dart';

class ObserverCounterService extends ChangeNotifier {
  SocketService socketService = SocketService();
  GameService gameService = GameService();
  int obsCount = 0;


  void initialize() {
    socketService.sendMessage(SocketEvent.GET_OBS_COUNT, gameService.realGameService.roomId);

    if (socketService.isSocketAlive()) {
      handleUpdateCounter();
    }
  }

  void handleUpdateCounter() {
    socketService.onMessage(SocketEvent.UPDATE_OBS_COUNT, (count) {
      obsCount = count;
      notifyListeners();
    });
  }
}