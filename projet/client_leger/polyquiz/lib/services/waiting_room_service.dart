import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WaitingRoomService {
  static IO.Socket? socket;

  static bool isSocketAlive() {
    return socket != null && socket!.connected;
  }

  static Future<void> connectToSocket(String roomId, {required bool isHost}) async {
    socket = IO.io('http://192.168.56.1:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('connect', (_) {
      print('Connected to WebSocket');
      joinRoom(roomId);
    });

    WaitingRoomService.socket?.on('disconnect', (_) {
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
    
  // final completer = Completer<void>();
  print('Attempting to delete room: $roomId');

  socket?.emit('hostAbandonnement', {'roomId': roomId});

  // socket?.emitWithAck('hostAbandonnement', roomId, ack: (success) {
  //   print('showing the log: $success');
  //   if (success == true) {
  //     print("Room deleted successfully for ID: $roomId");
  //     completer.complete();
  //   } else {
  //     print('Failed to delete room');
  //     completer.completeError('Failed to delete room');
  //   }
  // });

  // return completer.future;
}


  static Future<String> createRoom(String quizId) async {
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
      } else {
        print('Failed to create room');
        completer.completeError('Failed to create room');
      }
    });

    return completer.future;
  }

  static void joinRoom(String roomId) {
    if (isSocketAlive()) {
      socket?.emit('joinRoom', {'roomId': roomId});
    } else {
      print('Socket is not connected, cannot join room');
    }
  }


  static void disconnect() {
    socket?.disconnect();
  }

  static void updateRoomLockStatus(String roomId, bool isLocked) {
    // Update the lock status in your backend
    // Your implementation here
  }
}
