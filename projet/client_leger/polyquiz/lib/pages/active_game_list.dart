import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/main.dart';
import 'package:polyquiz/pages/game_page.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/fancyAppBar.dart';
import 'package:polyquiz/widgets/game_widgets/active_game_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/cancel_btn.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_list_item.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/services/room_validation_service.dart';
import 'package:polyquiz/services/snack_bar_service.dart';
import 'package:polyquiz/services/waiting_room_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'waiting_room_screen.dart';
import '../models/quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveGameListComponent extends StatefulWidget {
  ActiveGameListComponent({Key? key}) : super(key: key);

  @override
  _ActiveGameListComponentState createState() =>
      _ActiveGameListComponentState();
}

class _ActiveGameListComponentState extends State<ActiveGameListComponent> {
  late Future<void> _initializeFuture;
  Map<String, String> quizNameMap = {};
  WaitingRoomService waitingRoomService = WaitingRoomService();
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();
  GameService gameService = GameService();
  final UserService userService = UserService();
  bool _isJoining = false;
  late final GameListService gameListService;
  ThemeService themeService = ThemeService.instance;
  Map get text => TranslationService.instance.text;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map get activeText => text['ACTIVE_GAME_LIST'];

  @override
  void initState() {
    super.initState();
    gameListService = Provider.of<GameListService>(context, listen: false);
    _initializeFuture = _initialize();
  }

  Future<void> _initialize() async {
    final gameListService =
        Provider.of<GameListService>(context, listen: false);
    await gameListService.initialize();
    _prefetchQuizNames();
  }

  void _prefetchQuizNames() {
    final gameListService =
        Provider.of<GameListService>(context, listen: false);
    final quizService = Provider.of<QuizService>(context, listen: false);

    gameListService.games$.listen((games) {
      print('GAMES:');
      print(games);
      games.forEach((game) {
        print('game info: ${game}');
      });
      games.where((game) => !game.private).forEach((game) {
        quizService.basicGetById(game.quizId).then((quiz) {
          setState(() {
            quizNameMap[game.quizId] = quiz?.title ?? text['UNKNOWN'];
          });
        }).catchError((_) {
          setState(() {
            quizNameMap[game.quizId] = text['UNKNOWN'];
          });
        });
      });
    });
  }

  String _minimumPrestige(int prestige) {
    if (prestige >= 200) return '🏅'; // Platinum medal
    if (prestige >= 150) return '🥇'; // Gold medal
    if (prestige >= 100) return '🥈'; // Silver medal
    if (prestige >= 50) return '🥉'; // Bronze medal
    return '🚫'; // Default icon
  }

  Future<void> _joinRoom(GameListItem game) async {
    final roomValidationService =
        Provider.of<RoomValidationService>(context, listen: false);
    final snackbarService =
        Provider.of<SnackbarService>(context, listen: false);
    roomValidationService.reloadUserData();
    roomValidationService.roomId = game.room.toString();
    final isHostFriend = await _validateFriendship(game);
    dynamic dataOfRoomValidation = await roomValidationService.sendRoomId();
    if (!dataOfRoomValidation['isRoom']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(activeText['NO_GAMES_AVAILABLE'])),
      );
      setState(() {
        _isJoining = false;
      });
    } else {
      if (dataOfRoomValidation['isLocked']) {
        print('I am here 2');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(activeText['ROOM_LOCKED'])),
        );
        setState(() {
          _isJoining = false;
        });
      } else {
        if (game.friendsOnly && !isHostFriend) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(activeText['EXCLUSIVE_FRIENDS_GAME'])),
          );
        } else {
          final isPrestigeValid = await _validatePrestige(game.prestige);
          if (!isPrestigeValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(activeText['INSUFFICIENT_PRESTIGE'])),
            );
          } else {
            await roomValidationService.verifyUsername();
            if (!roomValidationService.isUsernameValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(activeText['USER_BANNED'])),
              );
            } else {
              if (roomValidationService.isLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(activeText['ROOM_LOCKED'])),
                );
              } else {
                if (game.price > 0) {
                  if (roomValidationService.userData!.currency < game.price) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(activeText['INSUFFICIENT_FUNDS'])),
                    );
                  } else {
                    final availableMoney =
                        roomValidationService.userData!.currency;
                    await _firestore
                        .collection('users')
                        .doc(roomValidationService.userData!.uid)
                        .update({
                      'currency': availableMoney - game.price,
                    });
                    if (!roomValidationService.isLocked &&
                        roomValidationService.isUsernameValid) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoomScreen(
                            quiz: Quiz(
                              id: roomValidationService
                                  .roomId!, // Pass the room ID to the waiting room.
                              title: 'Nothing', // Provide a sample title.
                              description:
                                  'Nothing', // Provide a sample description.
                              duration: 0, // Provide a sample duration.
                              questions: [], // Provide an empty list of questions.
                            ),
                            username: roomValidationService.userData!
                                .uid, // Pass the username to the waiting room.
                            isHost: false, // This user is not the host.
                            isFromActiveList: true,
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  if (!roomValidationService.isLocked &&
                      roomValidationService.isUsernameValid) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaitingRoomScreen(
                          quiz: Quiz(
                            id: roomValidationService
                                .roomId!, // Pass the room ID to the waiting room.
                            title: 'Nothing', // Provide a sample title.
                            description:
                                'Nothing', // Provide a sample description.
                            duration: 0, // Provide a sample duration.
                            questions: [], // Provide an empty list of questions.
                          ),
                          username: roomValidationService.userData!
                              .uid, // Pass the username to the waiting room.
                          isHost: false, // This user is not the host.
                          isFromActiveList: true,
                        ),
                      ),
                    );
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Future<bool> _validateFriendship(GameListItem game) async {
    final roomValidationService =
        Provider.of<RoomValidationService>(context, listen: false);
    final currentUserId = roomValidationService.userData!.uid;
    final hostProfile = await this.userService.getUserById(game.hostUserId);
    return hostProfile?.friends.contains(currentUserId) ?? false;
  }

  Future<bool> _validatePrestige(int prestige) async {
    final roomValidationService =
        Provider.of<RoomValidationService>(context, listen: false);

    final currentUserPrestige = roomValidationService.userData!.prestige;
    return currentUserPrestige >= prestige;
  }

  @override
  Widget build(BuildContext context) {
    final gameListService = Provider.of<GameListService>(context);

    return Scaffold(
      appBar: FancyAppBar(context: context),
      backgroundColor: themeService.mainBackground.value,
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/join');
                      },
                      child: Text(
                        text['PLAYER_WAITING_PAGE']['JOIN_PRIVATE_GAME'],
                        style: TextStyle(
                          color: themeService.secondaryAccent.value,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeService.secondaryBackground.value,
                      ),
                    ),
                  ),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
              Positioned(child: ChatPopup(), bottom: 20.0, left: 20.0)
            ]);
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/join');
                    },
                    child: Text(
                      text['PLAYER_WAITING_PAGE']['JOIN_PRIVATE_GAME'],
                      style: TextStyle(
                        color: themeService.secondaryAccent.value,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            themeService.secondaryBackground.value),
                  ),
                ),
                Center(child: Text('Error: ${snapshot.error}')),
              ],
            );
          } else {
            return StreamBuilder<List<GameListItem>>(
              stream: gameListService.games$,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/join');
                          },
                          child: Text(
                            text['PLAYER_WAITING_PAGE']['JOIN_PRIVATE_GAME'],
                            style: TextStyle(
                              color: themeService.secondaryAccent.value,
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                themeService.secondaryBackground.value,
                          ),
                        ),
                      ),
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/join');
                          },
                          child: Text(
                            text['PLAYER_WAITING_PAGE']['JOIN_PRIVATE_GAME'],
                            style: TextStyle(
                              color: themeService.secondaryAccent.value,
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                themeService.secondaryBackground.value,
                          ),
                        ),
                      ),
                      Center(child: Text('Error: ${snapshot.error}')),
                    ],
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Stack(children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/join');
                            },
                            child: Text(
                              text['PLAYER_WAITING_PAGE']['JOIN_PRIVATE_GAME'],
                              style: TextStyle(
                                color: themeService.secondaryAccent.value,
                                fontSize: 20,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  themeService.secondaryBackground.value,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          color: themeService
                                              .secondaryBackground.value),
                                      child: Center(
                                        child: Text(
                                          activeText['PUBLIC_GAME_LIST'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                              color: themeService
                                                  .secondaryAccent.value),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(activeText['NO_GAMES_AVAILABLE'],
                                  style: TextStyle(
                                      color: themeService.mainAccent.value)),
                              SizedBox(height: 100),
                              CancelBtn()
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(child: ChatPopup(), bottom: 20.0, left: 20.0)
                  ]);
                } else {
                  final games = snapshot.data!;
                  return Stack(children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/join');
                            },
                            child: Text(
                              text['PLAYER_WAITING_PAGE']['JOIN_PRIVATE_GAME'],
                              style: TextStyle(
                                color: themeService.secondaryAccent.value,
                                fontSize: 20,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  themeService.secondaryBackground.value,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: games.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                            color: themeService
                                                .secondaryBackground.value),
                                        child: Center(
                                          child: Text(
                                            activeText['PUBLIC_GAME_LIST'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: themeService
                                                    .secondaryAccent.value),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              final game = games[index - 1];
                              if (!game.onGoing && !game.private)
                                return GestureDetector(
                                  onTap: () {
                                    _joinRoom(game);
                                  },
                                  child: ActiveGameInfoWidget(
                                    quizTitle: _getQuizName(game.quizId),
                                    minRank: _minimumPrestige(game.prestige),
                                    allowedPlayers: game.friendsOnly
                                        ? activeText['FRIENDS_ONLY']
                                        : activeText['FRIENDS_AND_OTHERS'],
                                    playerNum: game.numberOfPlayers.toString(),
                                    gameMode: game.gameType == 'classic'
                                        ? activeText['CLASSIC']
                                        : activeText['TEAM'],
                                    price: game.price.toString(),
                                  ),
                                );
                              if (game.onGoing && !game.private)
                                return GestureDetector(
                                    onTap: () {
                                      // add method for observer
                                      observeGame(game, context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(_getQuizName(game.quizId),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: themeService
                                                            .mainAccent.value)),
                                                RichText(
                                                  text: TextSpan(children: [
                                                    TextSpan(
                                                        text: game.numberOfObs
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: themeService
                                                                .mainAccent
                                                                .value)),
                                                    WidgetSpan(
                                                        child: Icon(
                                                            Icons
                                                                .remove_red_eye_outlined,
                                                            color: themeService
                                                                .mainAccent
                                                                .value))
                                                  ]),
                                                ),
                                                Text(activeText['ONGOING_GAME'],
                                                    style: TextStyle(
                                                        color: themeService
                                                            .mainAccent.value))
                                              ]),
                                          Divider()
                                        ],
                                      ),
                                    ));
                            },
                          ),
                        ),
                        CancelBtn()
                      ],
                    ),
                    Positioned(child: ChatPopup(), bottom: 20.0, left: 20.0)
                  ]);
                }
              },
            );
          }
        },
      ),
    );
  }

  void observeGame(GameListItem game, BuildContext context) {
    this.gameService.isObserverMode = true;
    // this.gameService.init(game.room.toString(), true);
    this.gameService.realGameService.username = 'host';
    // ObservationService.instance.observeGame(game, context);
    ObservationService.instance.gameConfigs = game;
    this._globalNavigationService.navigateTo('/game');
    this._isJoining = false;
    // setTimeout(() => {this.router.navigate([`game/${game.room}`]);}, 500);
  }

  String _getQuizName(String id) {
    return quizNameMap[id] ?? 'Chargement...';
  }

  @override
  void dispose() {
    gameListService.cleanup();
    super.dispose();
  }
}
