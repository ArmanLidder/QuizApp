import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/real_game_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';
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
  String? newPlayerName;
  bool showPopup = false;
  WaitingRoomService waitingRoomService = WaitingRoomService();
  RealGameService realGameService = RealGameService();
  Map get text => TranslationService.instance.text;
  Map get waitRoomText => text['WAITING_ROOM_PAGE'];

  String get roomState => waitRoomText['ROOM_STATUS'] + " " + roomStateSuffix;
  String get roomStateSuffix => waitRoomText[isRoomLocked ? 'STATUS_LOCKED' : 'STATUS_UNLOCKED'];

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
      appBar: AppBar(
        title: Text(waitRoomText['TITLE']),
        automaticallyImplyLeading: false,
      ),
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
              Text(waitRoomText['TITLE'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(height: 20.0),
              Text('${waitRoomText['ROOM_CODE']}: $roomId', style: TextStyle(fontSize: 18)),
              if (widget.isHost)
                SwitchListTile(
                  title: Text(roomState, style: TextStyle(fontSize: 18)),
                  value: isRoomLocked,
                  contentPadding: EdgeInsets.symmetric(horizontal: 220),
                  activeColor: Color.fromRGBO(255, 255, 255, 1),
                  inactiveThumbColor: Color.fromRGBO(255, 255, 255, 1),
                  activeTrackColor: Color.fromRGBO(53, 121, 246, 1),
                  inactiveTrackColor: Color.fromRGBO(217, 217, 218, 1),
                  onChanged: !this.waitingRoomService.isTransition
                      ? (bool value) => _toggleRoomLock()
                      : null,
                ),
              SizedBox(height: 20.0),
              Text(waitRoomText['PLAYERS_TITLE'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Expanded(
                child: AnimatedBuilder(
                    animation: waitingRoomService,
                    builder: (BuildContext context, Widget? snapshot) {
                      return ListView.builder(
                        itemCount: waitingRoomService.players.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              SmartAvatar(
                                  userId: waitingRoomService.players[index],
                                  size: 60,
                                  hasName: true),
                              if (widget.isHost)
                                IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: Color.fromRGBO(246, 53, 53, 1),
                                      size: 28.0,
                                    ),
                                    onPressed: !this
                                            .waitingRoomService
                                            .isTransition
                                        ? () =>
                                            waitingRoomService.sendBanPlayer(
                                              waitingRoomService.players[index],
                                            )
                                        : null),
                            ],
                          );
                        },
                      );
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.isHost && !waitingRoomService.isTransition)
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            (waitingRoomService.players.length >= 1 &&
                                    isRoomLocked)
                                ? Color.fromRGBO(53, 121, 246, 1)
                                : Color.fromRGBO(200, 200, 200, 1),
                      ),
                      onPressed:
                          waitingRoomService.players.length >= 1 && isRoomLocked
                              ? () => setState(() {
                                    this.waitingRoomService.isTransition = true;
                                    waitingRoomService.sendStartSignals();
                                  })
                              : null,
                      child: Text(waitRoomText['START_BUTTON'],
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.normal)),
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
            ],
          ),
        ),
        Positioned(bottom: 20, left: 20, child: ChatPopup())
      ]),
    );
  }
}
