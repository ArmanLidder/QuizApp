import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_list_item.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/services/room_validation_service.dart';
import 'package:polyquiz/services/snack_bar_service.dart';
import 'package:polyquiz/services/waiting_room_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'package:polyquiz/models/user.dart';

class ActiveGameListComponent extends StatefulWidget {
  final Function(int) sendRoomData;
  final Function(String) sendUsernameData;
  final Function(bool) validationDone;

  ActiveGameListComponent({
    required this.sendRoomData,
    required this.sendUsernameData,
    required this.validationDone,
  });

  @override
  _ActiveGameListComponentState createState() => _ActiveGameListComponentState();
}

class _ActiveGameListComponentState extends State<ActiveGameListComponent> {
  late Future<void> _initializeFuture;
  Map<String, String> quizNameMap = {};
  WaitingRoomService waitingRoomService = WaitingRoomService();

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initialize();
  }

  Future<void> _initialize() async {
    final gameListService = Provider.of<GameListService>(context, listen: false);
    await gameListService.initialize();
    _prefetchQuizNames();
  }

  void _prefetchQuizNames() {
    final gameListService = Provider.of<GameListService>(context, listen: false);
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

  String _minimumPrestige(int prestige) {
    if (prestige >= 200) return '🏅'; // Platinum medal
    if (prestige >= 150) return '🥇'; // Gold medal
    if (prestige >= 100) return '🥈'; // Silver medal
    if (prestige >= 50) return '🥉';  // Bronze medal
    return '🚫';  // Default icon
  }

  Future<void> _joinRoom(GameListItem game) async {
    final roomValidationService = Provider.of<RoomValidationService>(context, listen: false);
    final snackbarService = Provider.of<SnackbarService>(context, listen: false);

    roomValidationService.roomId = game.room.toString();
    final isHostFriend = await _validateFriendship(game);
    if (game.friendsOnly && !isHostFriend) {
      snackbarService.show("Cette partie est exclusive aux amis de l'hôte.");
    } else {
      final isPrestigeValid = await _validatePrestige(game.prestige);
      if (!isPrestigeValid) {
        snackbarService.show("Vous n'avez pas le prestige minimum pour rejoindre cette partie.");
      } else {
        await roomValidationService.verifyUsername();
        if (!roomValidationService.isUsernameValid) {
          snackbarService.show("Vous avez été banni de cette partie.");
        } else {
          await waitingRoomService.connectToSocket(game.room.toString(), isHost: false, username: roomValidationService.userData!.username);
          if (roomValidationService.isLocked) {
            snackbarService.show("La partie est actuellement verouillez.");
          }
          final isValid = !roomValidationService.isLocked && roomValidationService.isUsernameValid;
          if (isValid) _sendAllDataToWaitingRoom();
        }
      }
    }
  }

  Future<bool> _validateFriendship(GameListItem game) async {
    final roomValidationService = Provider.of<RoomValidationService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    final currentUserId = (await roomValidationService.user$.first)?.uid;
    final hostProfile = await userService.getUserById(game.hostUserId);
    return hostProfile?.friends.contains(currentUserId) ?? false;
  }

  Future<bool> _validatePrestige(int prestige) async {
    final roomValidationService = Provider.of<RoomValidationService>(context, listen: false);

    final currentUserPrestige = (await roomValidationService.user$.first)?.prestige;
    return currentUserPrestige != null && currentUserPrestige >= prestige;
  }

  void _sendAllDataToWaitingRoom() {
    final roomValidationService = Provider.of<RoomValidationService>(context, listen: false);

    if (roomValidationService.roomId != null) {
      widget.sendRoomData(int.parse(roomValidationService.roomId!));
      widget.sendUsernameData(roomValidationService.username!);
    } else {
      print('Room ID is null from roomValidationService.roomId');
    }
    roomValidationService.isActive = false;
    widget.validationDone(roomValidationService.isActive);
  }

  @override
  Widget build(BuildContext context) {
    final gameListService = Provider.of<GameListService>(context);

    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return StreamBuilder<List<GameListItem>>(
            stream: gameListService.games$,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No active games.'));
              } else {
                final games = snapshot.data!;
                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return ListTile(
                      title: Text(_getQuizName(game.quizId)),
                      subtitle: Text('Prestige: ${_minimumPrestige(game.prestige)}'),
                      onTap: () => _joinRoom(game),
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  String _getQuizName(String id) {
    return quizNameMap[id] ?? 'Chargement...';
  }

  @override
  void dispose() {
    final gameListService = Provider.of<GameListService>(context, listen: false);
    gameListService.cleanup();
    super.dispose();
  }
}