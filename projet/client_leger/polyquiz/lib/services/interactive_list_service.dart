import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/player_status.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/score.dart';
import 'package:polyquiz/services/socket_service.dart';

class InteractiveListService extends ChangeNotifier {
  static final InteractiveListService _instance =
      InteractiveListService._internal();

  InteractiveListService._internal();

  factory InteractiveListService() {
    return _instance;
  }

  List<Player> players = []; //check player type for each service
  bool isFinal = false;
  List<Player> actualStatus = [];

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

  void gatherPlayersUsername(RoomSettings roomSettings, Function(int) resolve,
      List<Player> leftPlayers) {
    _socketService.sendMessageWithAck(
        SocketEvent.GATHER_PLAYERS_USERNAME, roomSettings.roomId, (players) {
      resolve(players.length);
      setUpPlayerList(leftPlayers);
      for (String username in players) {
        print('USERNAME IN PLAYERS: ${username}');
        getPlayerScoreFromServer(
            UserData(
                username: username,
                resetPlayerStatus: roomSettings.resetPlayerStatus),
            roomSettings.roomId,
            leftPlayers);
      }
    });
  }

  void toggleChatPermission(String username, int roomId) {
    int playerIndex = findPlayer(username, players);
    players[playerIndex].canChat = !players[playerIndex].canChat;
    _socketService.sendMessage(SocketEvent.TOGGLE_CHAT_PERMISSION,
        {'roomId': roomId, 'username': username});
  }

  void configureBaseSocketFeatures() {
    reset();
    handleUpdateInteraction();
    handleSubmitAnswer();
  }

  bool isPlayerGone(String username, List<Player> remainingPlayers) {
    return remainingPlayers.any((player) => player.username == username);
  }

  void setUpPlayerList(List<Player> leftPlayers) {
    this.actualStatus = this.players;
    this.players.clear();
    appendLeftPlayersToActivePlayers(leftPlayers);
  }

  void getPlayerScoreFromServer(
      UserData userInfo, int roomId, List<Player> leftPlayers) {
    _socketService.sendMessageWithAck(SocketEvent.GET_SCORE, {
      'roomId': roomId,
      'username': userInfo.username,
    }, (score) {
      this.addPlayer(userInfo, Score.fromJson(score), leftPlayers);
    });
  }

  void addPlayer(UserData userInfo, Score score, List<Player> leftPlayers) {
    var status = initPlayerStatus(
        userInfo.username, userInfo.resetPlayerStatus, leftPlayers);
    bool canChat = canPlayerChat(userInfo.username);
    players.add(Player(
        username: userInfo.username,
        score: score.points,
        bonus: score.bonusCount,
        status: status,
        canChat: canChat));
    notifyListeners();
  }

  bool canPlayerChat(String username) {
    final int playerIndex = this.findPlayer(username, this.actualStatus);
    print('PLAYER INDEX: ${playerIndex}');
    for (Player player in actualStatus) {
      print('ACTUAL STATUS CONTENT: ${player.username}');
    }
    return this.actualStatus.length == 0 ||
            playerIndex ==
                -1 // bug potentiel du actualstatus qui n'a pas tous les joueurs au bon moment
        ? true
        : this.actualStatus[playerIndex].canChat;
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
      String username, bool resetPlayerStatus, List<Player> leftPlayers) {
    if (this.isPlayerGone(username, leftPlayers))
      return PlayerStatus.LEFT;
    else if (!resetPlayerStatus)
      return this.getActualStatus(username);
    else
      return this.isFinal ? PlayerStatus.END_GAME : PlayerStatus.NO_INTERACTION;
  }

  String getActualStatus(String username) {
    final playerIndex = this.findPlayer(username, this.actualStatus);
    return this.actualStatus[playerIndex].status;
  }

  void reset() {
    this.isFinal = false;
    this.actualStatus = [];
    this.players = [];
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
