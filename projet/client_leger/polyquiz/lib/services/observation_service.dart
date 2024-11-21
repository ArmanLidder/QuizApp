import 'package:get/get.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/socket_service.dart';

class ObservationService extends GetxController {
  static ObservationService get instance => Get.find();

  // SERVICES
  SocketService socketService = SocketService();
  GameService gameService = GameService();
  HostInterfaceManagementService hostInterfaceManagementService = HostInterfaceManagementService();
  GameInterfaceManagementService gameInterfaceManagementService = GameInterfaceManagementService();
  // RELEVANT ATTRIBUTES
  bool isHost = true;
  String observedUid = '';
  GameListItem? gameConfigs;
  List<String> playerList = [];

  void observeGame(GameListItem game) {
    this.gameConfigs = game;
    this.observedUid = this.gameConfigs!.hostUserId;
    this.gameService.isObservingHost = true;
    this.gameService.observedUid = this.observedUid;
    // this.configureBaseSocketFeatures()
    // ^ TODO
    this.socketService.sendMessage(SocketEvent.NEW_OBSERVER_GAME, {
      'roomId': this.gameConfigs!.room,
      'isFirst': true,
    });
    this.isHost = true;
  }
}