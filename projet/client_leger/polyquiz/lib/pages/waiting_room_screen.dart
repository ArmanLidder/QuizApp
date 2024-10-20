import 'dart:ffi';
import 'dart:async';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter/material.dart';
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
  List<String> players = [];
  String roomId = "nothing";
  String username = "nothing";
  bool isRoomLocked = false;
  bool isGameStarting = false;
  String? newPlayerName;
  bool showPopup = false;
  WaitingRoomService waitingRoomService = WaitingRoomService();

  @override
  void initState() {
    super.initState();
    waitingRoomService.setUpService();
    _initRoom();
  }

  @override
  void dispose() {
    _leaveRoom();
    waitingRoomService.cancelListeners();
    waitingRoomService.disconnect();
    super.dispose();
  }

  Future<void> _initRoom() async {
    try {
      
      if (widget.isHost) {
        roomId = await waitingRoomService.createRoom(widget.quiz.id);
        // WaitingRoomService.connectToSocket(roomId, isHost: widget.isHost);
      } else {
        roomId = widget.quiz.id;
        username = widget.username ?? 'nothing';
        print('Joining room $roomId as $username');
      }
      if (username == 'nothing') {
        print('isHost : username is nothing');
      } else {
        waitingRoomService.connectToSocket(roomId,
            isHost: widget.isHost, username: username);
      }
      _configureSocketListeners();
      setState(() {});
    } catch (e) {
      print('Error initializing room: $e');
    }
  }

  void _configureSocketListeners() {
    final waitingRoomService = WaitingRoomService();

    waitingRoomService.onNewPlayer((data) {
      if (mounted) {
        if (data is List) {
          newPlayerName = data.last;
          setState(() {
            players.add(newPlayerName!);
            showPopup = true;
          });
        } else {
          print('Unexpected data format: $data');
        }
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              showPopup = false;
            });
          }
        });
      }
    });

    waitingRoomService.onRemovedPlayer((username) {
      if (username is String) {
        setState(() {
          players.remove(username);
        });
      } else {
        print('Unexpected data format for playerLeft: $username');
      }
    });

    // Uncomment and use if needed
    // waitingRoomService.onStartGame((_) {
    //   setState(() {
    //     isGameStarting = true;
    //   });
    // });
  }

  void _toggleRoomLock() {
    setState(() {
      isRoomLocked = !isRoomLocked;
    });
    waitingRoomService.toggleRoomLock(roomId);
    waitingRoomService.updateRoomLockStatus(roomId, isRoomLocked);
  }

  void _banPlayer(String username) {
    setState(() {
      players.remove(username);
    });
  }

  void _leaveRoom() {
    if (widget.isHost) {
      print('Host left Deleting room $roomId');
      waitingRoomService.deleteRoom(roomId);
    }
    else {
      print('Player left');
      waitingRoomService.userLeft(roomId, SocketEvent.PLAYER_LEFT);
    }
  }

  // void _startGame() {
  //   if (widget.isHost) {
  //     waitingRoomService.startGame();
  //   }
  //   Navigator.pushNamed(context, '/gameScreen', arguments: roomId);
  // }

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
          if (widget.isHost && !waitingRoomService.isTransition)
            ElevatedButton(
              onPressed: players.length >= 1 && isRoomLocked
                  ? () => setState(() {
                        this.waitingRoomService.isTransition = true;
                        waitingRoomService.sendStartSignals();
                      })
                  : null,
              child: Text('Start Game'),
            ),
          if (widget.isHost && waitingRoomService.isTransition)
            AnimatedBuilder(
                animation: waitingRoomService,
                builder: (BuildContext context, Widget? snapshot) {
                  return Text(
                      'Game starts in: ${waitingRoomService.time} second(s)');
                }),
          // Countdown(
          //   seconds: 5, // Set the countdown duration here
          //   build: (BuildContext context, double time) => Text(
          //     'Starting in: ${time.toStringAsFixed(0)} seconds',
          //     style: TextStyle(fontSize: 18),
          //   ),
          //   interval: Duration(seconds: 1),
          //   onFinished: () {
          //     print('Countdown is done!');
          //   },
          // ),
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
