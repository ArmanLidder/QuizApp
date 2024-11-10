import 'package:flutter/material.dart';
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
  final UserService userService = UserService();
  bool _isJoining = false;
  late final GameListService gameListService;

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
    roomValidationService.roomId = game.room.toString();
    final isHostFriend = await _validateFriendship(game);
    if (game.friendsOnly && !isHostFriend) {
      snackbarService.show("Cette partie est exclusive aux amis de l'hôte.");
    } else {
      final isPrestigeValid = await _validatePrestige(game.prestige);
      if (!isPrestigeValid) {
        snackbarService.show(
            "Vous n'avez pas le prestige minimum pour rejoindre cette partie.");
      } else {
        await roomValidationService.verifyUsername();
        if (!roomValidationService.isUsernameValid) {
          snackbarService.show("Vous avez été banni de cette partie.");
        } else {
          if (roomValidationService.isLocked) {
            snackbarService.show("La partie est actuellement verouillez.");
          }
          // _joinWaitingRoom(game.room.toString(), roomValidationService.userData!.username);
          final isValid = !roomValidationService.isLocked &&
              roomValidationService.isUsernameValid;
          if (true) {
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
        title: Text(
          'Liste des Jeux Publics',
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return StreamBuilder<List<GameListItem>>(
              stream: gameListService.games$,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Aucune partie en cours'),
                        SizedBox(height: 100),
                        CancelBtn()
                      ],
                    ),
                  );
                } else {
                  final games = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return GestureDetector(
                              onTap: () {
                                _joinRoom(game);
                              },
                              child: ActiveGameInfoWidget(
                                quizTitle: _getQuizName(game.quizId),
                                minRank: _minimumPrestige(game.prestige),
                                allowedPlayers: game.friendsOnly
                                    ? 'Amis seulement'
                                    : 'Amis et autres',
                                playerNum: game.numberOfPlayers.toString(),
                                gameMode: game.gameType == 'classic'
                                    ? 'Classique'
                                    : 'Équipe',
                                price: game.price.toString(),
                              ),
                            );
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

  String _getQuizName(String id) {
    return quizNameMap[id] ?? 'Chargement...';
  }

  @override
  void dispose() {
    gameListService.cleanup();
    super.dispose();
  }
}
