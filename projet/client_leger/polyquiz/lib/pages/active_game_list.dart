import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/main.dart';
import 'package:polyquiz/pages/game_page.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/services/translationService.dart';
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
      games.where((game) => !game.private).forEach((game) {
        quizService.basicGetById(game.quizId).then((quiz) {
          setState(() {
            quizNameMap[game.quizId] = quiz?.title ?? 'Quiz Inconnu';
          });
        }).catchError((_) {
          setState(() {
            quizNameMap[game.quizId] = 'Quiz Inconnu';
          });
        });
      });
    });
  }

  Future<void> _joinWaitingRoom(String roomID, String username) async {
    setState(() {
      _isJoining = true;
    });

    try {
      // Navigate to the WaitingRoomScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingRoomScreen(
            quiz: Quiz(
              id: roomID, // Pass the room ID to the waiting room.
              title: 'Nothing', // Provide a sample title.
              description: 'Nothing', // Provide a sample description.
              duration: 0, // Provide a sample duration.
              questions: [], // Provide an empty list of questions.
            ),
            username: username, // Pass the username to the waiting room.
            isHost: false, // This user is not the host.
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isJoining = false;
      });

      // Display an error message if joining fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join room: $e')),
      );
    }
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
    if(!dataOfRoomValidation['isRoom']){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(activeText['NO_GAMES_AVAILABLE'])),
        );
      setState(() {
          _isJoining = false;
      });
    }
    else{
      if(dataOfRoomValidation['isLocked']){
        print('I am here 2');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(activeText['ROOM_LOCKED'])),
        );
        setState(() {
          _isJoining = false;
        });
      }
        else{
      if (game.friendsOnly && !isHostFriend) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(activeText['EXCLUSIVE_FRIENDS_GAME'])),
        );
      } else {
        final isPrestigeValid = await _validatePrestige(game.prestige);
        if (!isPrestigeValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    activeText['INSUFFICIENT_PRESTIGE'])),
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
            }
            else{
              if(game.price > 0){
                if(roomValidationService.userData!.currency < game.price){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(activeText['INSUFFICIENT_FUNDS'])),
                  );
                }
                else{
                  final availableMoney = roomValidationService.userData!.currency;
                  await _firestore.collection('users').doc(roomValidationService.userData!.uid).update({
                    'currency': availableMoney - game.price,
                  });
                  if (!roomValidationService.isLocked &&
                      roomValidationService.isUsernameValid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaitingRoomScreen(
                          quiz: Quiz(
                            id: roomValidationService
                                .roomId!, // Pass the room ID to the waiting room.
                            title: 'Nothing', // Provide a sample title.
                            description: 'Nothing', // Provide a sample description.
                            duration: 0, // Provide a sample duration.
                            questions: [], // Provide an empty list of questions.
                          ),
                          username: roomValidationService
                              .userData!.uid, // Pass the username to the waiting room.
                          isHost: false, // This user is not the host.
                          isFromActiveList: true,
                        ),
                      ),
                    );
                  }
                }
              }
              else{
                if (!roomValidationService.isLocked &&
                      roomValidationService.isUsernameValid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaitingRoomScreen(
                          quiz: Quiz(
                            id: roomValidationService
                                .roomId!, // Pass the room ID to the waiting room.
                            title: 'Nothing', // Provide a sample title.
                            description: 'Nothing', // Provide a sample description.
                            duration: 0, // Provide a sample duration.
                            questions: [], // Provide an empty list of questions.
                          ),
                          username: roomValidationService
                              .userData!.uid, // Pass the username to the waiting room.
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
    final currentUserId = roomValidationService.userData!.username;
    final hostProfile = await this.userService.getUserById(game.hostUserId);
    return hostProfile?.friends.contains(currentUserId) ?? false;
  }

  Future<bool> _validatePrestige(int prestige) async {
    final roomValidationService =
        Provider.of<RoomValidationService>(context, listen: false);

    final currentUserPrestige = roomValidationService.userData!.prestige;
    return currentUserPrestige >= prestige;
  }

  void _sendAllDataToWaitingRoom() {
    final roomValidationService =
        Provider.of<RoomValidationService>(context, listen: false);

    if (roomValidationService.roomId != null) {
      roomValidationService.isActive = false;
      try {
        // Navigate to the WaitingRoomScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingRoomScreen(
              quiz: Quiz(
                id: roomValidationService
                    .roomId!, // Pass the room ID to the waiting room.
                title: 'Nothing', // Provide a sample title.
                description: 'Nothing', // Provide a sample description.
                duration: 0, // Provide a sample duration.
                questions: [], // Provide an empty list of questions.
              ),
              username: roomValidationService
                  .username!, // Pass the username to the waiting room.
              isHost: false, // This user is not the host.
            ),
          ),
        );
      } catch (e) {
        print('Failed to join room: $e');
      }
    } else {
      print('Room ID is null from roomValidationService.roomId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameListService = Provider.of<GameListService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          activeText['PUBLIC_GAME_LIST'],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color.fromRGBO(255, 255, 255, 1)),
        ),
        backgroundColor: Color.fromRGBO(53, 121, 246, 1),
      ),
      body: FutureBuilder<void>(
        future: _initializeFuture,
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
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(53, 121, 246, 1),
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
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(53, 121, 246, 1),
                    ),
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
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(53, 121, 246, 1),
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
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(53, 121, 246, 1),
                          ),
                        ),
                      ),
                      Center(child: Text('Error: ${snapshot.error}')),
                    ],
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(53, 121, 246, 1),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(activeText['NO_GAMES_AVAILABLE']),
                            SizedBox(height: 100),
                            CancelBtn()
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  final games = snapshot.data!;
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
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(53, 121, 246, 1),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
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
                                    print('observer method');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(_getQuizName(game.quizId),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                              Text(activeText['ONGOING_GAME'])
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
                  );
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
