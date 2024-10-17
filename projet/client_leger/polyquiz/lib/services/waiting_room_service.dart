import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WaitingRoomService {
  static IO.Socket? socket;

  static bool isSocketAlive() {
    return socket != null && socket!.connected;
  }

  static Future<void> connectToSocket(String roomId, {required bool isHost, String? username}) async {
    socket = IO.io('http://192.168.56.1:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('connect', (_) {
      print('Connected to WebSocket');
      if(username != null) {
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
  }

  static void startGame(String roomId) {
    socket?.emit('startGame', {'roomId': roomId});
  }

  static void toggleRoomLock(String roomId, bool isLocked) {
    socket?.emit('toggleLock', {'roomId': roomId, 'locked': isLocked});
  }

  static Future<void> deleteRoom(String roomId) async {
    print('Attempting to delete room: $roomId');
    socket?.emit('hostAbandonnement', {'roomId': roomId});
  }


  static Future<String> createRoom(String quizId) async {
    final completer = Completer<String>();
    print('Creating room for quiz: $quizId');

    socket?.emitWithAck('createRoom', quizId, ack: (roomCode) {
      if (roomCode != null) {
        print("Room created with ID: $roomCode");
        completer.complete(roomCode.toString());
      } else {
        print('Failed to create room');
        completer.completeError('Failed to create room');
      }
    });

    return completer.future;
  }

  // Function to join a room, with a callback for the join process
  static Future<String> sendJoinRoomRequest(String roomId, String username) async {
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
  static String _handleJoiningRoomValidation(bool isLocked) {
    return isLocked ? 'Room is locked, cannot join at this time.' : 'Successfully joined the room!';
  }


  static void disconnect() {
    socket?.disconnect();
  }

  static void updateRoomLockStatus(String roomId, bool isLocked) {
    // Update the lock status in your backend
    // Your implementation here
  }
}
