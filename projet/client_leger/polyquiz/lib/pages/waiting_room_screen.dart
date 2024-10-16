import 'dart:ffi';
import 'package:flutter/material.dart';
import '../services/waiting_room_service.dart';
import '../models/quiz.dart';

class WaitingRoomScreen extends StatefulWidget {
  final Quiz quiz;
  final bool isHost;

  const WaitingRoomScreen({Key? key, required this.quiz, required this.isHost}) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  List<String> players = [];
  String roomId = "nothing";
  bool isRoomLocked = false;
  bool isGameStarting = false;
  String? newPlayerName;
  bool showPopup = false;

  @override
  void initState() {
    super.initState();
    _initRoom();
  }

  @override
  void dispose() {
    _leaveRoom();
    WaitingRoomService.disconnect();
    super.dispose();
  }

  Future<void> _initRoom() async {
    try {
      if (widget.isHost) {
        roomId = await WaitingRoomService.createRoom(widget.quiz.id);
      } else {
        roomId = widget.quiz.id;
        WaitingRoomService.joinRoom(roomId);
      }
      WaitingRoomService.connectToSocket(roomId, isHost: widget.isHost);
      _configureSocketListeners();
      setState(() {});
    } catch (e) {
      print('Error initializing room: $e');
    }
  }

  void _configureSocketListeners() {
    WaitingRoomService.socket?.on('newPlayer', (data) {
        if (data is List) {
          newPlayerName = data.last; 
          setState(() {
            players.add(newPlayerName!);
            showPopup = true;
          });
        } else {
          print('Unexpected data format: $data');
        }
      });

    WaitingRoomService.socket?.on('removedPlayer', (username) {
    if (username is String) {
      setState(() {
        players.remove(username);
      });
    } else {
      print('Unexpected data format for playerLeft: $username');
    }
  });

    WaitingRoomService.socket?.on('startGame', (_) {
      setState(() {
        isGameStarting = true;
      });
      _startGame();
    });
  }

  void _toggleRoomLock() {
    setState(() {
      isRoomLocked = !isRoomLocked;
    });
    WaitingRoomService.toggleRoomLock(roomId, isRoomLocked);
    WaitingRoomService.updateRoomLockStatus(roomId, isRoomLocked);
  }

  void _banPlayer(String username) {
    setState(() {
      players.remove(username);
    });
  }

  void _leaveRoom() {
    final event = widget.isHost ? 'hostLeft' : 'playerLeft';
    WaitingRoomService.socket?.emit(event, {'roomId': roomId});
    if(widget.isHost) {
      WaitingRoomService.deleteRoom(roomId);
    }
    WaitingRoomService.disconnect();
  }

  void _startGame() {
    if (widget.isHost) {
      WaitingRoomService.startGame(roomId);
    }
    Navigator.pushNamed(context, '/gameScreen', arguments: roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Waiting Room')),
      body: Column(
        children: [
          Text('Room ID: $roomId'),
          if (widget.isHost)
            SwitchListTile(
              title: Text('Lock Room'),
              value: isRoomLocked,
              onChanged: (bool value) => _toggleRoomLock(),
            ),
          Text('Players:'),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(players[index]),
                  trailing: widget.isHost
                      ? IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _banPlayer(players[index]),
                        )
                      : null,
                );
              },
            ),
          ),
          if (widget.isHost)
            ElevatedButton(
              onPressed: _startGame,
              child: Text('Start Game'),
            ),
          if (widget.isHost)
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white),
              ),
              onPressed: _leaveRoom,
            ),
          if (showPopup && newPlayerName != null)
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'The player $newPlayerName has joined the room',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
