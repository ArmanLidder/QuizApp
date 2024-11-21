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
  bool isGameStarting = false;
  String? newPlayerName;
  bool showPopup = false;
  WaitingRoomService waitingRoomService = WaitingRoomService();
  RealGameService realGameService = RealGameService();
  Map get text => TranslationService.instance.text;
  Map get waitRoomText => text['WAITING_ROOM_PAGE'];

  String get roomState => waitRoomText['ROOM_STATUS'] + " " + roomStateSuffix;
  String get roomStateSuffix =>
      waitRoomText[this.waitingRoomService.isRoomLocked
          ? 'STATUS_LOCKED'
          : 'STATUS_UNLOCKED'];

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
    if(!waitingRoomService.isTransition) {
      if (widget.isHost) {
          this.waitingRoomService.userLeft(roomId, SocketEvent.HOST_LEFT);
          this.waitingRoomService.deleteRoom(roomId);
      }
      else{
          this.waitingRoomService.userLeft(roomId, SocketEvent.PLAYER_LEFT);
      }
    }
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
        setState(() {
          waitingRoomService.gameType = widget.gameConfigService!.gameType;
        });
      } else {
        roomId = widget.quiz.id;
        username = widget.username ?? 'nothing';
        waitingRoomService.roomId = int.parse(roomId);
        realGameService.username = username;
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

        if (!widget.isHost) {
          waitingRoomService.gatherPlayers();
          print(
              'waiting room player game type: ${waitingRoomService.gameType}');
        }
      }
      waitingRoomService.configureBaseSocketFeatures();
      setState(() {});
    } catch (e) {
      print('Error initializing room: $e');
    }
  }

  void _toggleRoomLock() {
    setState(() {
      this.waitingRoomService.isRoomLocked =
          !this.waitingRoomService.isRoomLocked;
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

  bool onlyOneMember() {
    bool result = false;
    this.waitingRoomService.teamsForInterface.forEach((team) {
      if (team.userIds.contains(this.username) && team.userIds.length < 2) {
        result = true;
      }
    });
    return result;
  }

  bool validationBeforeEntry() {
    if (this.waitingRoomService.gameType == 'classic') {
      return this.waitingRoomService.players.length == 0 ||
          !this.waitingRoomService.isRoomLocked;
    }

    int moreThanTwoMembers = 0;

    this.waitingRoomService.teamsForInterface.forEach((team) {
      if (team.userIds.length > 1) {
        moreThanTwoMembers += 1;
      }
    });

    return moreThanTwoMembers < 1 ||
        this.waitingRoomService.teams.length < 1 ||
        !this.waitingRoomService.isRoomLocked;
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
              Text('${waitRoomText['ROOM_CODE']}: $roomId',
                  style: TextStyle(fontSize: 18)),
              if (widget.isHost)
                SwitchListTile(
                  title: Text(roomState, style: TextStyle(fontSize: 18)),
                  value: this.waitingRoomService.isRoomLocked,
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
              AnimatedBuilder(
                animation: waitingRoomService,
                builder: (BuildContext context, Widget? snapshot) {
                  return Text(
                      waitingRoomService.gameType == 'classic'
                          ? waitRoomText['PLAYERS_TITLE']
                          : waitRoomText['TEAMS_TITLE'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: AnimatedBuilder(
                  animation: waitingRoomService,
                  builder: (BuildContext context, Widget? snapshot) {
                    return waitingRoomService.gameType == 'classic'
                        ? ListView.builder(
                            itemCount: waitingRoomService.players.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SmartAvatar(
                                          userId:
                                              waitingRoomService.players[index],
                                          size: 60,
                                          hasName: true,
                                        ),
                                        if (widget.isHost)
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color: Color.fromRGBO(
                                                  246, 53, 53, 1),
                                              size: 28.0,
                                            ),
                                            onPressed:
                                                !waitingRoomService.isTransition
                                                    ? () => waitingRoomService
                                                            .sendBanPlayer(
                                                          waitingRoomService
                                                              .players[index],
                                                        )
                                                    : null,
                                          )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10)
                                ],
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount:
                                waitingRoomService.teamsForInterface.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${waitRoomText['TEAM_LABEL']} ${index + 1}',
                                      ),
                                      if (waitingRoomService
                                                  .teamsForInterface[index]
                                                  .userIds
                                                  .length ==
                                              1 &&
                                          !widget.isHost &&
                                          waitingRoomService
                                                  .teamsForInterface[index]
                                                  .userIds[0] !=
                                              username)
                                        TextButton(
                                            style: TextButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                    53, 121, 246, 1)),
                                            onPressed: () {
                                              waitingRoomService.joinTeam(
                                                  waitingRoomService
                                                      .teamsForInterface[index]
                                                      .name);
                                            },
                                            child: Text(
                                                waitRoomText['JOIN_TEAM'],
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal))),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (int i = 0;
                                            i <
                                                waitingRoomService
                                                    .teamsForInterface[index]
                                                    .userIds
                                                    .length;
                                            i++)
                                          Column(
                                            children: [
                                              SmartAvatar(
                                                userId: waitingRoomService
                                                    .teamsForInterface[index]
                                                    .userIds[i],
                                                size: 60,
                                                hasName: true,
                                              ),
                                              if (widget.isHost)
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove_circle_outline,
                                                    color: Color.fromRGBO(
                                                        246, 53, 53, 1),
                                                    size: 28.0,
                                                  ),
                                                  onPressed: !waitingRoomService
                                                          .isTransition
                                                      ? () => waitingRoomService
                                                              .sendBanPlayer(
                                                            waitingRoomService
                                                                .players[i],
                                                          )
                                                      : null,
                                                )
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10)
                                ],
                              );
                            },
                          );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.isHost && !waitingRoomService.isTransition)
                    AnimatedBuilder(
                        animation: waitingRoomService,
                        builder: (BuildContext context, Widget? snapshot) {
                          return TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: (!this.validationBeforeEntry())
                                  ? Color.fromRGBO(53, 121, 246, 1)
                                  : Color.fromRGBO(200, 200, 200, 1),
                            ),
                            onPressed: !this.validationBeforeEntry()
                                ? () => setState(() {
                                      this.waitingRoomService.isTransition =
                                          true;
                                      waitingRoomService.sendStartSignals();
                                    })
                                : null,
                            child: Text(waitRoomText['START_BUTTON'],
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal)),
                          );
                        }),
                  if (!widget.isHost)
                    AnimatedBuilder(
                        animation: waitingRoomService,
                        builder: (BuildContext context, Widget? snapshot) {
                          return waitingRoomService.gameType == 'classic'
                              ? SizedBox.shrink()
                              : TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: (!this.onlyOneMember())
                                        ? Color.fromRGBO(53, 121, 246, 1)
                                        : Color.fromRGBO(200, 200, 200, 1),
                                  ),
                                  onPressed: this.onlyOneMember() == true
                                      ? null
                                      : () {
                                          waitingRoomService.sendCreateTeam();
                                        },
                                  child: Text(waitRoomText['CREATE_TEAM'],
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)));
                        }),
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
