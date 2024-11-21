import 'package:flutter/material.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/game_widgets/cancel_btn.dart';
import '../models/quiz.dart';
import 'waiting_room_screen.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/room_validation_service.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'package:polyquiz/services/game_list_item.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({Key? key}) : super(key: key);

  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _usernameController = TextEditingController();
  final _roomIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isJoining = false;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;
  final UserService userService = UserService();
  late final GameListService gameListService;
  Map<String, String> quizNameMap = {};
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map get text => TranslationService.instance.text;
  Map get waitPageText => text['PLAYER_WAITING_PAGE'];
  Map get roomPromptText => waitPageText['ROOM_CODE_PROMPT'];
  Map get roomErrorText => waitPageText['ROOM_CODE_PROMPT_ERRORS'];

  @override
  void initState() {
    super.initState();
    gameListService = Provider.of<GameListService>(context, listen: false);
    _initialize();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _roomIdController.dispose();
    super.dispose();
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

  Future<void> _joinRoom(GameListItem game) async {
    final roomValidationService =
        Provider.of<RoomValidationService>(context, listen: false);
    roomValidationService.reloadUserData();
    roomValidationService.roomId = game.room.toString();
    final isHostFriend = await _validateFriendship(game);
    dynamic dataOfRoomValidation = await roomValidationService.sendRoomId();
    if(!dataOfRoomValidation['isRoom']){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(roomErrorText['GAME_NOT_FOUND'])),
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
              content: Text(roomErrorText['ROOM_LOCKED'])),
        );
        setState(() {
          _isJoining = false;
        });
      }
        else{
          if (game.friendsOnly && !isHostFriend) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(roomErrorText['FRIENDS_ONLY'])),
            );
            setState(() {
              _isJoining = false;
            });
          } else {
            final isPrestigeValid = await _validatePrestige(game.prestige);
            if (!isPrestigeValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        roomErrorText['INSUFFICIENT_PRESTIGE'])),
              );
              setState(() {
                _isJoining = false;
              });
            } else {
              await roomValidationService.verifyUsername();
              if (!roomValidationService.isUsernameValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(roomErrorText['BANNED_USER'])),
                );
                setState(() {
                  _isJoining = false;
                });
              } else {
                if (roomValidationService.isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(roomErrorText['ROOM_LOCKED'])),
                  );
                  setState(() {
                    _isJoining = false;
                  });
                }
                else{
                  if(game.price > 0){
                    if(roomValidationService.userData!.currency < game.price){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(roomErrorText['INSUFFICIENT_FUNDS'])),
                      );
                      setState(() {
                        _isJoining = false;
                      });
                    }
                    else{
                      final availableMoney = roomValidationService.userData!.currency;
                      await _firestore.collection('users').doc(roomValidationService.userData!.uid).update({
                        'currency': availableMoney - game.price,
                      });
                      if (!roomValidationService.isLocked &&
                          roomValidationService.isUsernameValid) {
                        try {
                          // Navigate to the WaitingRoomScreen
                          Navigator.pushReplacement(
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
                                username: this
                                    .userData!
                                    .uid, // Pass the username to the waiting room.
                                isHost: false, // This user is not the host.
                                isFromActiveList: true,
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
                    }
                  }
                  else{
                  if (!roomValidationService.isLocked &&
                        roomValidationService.isUsernameValid) {
                      try {
                        // Navigate to the WaitingRoomScreen
                        Navigator.pushReplacement(
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
                              username: this
                                  .userData!
                                  .uid, // Pass the username to the waiting room.
                              isHost: false, // This user is not the host.
                              isFromActiveList: true,
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

  Future<void> _joinRoomField() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final roomId = _roomIdController.text.trim();
      this.userData = this.loggedInUserService.getUser();

      setState(() {
        _isJoining = true;
      });

      final game = await _getGame(roomId);
      print(roomId);

      if (game != null) {
        await _joinRoom(game);
      } else {
        setState(() {
          _isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(roomErrorText['GAME_NOT_FOUND'])),
        );
      }
    }
  }

  Future<GameListItem?> _getGame(String roomId) async {
    final games = await this.gameListService.games$.first;
    print(this.gameListService.games$);
    print(games);
    for (var game in games) {
      if (game.room == int.parse(roomId)) {
        return game;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.instance.languageValue.value == Language.fr ? 'Joindre une salle' : "Join a room"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/roomList');
              },
              child: Text(
                waitPageText['JOIN_PUBLIC_GAME'],
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      roomPromptText['ENTER_CODE_MESSAGE'],
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _roomIdController,
                    decoration: InputDecoration(
                      labelText: roomPromptText['ENTER_CODE_LABEL'],
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Room ID';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  _isJoining
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: _joinRoomField,
                                child: Text(roomPromptText['VALIDATE_BUTTON'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20)),
                                style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(53, 121, 246, 1))),
                            CancelBtn()
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
