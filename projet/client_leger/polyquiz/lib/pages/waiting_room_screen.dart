import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/real_game_service.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/fancyAppBar.dart';
import '../services/waiting_room_service.dart';
import '../models/quiz.dart';
import 'package:polyquiz/constants/socket-event.dart';

class WaitingRoomScreen extends StatefulWidget {
  final Quiz quiz;
  final bool isHost;
  final String? username;
  final GameConfigService? gameConfigService;
  final bool? isFromActiveList;

  const WaitingRoomScreen(
      {Key? key,
      required this.quiz,
      required this.isHost,
      this.username,
      this.gameConfigService,
      this.isFromActiveList})
      : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  String roomId = "nothing";
  String username = "nothing";
  bool isRoomLocked = false;
  bool isGameStarting = false;
  String roomState = "La salle est ouverte";
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
    // waitingRoomService.cancelListeners();
    // waitingRoomService.disconnect();
    waitingRoomService.players = [];
    super.dispose();
  }

  Future<void> _initRoom() async {
    try {
      print(widget.isHost);
      if (widget.isHost) {
        print(widget.gameConfigService!.getGameConfig());
        roomId = await waitingRoomService.createRoom(
            widget.quiz.id, widget.gameConfigService!.getGameConfig());
        realGameService.username = 'host';
        realGameService.roomId = waitingRoomService.roomId;
      } else {
        roomId = widget.quiz.id;
        username = widget.username ?? 'nothing';
        waitingRoomService.roomId = int.parse(roomId);
        realGameService.username = username;
        waitingRoomService.gatherPlayers();
        realGameService.roomId = int.parse(roomId);

        print('Joining room $roomId as $username');
      }
      if (username == 'nothing') {
        print('isHost : username is nothing');
      } else {
        waitingRoomService.connectToSocket(roomId,
            isHost: widget.isHost,
            username: username,
            isFromActiveList: widget.isFromActiveList);
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
      roomState = roomState == "La salle est ouverte"
          ? "La salle est verrouillée"
          : "La salle est ouverte";
      print(roomState);
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
      appBar: FancyAppBar(context: context),
      body: Stack(children: [
        Container(
          margin: EdgeInsets.all(50.0),
          padding: EdgeInsets.all(40.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(248, 249, 250, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                )
              ]),
          child: Column(
            children: [
              Text("Salle d'attente",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(height: 20.0),
              Text('Code : $roomId', style: TextStyle(fontSize: 18)),
              if (widget.isHost)
                SwitchListTile(
                  title: Text(roomState, style: TextStyle(fontSize: 18)),
                  value: isRoomLocked,
                  contentPadding: EdgeInsets.symmetric(horizontal: 220),
                  activeColor: Color.fromRGBO(255, 255, 255, 1),
                  inactiveThumbColor: Color.fromRGBO(255, 255, 255, 1),
                  activeTrackColor: Color.fromRGBO(53, 121, 246, 1),
                  inactiveTrackColor: Color.fromRGBO(217, 217, 218, 1),
                  onChanged: (bool value) => _toggleRoomLock(),
                ),
              SizedBox(height: 20.0),
              Text('Joueurs:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Color.fromRGBO(246, 53, 53, 1),
                                        size: 28.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.isHost && !waitingRoomService.isTransition)
                    ElevatedButton(
                      onPressed:
                          waitingRoomService.players.length >= 1 && isRoomLocked
                              ? () => setState(() {
                                    this.waitingRoomService.isTransition = true;
                                    waitingRoomService.sendStartSignals();
                                  })
                              : null,
                      child: Text('Commencer'),
                    ),
                  QuitBtn(
                      isHost: widget.isHost, roomId: waitingRoomService.roomId),
                ],
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
        ),
        Positioned(bottom: 20, left: 20, child: ChatPopup())
      ]),
    );
  }
}
