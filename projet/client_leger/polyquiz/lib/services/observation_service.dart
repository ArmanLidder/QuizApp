import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:polyquiz/constants/constants.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/current_game_interface.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'package:polyquiz/models/host_interface.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/game_interface_management_service.dart' as gims;
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
  gims.GameInterfaceManagementService gameInterfaceManagementService = gims.GameInterfaceManagementService();
  // TRANSLATION VALUES
  Map get text => TranslationService.instance.text;
  Map get observerText => text['OBSERVER_INTERFACE'];
  Map get qreText => text['GAME_INTERFACE']['QRE_HISTOGRAM_X_VAL'];
  Map get histogramText => text['GAME_INTERFACE']['HISTOGRAM'];
  // RELEVANT ATTRIBUTES
  bool isHost = true;
  String observedUid = '';
  GameListItem? gameConfigs;
  RxList<String> playerList = <String>[].obs;
  void Function(bool)? callback;

  void observeGame(GameListItem game, BuildContext context) {
    this.gameConfigs = game;
    this.observedUid = this.gameConfigs!.hostUserId;
    this.gameService.isObservingHost = true;
    this.gameService.observedUid = this.observedUid;
    this.configureBaseSocketFeatures(context);
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
    this.handleQCMSelection();
  }

  void observeOtherPlayer(String newUid) {
    final oldUid = this.gameService.observedUid;
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
    print("The old old observeduid: $oldUid");
    print("The current observeduid: ${this.gameService.observedUid}");
    if (callback != null) callback!(this.isHost);
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
    this.socketService.onMessage(SocketEvent.GET_QRE_ANSWER_FOR_OBS, (value) {
      this.gameService.obsQreAnswer = value as int;
      this.gameService.realGameService.notifyOnChanged();
    });
  }

  void handleObsGetInitialQuestion() {
    this.socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION, (data) {
      InitialQuestionData questionData = InitialQuestionData(
        question: QuizQuestion.fromJson(data['question']),
        username: data['username'] ?? '',
        index: data['index'],
        numberOfQuestions: data['numberOfQuestions'],
      );
      this.gameService.realGameService.question = questionData.question;
      this.gameService.realGameService.isLast = questionData.numberOfQuestions == questionData.index;
    });
  }

  void handleGameStateReception() {
    this.socketService.onMessage(SocketEvent.RECEIVING_HOST_GAME_STATUS, (data) {
      final hostData = HostCurrentGameInterface.fromJson(data);
      this.setUpGameState(hostData);
      final resetPlayerStatus = this.hostInterfaceManagementService.isGameOver;
      this.hostInterfaceManagementService.interactiveListService.getPlayersList(
        this.gameService.realGameService.roomId,
        leftPlayers: this.hostInterfaceManagementService.leftPlayers,
        resetPlayerStatus: resetPlayerStatus
      );
    });
  }

  void handleGameStatusDistribution() {
    this.socketService.onMessage(SocketEvent.GAME_STATUS_DISTRIBUTION, (data) {
      this.unpackStats(this.parseGameStats(data as String));
    });
  }

  TransportStatsFormat parseGameStats(String stringifyStats) {
    final parsedData = jsonDecode(stringifyStats);
    if (parsedData is List<List>) {
      return parsedData;
    } else return [];
  }

  void unpackStats(TransportStatsFormat stats) {
    // TODO
  }

  void handlePlayerGameState() {
    this.socketService.onMessage(SocketEvent.RECEIVE_PLAYER_GAME_STATUS, (data) {
      final playerCGI = PlayerCurrentGameInterface.fromJson(data);
      this.gameInterfaceManagementService.isBonus = playerCGI.isBonus;
      this.gameInterfaceManagementService.isGameOver = this.hostInterfaceManagementService.isGameOver;
      this.gameInterfaceManagementService.playerScore = playerCGI.playerScore;
      // this.gameInterfaceManagementService.timerText = this.hostInterfaceManagementService.timerText;
      this.gameInterfaceManagementService.players = playerCGI.players;
      this.gameInterfaceManagementService.inPanicMode = this.hostInterfaceManagementService.isPanicMode;
      this.gameService.obsQreAnswer = playerCGI.qreAnswer;
      this.gameService.obsQrlAnswer = playerCGI.qrlAnswer;
      this.gameService.qrlAnswer = playerCGI.qrlAnswer;
      this.gameInterfaceManagementService.getScore();
    });
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
    this.socketService.onMessage(SocketEvent.RECEIVE_LAST_QRL_INTERACTION, (data) {
      // Assuming 'data' is a Map containing the expected values
      final Map<String, dynamic> dataMap = data as Map<String, dynamic>;

      if (gameService.observedUid == (dataMap['userId'] as String)) {
        gameService.lastQrlScore = dataMap['lastQRLScore'] ?? 0;
        gameService.obsQrlAnswer = dataMap['qrlAnswer'] ?? "";
      }
    });
  }

  void handleQCMSelection() {
    // TODO: MAKE IT WORK
    print('Handling: QCM SELECTION');
    this.socketService.onMessage(SocketEvent.OBS_QCM_INTERACTION, (data) {
      print("OBS QCM SELECTION EVENT RECEIVED, DOING THE STUFF");
      final roomId = data['roomId'] as int;
      final isSelected = data['isSelected'] as bool;
      final index = data['index'] as int;
      print('Choosing: $index as $isSelected');
      this.gameService.obsUpdateChoice(index, isSelected);
    });
  }

  void reset(BuildContext context) {
    this.hostInterfaceManagementService.reset(context);
    this.gameInterfaceManagementService.reset();
  }
}