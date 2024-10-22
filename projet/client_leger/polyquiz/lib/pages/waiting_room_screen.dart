import 'dart:ffi';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/real_game_service.dart';
import '../services/waiting_room_service.dart';
import '../models/quiz.dart';
import 'package:polyquiz/constants/socket-event.dart';

class WaitingRoomScreen extends StatefulWidget {
  final Quiz quiz;
  final bool isHost;
  final String? username;

  const WaitingRoomScreen(
      {Key? key, required this.quiz, required this.isHost, this.username})
      : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  String roomId = "nothing";
  String username = "nothing";
  bool isRoomLocked = false;
  bool isGameStarting = false;
  String? newPlayerName;
  bool showPopup = false;
  WaitingRoomService waitingRoomService = WaitingRoomService();
  RealGameService realGameService = RealGameService();

  @override
  void initState() {
    super.initState();
    waitingRoomService.setUpService();
    _initRoom();
  }

  @override
  void dispose() {
    //_leaveRoom();
    waitingRoomService.cancelListeners();
    // waitingRoomService.disconnect();
    super.dispose();
  }

  Future<void> _initRoom() async {
    try {
      if (widget.isHost) {
        roomId = await waitingRoomService.createRoom(widget.quiz.id);
        realGameService.username = 'host';
        realGameService.roomId = waitingRoomService.roomId;
      } else {
        roomId = widget.quiz.id;
        username = widget.username ?? 'nothing';
        realGameService.username = username;
        waitingRoomService.gatherPlayers();
        realGameService.roomId = int.parse(roomId);
        print('Joining room $roomId as $username');
      }
      if (username == 'nothing') {
        print('isHost : username is nothing');
      } else {
        waitingRoomService.connectToSocket(roomId,
            isHost: widget.isHost, username: username);
      }
      waitingRoomService.configureBaseSocketFeatures();
      setState(() {});
    } catch (e) {
      print('Error initializing room: $e');
    }
  }

  void _toggleRoomLock() {
    setState(() {
      isRoomLocked = !isRoomLocked;
    });
    waitingRoomService.toggleRoomLock();
  }

  void _leaveRoom() {
    if (widget.isHost) {
      print('Host left Deleting room $roomId');
      waitingRoomService.deleteRoom(roomId);
    } else {
      print('Player left');
      waitingRoomService.userLeft(roomId, SocketEvent.PLAYER_LEFT);
    }
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
            child: AnimatedBuilder(
                animation: waitingRoomService,
                builder: (BuildContext context, Widget? snapshot) {
                  return ListView.builder(
                    itemCount: waitingRoomService.players.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(waitingRoomService.players[index]),
                        trailing: widget.isHost
                            ? IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () => {
                                  waitingRoomService.sendBanPlayer(
                                      waitingRoomService.players[index])
                                },
                              )
                            : null,
                      );
                    },
                  );
                }),
          ),
          if (widget.isHost && !waitingRoomService.isTransition)
            ElevatedButton(
              onPressed: waitingRoomService.players.length >= 1 && isRoomLocked
                  ? () => setState(() {
                        this.waitingRoomService.isTransition = true;
                        waitingRoomService.sendStartSignals();
                      })
                  : null,
              child: Text('Start Game'),
            ),
          AnimatedBuilder(
              animation: waitingRoomService,
              builder: (BuildContext context, Widget? snapshot) {
                return Visibility(
                  visible: waitingRoomService.isTransition,
                  child: Text(
                      'Game starts in: ${waitingRoomService.time} second(s)'),
                );
              }),
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
