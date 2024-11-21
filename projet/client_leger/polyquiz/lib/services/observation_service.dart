import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:polyquiz/constants/constants.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/current_game_interface.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/translationService.dart';

class ObservationService extends GetxController {
  static ObservationService get instance => Get.find();

  // SERVICES
  SocketService socketService = SocketService();
  GameService gameService = GameService();
  HostInterfaceManagementService hostInterfaceManagementService = HostInterfaceManagementService();
  GameInterfaceManagementService gameInterfaceManagementService = GameInterfaceManagementService();
  // TRANSLATION VALUES
  Map get text => TranslationService.instance.text;
  Map get observerText => text['OBSERVER_INTERFACE'];
  Map get qreText => text['GAME_INTERFACE']['QRE_HISTOGRAM_X_VAL'];
  Map get histogramText => text['GAME_INTERFACE']['HISTOGRAM'];
  // RELEVANT ATTRIBUTES
  bool isHost = true;
  String observedUid = '';
  GameListItem? gameConfigs;
  List<String> playerList = [];

  void observeGame(GameListItem game, BuildContext context) {
    this.gameConfigs = game;
    this.observedUid = this.gameConfigs!.hostUserId;
    this.gameService.isObservingHost = true;
    this.gameService.observedUid = this.observedUid;
    // this.configureBaseSocketFeatures(context)
    // ^ TODO
    this.socketService.sendMessage(SocketEvent.NEW_OBSERVER_GAME, {
      'roomId': this.gameConfigs!.room,
      'isFirst': true,
    });
    this.isHost = true;
  }

  void configureBaseSocketFeatures(BuildContext context) {
    this.handleGetQRLInteraction();
    this.handleGetQRLAnswer();
    this.handleGetQREAnswer();
    this.handleObsGetInitialQuestion();
    this.gameInterfaceManagementService.configureBaseSocketFeatures();
    this.hostInterfaceManagementService.configureBaseSocketFeatures(context);
    this.handleGameStateReception();
    this.handlePlayerGameState();
    this.handleGameStatusDistribution();
    this.handleHostLeft();
    this.handleLastQRLAnswerReception();
  }

  void observeOtherPlayer(String oldUid, String newUid) {
    final data = {
      'roomId': this.gameConfigs?.room,
      'oldUserId': oldUid,
      'newUserId': newUid,
      'isHost': this.isHost,
    };
    this.isHost = newUid == this.gameConfigs?.hostUserId;
    this.gameService.isObservingHost = this.isHost;
    this.gameService.observedUid = newUid;
    this.gameService.realGameService.username = this.isHost ? 'host' : newUid;
    if (this.gameService.isObserverMode) this.gameService.obsQrlAnswer = observerText['INACTIVE_PLAYER'];
    this.socketService.sendMessage(SocketEvent.CHANGE_OBSERVED_PLAYER, data);
    if (this.isHost) this.socketService.sendMessage(SocketEvent.NEW_OBSERVER_GAME, {
      'roomId': this.gameConfigs?.room,
      'isFirst': false,
    });
  }

  void handleHostLeft() {
    this.socketService.onMessage(SocketEvent.REMOVED_FROM_GAME, (_) {
      this.socketService.sendMessage(SocketEvent.OBS_LEFT, {
        'roomId': this.gameConfigs!.room,
        'observedId': this.gameService.observedUid,
      });
      // TODO: HANDLE ROUTER NAVIGATION
    });
  }

  void handleGetQRLInteraction() {
    this.socketService.onMessage(SocketEvent.GET_QRL_INTERACTION, (isActive) {
      this.gameService.qreAnswer = isActive as bool ? observerText['PLAYER_IS_WRITING'] : observerText['INACTIVE_PLAYER'];
    });
  }

  void handleGetQRLAnswer() {
    this.socketService.onMessage(SocketEvent.GET_QRL_ANSWER_FOR_OBS, (answer) {
      this.gameService.obsQrlAnswer = answer as String;
    });
  }

  void handleGetQREAnswer() {
    // TODO
  }

  void handleObsGetInitialQuestion() {
    // TODO
  }

  void handleGameStateReception() {
    // TODO
  }

  void handleGameStatusDistribution() {
    // TODO
  }

  void parseGameStats(String stringifyStats) {
    // TODO
  }

  void unpackStats(TransportStatsFormat stats) {
    // TODO
  }

  void handlePlayerGameState() {
    // TODO
  }

  void setUpGameState(HostCurrentGameInterface data) {
    this.gameService.realGameService.validated = data.isValidated;
    this.gameService.realGameService.timer = data.currentTime;
    this.hostInterfaceManagementService.timerText = data.timerText;
    this.hostInterfaceManagementService.isGameOver = data.isGameOver;
    this.hostInterfaceManagementService.isHostEvaluating = data.isHostEvaluating;
    this.hostInterfaceManagementService.isPanicMode = data.isPanicMode;
    this.hostInterfaceManagementService.isPaused = data.isPaused;
    this.hostInterfaceManagementService.leftPlayers = data.leftPlayers;
    this.hostInterfaceManagementService.interactiveListService.players = data.players;
    this.gameInterfaceManagementService.gameStats = [];
    this.gameInterfaceManagementService.unpackStats(this.gameInterfaceManagementService.parseGameStats(data.gameStats));
    this.hostInterfaceManagementService.gameStats = this.gameInterfaceManagementService.gameStats;
    if (!data.isGameOver) {
      final histValue = data.histogramDataChangingResponses;
      if (data.histogramDataChangingResponses.length == 2) {
        this.hostInterfaceManagementService.histogramDataChangingResponses = {
          histogramText['ACTIVE']: histValue[0],
          histogramText['INACTIVE']: histValue[1]
        };
      } else if (data.histogramDataChangingResponses.length == 3) {
        this.hostInterfaceManagementService.histogramDataChangingResponses = {
          qreText['WITHIN_MARGIN']: histValue[0],
          qreText['EXACT_ANSWER']: histValue[1],
          qreText['INCORRECT_ANSWER']: histValue[2],
        };
      } else this.hostInterfaceManagementService.histogramDataChangingResponses = this.hostInterfaceManagementService.createChoicesStatsMap(histValue);
    }
  }

  void handleLastQRLAnswerReception() {
    // TODO
  }

  void reset(BuildContext context) {
    this.hostInterfaceManagementService.reset(context);
    this.gameInterfaceManagementService.reset();
  }
}