import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/models/teams.dart';
import 'package:polyquiz/models/teams_models.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'socket_service.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/models/game_info_interface.dart';

class WaitingRoomService extends ChangeNotifier {
  static final WaitingRoomService _instance = WaitingRoomService._internal();
  final SocketService _socketService =
      SocketService(); // Use the SocketService instance
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;

  int roomId = 0;
  bool isRoomLocked = false;
  bool isGameStarting = false;
  bool isTransition = false;
  List<String> players = [];
  num time = 0;
  Map<int, List<String>> teams = {};
  List<TeamsForInterface> teamsForInterface = [];
  String gameType = 'classic';

  WaitingRoomService._internal();

  factory WaitingRoomService() {
    return _instance;
  }

  void setUpService() {
    this.roomId = 0;
    this.isRoomLocked = false;
    this.isGameStarting = false;
    this.isTransition = false;
    this.players = [];
    this.time = 0;
    this.teams = {};
    this.teamsForInterface = [];
  }

  bool isSocketAlive() {
    return _socketService.isSocketAlive();
  }

  Future<void> connectToSocket(String roomId,
      {required bool isHost, String? username, bool? isFromActiveList}) async {
    this.userData = this.loggedInUserService.getUser();
    if (!isHost) {
      this.roomId = int.parse(roomId);
    }
    if (!_socketService.isSocketAlive()) {
      print("Socket is not connected. Attempting to connect...");
      _socketService.connect(this.userData?.uid);
    }

    if (isFromActiveList != null && isFromActiveList) {
      print("Joining room from active list");
      sendJoinRoomRequest(roomId, username!);
    }

    _socketService.onMessage(SocketEvent.CONNECTION, (_) {
      print('Connected to WebSocket');
      if (username != null && isHost == false) {
        sendJoinRoomRequest(roomId, username);
      }
    });
  }

  Future<String> createRoom(String quizId, GameConfig gameConfig) async {
    final completer = Completer<String>();
    print('Creating room for quiz: $quizId');

    if (!isSocketAlive()) {
      print("Socket is not connected. Attempting to connect...");
      await connectToSocket("roomId", isHost: true);
    }

    final data = {
      'quizId': quizId,
      'gameConfig': gameConfig.toJson(),
    };

    _socketService.sendMessageWithAck(SocketEvent.CREATE_ROOM, data,
        (roomCode) {
      if (roomCode != null) {
        print("Room created with ID: $roomCode");
        completer.complete(roomCode.toString());
        this.roomId = roomCode;
      } else {
        print('Failed to create room');
        completer.completeError('Failed to create room');
      }
    });

    return completer.future;
  }

  Future<String> sendJoinRoomRequest(String roomId, String username) async {
    if (!isSocketAlive()) {
      return 'Socket is not connected, cannot join room';
    }

    final completer = Completer<String>();

    final usernameData = {
      'roomId': int.parse(roomId),
      'username': username,
    };

    print('Joining room with data: $usernameData');

    _socketService.sendMessageWithAck(SocketEvent.JOIN_GAME, usernameData,
        (isLocked) {
      if (isLocked is bool) {
        print("is joining room locked: $isLocked");
        final result = _handleJoiningRoomValidation(isLocked);
        completer.complete(result);
      } else {
        completer.complete('Unexpected response from server');
      }
    });

    print("joined room with id: $roomId");

    return completer.future;
  }

  void sendBanPlayer(String username) {
    removePlayer(username);
    _socketService.sendMessage(
        SocketEvent.BAN_PLAYER, {'roomId': this.roomId, 'username': username});
    notifyListeners();
  }

  void toggleRoomLock() {
    _socketService.sendMessage(SocketEvent.TOGGLE_ROOM_LOCK, this.roomId);
  }

  void userLeft(String roomId, dynamic event) {
    _socketService.sendMessage(event, roomId);
  }

  void deleteRoom(String roomId) {
    _socketService.sendMessage(SocketEvent.HOST_LEFT, roomId);
  }

  void disconnect() {
    _socketService.disconnect();
  }

  void cancelListeners() {
    _socketService.clearAllListeners();
  }

  // void onNewPlayer(Function(dynamic) callback) {
  //   _socketService.onMessage(SocketEvent.NEW_PLAYER, callback);
  // }

  void onRemovedPlayer(Function(dynamic) callback) {
    _socketService.onMessage(SocketEvent.REMOVED_PLAYER, (username) {
      print('REMOVED PLAYER CALLED');
      this.removePlayer(username);
    });
  }

  void onStartGame(Function(dynamic) callback) {
    _socketService.onMessage(SocketEvent.START, callback);
  }

  void sendStartSignals() {
    _socketService
        .sendMessage(SocketEvent.START, {'roomId': this.roomId, 'time': 5});
    notifyListeners();
  }

  void sendCreateTeam() {
    this._socketService.sendMessage(SocketEvent.CREATE_TEAM, this.roomId);
  }

  void joinTeam(int newTeamId) {
    JoinTeamData joinTeamData =
        JoinTeamData(roomId: roomId, newTeamId: newTeamId);
    this
        ._socketService
        .sendMessage(SocketEvent.JOIN_TEAM, joinTeamData.toJson());
  }

  void removePlayer(String username) {
    players.remove(username);
    notifyListeners();
  }

  void gatherPlayers() {
    _socketService.sendMessageWithAck(SocketEvent.GET_GAME_TYPE, this.roomId,
        (gameType) => {this.gameType = gameType});

    _socketService.sendMessageWithAck(
        SocketEvent.GATHER_PLAYERS_USERNAME, this.roomId, (dynamic players) {
      this.players = List<String>.from(players);
    });
  }

  String _handleJoiningRoomValidation(bool isLocked) {
    if (isLocked) {
      return 'Room is locked, cannot join';
    } else {
      return 'Successfully joined the room';
    }
  }

  void configureBaseSocketFeatures() {
    handleNewPlayer();
    handleRemovedFromGame();
    handleRemovedPlayer();
    handleTime();
    handleFinalTransition();
    handleGetTeams();
  }

  void handleNewPlayer() {
    _socketService.onMessage(SocketEvent.NEW_PLAYER, (players) {
      this.players = List<String>.from(players);
      notifyListeners();
    });
  }

  void handleRemovedFromGame() {
    _socketService.onMessage(SocketEvent.REMOVED_FROM_GAME, (_) {
      _globalNavigationService.navigateTo('/home');
    });
  }

  void handleRemovedPlayer() {
    _socketService.onMessage(SocketEvent.REMOVED_PLAYER, (username) {
      if (players.contains(username)) {
        removePlayer(username);
      }
    });
  }

  void handleTime() {
    _socketService.onMessage(SocketEvent.TIME, (data) {
      this.time = data;
      if (time == 0) {
        this.isGameStarting = true;
        this._globalNavigationService.navigateTo('/game');
      } else if (time > 0) {
        this.isTransition = true;
      }
      notifyListeners();
    });
  }

  void handleFinalTransition() {
    this._socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION, (_) {
      if (this.isTransition) {
        this._globalNavigationService.navigateTo('/home');
      }
    });
  }

  void handleGetTeams() {
    this._socketService.onMessage(SocketEvent.GET_TEAMS, (teams) {
      this.teams.clear();
      teams.forEach((teamId, teamData) {
        print('${teamId} ${teamData['members']}');
        List<String> members = List<String>.from(teamData['members']);
        this.teams[int.parse(teamId)] = members;
      });
      this.teamsForInterface.clear();
      this.teamsForInterface = this.teams.entries.map((entry) {
        return TeamsForInterface(entry.key, entry.value);
      }).toList();

      print('\nTeams For Interface:');
      for (var team in teamsForInterface) {
        print('Team ${team.name}: ${team.userIds}');
      }
      notifyListeners();
    });
  }
}
