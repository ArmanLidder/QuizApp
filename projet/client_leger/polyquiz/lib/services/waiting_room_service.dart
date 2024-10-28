import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'socket_service.dart';
import 'package:polyquiz/constants/socket-event.dart';

class WaitingRoomService extends ChangeNotifier {
  static final WaitingRoomService _instance = WaitingRoomService._internal();
  final SocketService _socketService =
      SocketService(); // Use the SocketService instance
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();

  int roomId = 0;
  bool isRoomLocked = false;
  bool isGameStarting = false;
  bool isTransition = false;
  List<String> players = [];
  num time = 0;

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
  }

  bool isSocketAlive() {
    return _socketService.isSocketAlive();
  }

  Future<void> connectToSocket(String roomId,
      {required bool isHost, String? username}) async {
    if (!_socketService.isSocketAlive()) {
      print("Socket is not connected. Attempting to connect...");
      _socketService.connect();
    }

    _socketService.onMessage(SocketEvent.CONNECTION, (_) {
      print('Connected to WebSocket');
      if (username != null && isHost == false) {
        sendJoinRoomRequest(roomId, username);
      }
    });
  }

  Future<String> createRoom(String quizId) async {
    final completer = Completer<String>();
    print('Creating room for quiz: $quizId');

    if (!isSocketAlive()) {
      print("Socket is not connected. Attempting to connect...");
      await connectToSocket("roomId", isHost: true);
    }

    _socketService.sendMessageWithAck(SocketEvent.CREATE_ROOM, quizId,
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
    print('RoomId sent: ${this.roomId}');
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
    _socketService.onMessage(SocketEvent.REMOVED_PLAYER, callback);
  }

  void onStartGame(Function(dynamic) callback) {
    _socketService.onMessage(SocketEvent.START, callback);
  }

  void sendStartSignals() {
    _socketService
        .sendMessage(SocketEvent.START, {'roomId': this.roomId, 'time': 5});
    notifyListeners();
  }

  void removePlayer(String username) {
    players.remove(username);
  }

  void gatherPlayers() {
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
}
