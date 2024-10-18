import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WaitingRoomService extends ChangeNotifier {
  static final WaitingRoomService _instance = WaitingRoomService._internal();
  IO.Socket? socket;

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
    return socket != null && socket!.connected;
  }

  Future<void> connectToSocket(String roomId,
      {required bool isHost, String? username}) async {
    socket = IO.io('http://192.168.68.103:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('connect', (_) {
      print('Connected to WebSocket');
      if (username != null && isHost == false) {
        sendJoinRoomRequest(roomId, username);
      }
    });

    socket?.on('disconnect', (_) {
      print('Disconnected from WebSocket');
      if (isHost) {
        print('Host disconnected, deleting room...');
        deleteRoom(roomId);
      }
    });

    socket?.on('newPlayer', (data) {
      print('New player joined: $data');
    });

    socket?.on('removedPlayer', (data) {
      print('Player left: $data');
    });

    socket?.on('time', (data) {
      this.time = data;
      print('on time data: ${this.time}');
      notifyListeners();
      if (time == 0) {
        this.isGameStarting = true;
        //navigatorKey.currentState?.pushNamed('/nextPage', arguments: data);
      }
    });
  }

  void sendStartSignals() {
    socket?.emit('start', {'roomId': this.roomId, 'time': 5});
    notifyListeners();
  }

  void toggleRoomLock(num roomId) {
    socket?.emit('toggleRoomRock', roomId);
  }

  Future<void> deleteRoom(String roomId) async {
    print('Attempting to delete room: $roomId');
    socket?.emit('hostAbandonnement', {'roomId': roomId});
  }

  Future<String> createRoom(String quizId) async {
    final completer = Completer<String>();
    print('Creating room for quiz: $quizId');

    if (!isSocketAlive()) {
      print("Socket is not connected. Attempting to connect...");
      await connectToSocket("roomId", isHost: true);
    }

    socket?.emitWithAck('createRoom', quizId, ack: (roomCode) {
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

  // Function to join a room, with a callback for the join process
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

    socket?.emitWithAck('playerJoin', usernameData, ack: (isLocked) {
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

  // Helper function to validate if the room is locked
  String _handleJoiningRoomValidation(bool isLocked) {
    return isLocked
        ? 'Room is locked, cannot join at this time.'
        : 'Successfully joined the room!';
  }

  void disconnect() {
    socket?.disconnect();
  }

  void updateRoomLockStatus(String roomId, bool isLocked) {
    // Update the lock status in your backend
    // Your implementation here
  }
}
