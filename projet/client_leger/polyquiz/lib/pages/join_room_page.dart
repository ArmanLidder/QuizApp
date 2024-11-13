import 'package:flutter/material.dart';
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
    roomValidationService.roomId = game.room.toString();
    final isHostFriend = await _validateFriendship(game);
    if (game.friendsOnly && !isHostFriend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cette partie est exclusive aux amis de l'hôte.")),
      );
    } else {
      final isPrestigeValid = await _validatePrestige(game.prestige);
      if (!isPrestigeValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vous n'avez pas le prestige minimum pour rejoindre cette partie.")),
        );
      } else {
        await roomValidationService.verifyUsername();
        if (!roomValidationService.isUsernameValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Vous avez été banni de cette partie.")),
          );
        } else {
          if (roomValidationService.isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("La partie est actuellement verouillez.")),
            );
          }
          if (!roomValidationService.isLocked && roomValidationService.isUsernameValid) {
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
                    username:
                        this.userData!.uid, // Pass the username to the waiting room.
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
          SnackBar(content: Text('Room not found')),
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
        title: Text('Join a Room'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              TextFormField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Enter the Room ID',
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
                  ElevatedButton(
                    onPressed: _joinRoomField,
                    child: Text('Join Room'),
                  ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text("Retours a la page d'origine"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
