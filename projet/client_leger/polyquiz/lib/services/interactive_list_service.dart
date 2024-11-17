import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/player_status.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/score.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'user_service.dart';

class InteractiveListService extends ChangeNotifier {
  static final InteractiveListService _instance =
      InteractiveListService._internal();

  InteractiveListService._internal();

  factory InteractiveListService() {
    return _instance;
  }

  List<Player> players = []; //check player type for each service
  bool isFinal = false;
  bool isAlreadyInit = false;
  List<Player> actualStatus = [];
  User? user;
  final UserService userService = UserService();

  SocketService _socketService = SocketService();

  Future<int> getPlayersList(int roomId,
      {List<Player> leftPlayers = const [],
      bool resetPlayerStatus = true}) async {
    final completer = Completer<int>();
    gatherPlayersUsername(
        RoomSettings(resetPlayerStatus: resetPlayerStatus, roomId: roomId),
        completer.complete,
        leftPlayers);
    return completer.future;
  }

  Future<void> gatherPlayersUsername(RoomSettings roomSettings, Function(int) resolve,
      List<Player> leftPlayers) async {
    _socketService.sendMessageWithAck(
        SocketEvent.GATHER_PLAYERS_USERNAME, roomSettings.roomId, (players) async {
      resolve(players.length);
      setUpPlayerList(leftPlayers);
      for (String userID in players) {
          getPlayerScoreFromServer(
              UserData(
                  username: userID,
                  resetPlayerStatus: roomSettings.resetPlayerStatus),
              roomSettings.roomId,
              leftPlayers, this.actualStatus);
      }
    });
  }

  void toggleChatPermission(String username, int roomId) {
    int playerIndex = findPlayer(username, players);
    this.players[playerIndex].canChat = !this.players[playerIndex].canChat;
    _socketService.sendMessage(SocketEvent.TOGGLE_CHAT_PERMISSION,
        {'roomId': roomId, 'username': username});
  }

  void configureBaseSocketFeatures() {
    reset();
    handleUpdateInteraction();
    handleSubmitAnswer();
    isAlreadyInit = true;
  }

  bool isPlayerGone(String username, List<Player> remainingPlayers) {
    return remainingPlayers.any((player) => player.username == username);
  }

  void setUpPlayerList(List<Player> leftPlayers) {
    this.actualStatus = this.players.map((player) => Player(
      username: player.username,
      score: player.score,
      bonus: player.bonus,
      status: player.status,
      canChat: player.canChat
    )).toList();
    this.players.clear();
    appendLeftPlayersToActivePlayers(leftPlayers);
  }

  void getPlayerScoreFromServer(
      UserData userInfo, int roomId, List<Player> leftPlayers, List<Player> actualStatus) {
    _socketService.sendMessageWithAck(SocketEvent.GET_SCORE, {
      'roomId': roomId,
      'username': userInfo.username
    }, (score) {
      this.addPlayer(userInfo, Score.fromJson(score), leftPlayers, actualStatus);
    });
  }

  void addPlayer(UserData userInfo, Score score, List<Player> leftPlayers, List<Player> actualStatus) {
    String status = initPlayerStatus( userInfo.username, userInfo.resetPlayerStatus, leftPlayers, actualStatus);
    bool canChat = canPlayerChat(userInfo.username, actualStatus);
    this.players.add(Player(
        username: userInfo.username,
        score: score.points,
        bonus: score.bonusCount,
        status: status,
        canChat: canChat));
    notifyListeners();
  }

  bool canPlayerChat(String username, List<Player> actualStatus) {
    final int playerIndex = this.findPlayer(username, actualStatus);
    return this.actualStatus.length == 0 ||
            playerIndex ==
                -1 // bug potentiel du actualstatus qui n'a pas tous les joueurs au bon moment
        ? true
        : actualStatus[playerIndex].canChat;
  }

  void appendLeftPlayersToActivePlayers(List<Player> leftPlayers) {
    for (var player in leftPlayers) {
      player.canChat = false;
      player.status = PlayerStatus.LEFT;
      this.players.add(player);
    }
  }

  int findPlayer(String username, List<Player> players) {
    return players.indexWhere((player) => player.username == username);
  }

  void handleUpdateInteraction() {
    this._socketService.onMessage(SocketEvent.UPDATE_INTERACTION, (username) {
      this.changePlayerStatus(username, PlayerStatus.INTERACTION);
    });
  }

  void handleSubmitAnswer() {
    this._socketService.onMessage(SocketEvent.SUBMIT_ANSWER, (username) {
      this.changePlayerStatus(username, PlayerStatus.VALIDATION);
    });
  }

  void changePlayerStatus(String username, String status) {
    final playerIndex = this.findPlayer(username, this.players);
    if (playerIndex != -1) this.players[playerIndex].status = status;
    notifyListeners();
  }

  String initPlayerStatus(
      String username, bool resetPlayerStatus, List<Player> leftPlayers, List<Player> actualStatus) {
    if (this.isPlayerGone(username, leftPlayers))
      return PlayerStatus.LEFT;
    else if (!resetPlayerStatus)
      return this.getActualStatus(username, actualStatus);
    else
      return this.isFinal ? PlayerStatus.END_GAME : PlayerStatus.NO_INTERACTION;
  }

  String getActualStatus(String username, List<Player> actualStatus) {
    final playerIndex = this.findPlayer(username, actualStatus);
    return actualStatus[playerIndex].status;
  }

  void reset() {
    this.isFinal = false;
    this.actualStatus = [];
    this.players = [];
    this.isAlreadyInit = false;
  }
}

class Player {
  final String username;
  final int score;
  final int bonus;
  String status;
  bool canChat;

  Player({
    required this.username,
    required this.score,
    required this.bonus,
    required this.status,
    required this.canChat,
  });
}

class RoomSettings {
  final int roomId;
  final bool resetPlayerStatus;

  RoomSettings({
    required this.roomId,
    required this.resetPlayerStatus,
  });
}

class UserData {
  final String username;
  final bool resetPlayerStatus;

  UserData({
    required this.username,
    required this.resetPlayerStatus,
  });
}
