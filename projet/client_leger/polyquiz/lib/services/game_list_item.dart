import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/game_list_item.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/models/user.dart';

class GameListService with ChangeNotifier {
  final SocketService socketService;
  final BehaviorSubject<List<GameListItem>> _gamesSubject =
      BehaviorSubject<List<GameListItem>>.seeded([]);
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;

  Stream<List<GameListItem>> get games$ => _gamesSubject.stream;

  GameListService({required this.socketService});

  Future<void> initialize() async {
    this.loggedInUserService.reloadUser();
    this.userData = this.loggedInUserService.getUser();
    if (!socketService.isSocketAlive()) {
      socketService.connect(this.userData?.uid);
    }
    _configureBaseSocket();
    fetchGameList();
  }

  void cleanup() {
    socketService.clearListener(SocketEvent.UPDATE_GAME_LIST);
  }

  void fetchGameList() {
    socketService.sendMessage(SocketEvent.GET_GAME_LIST);
  }

  void _configureBaseSocket() {
    socketService.onMessage(SocketEvent.UPDATE_GAME_LIST, (data) {
      final games =
          (data as List).map((item) => GameListItem.fromJson(item)).toList();
      _gamesSubject.add(games);
    });
  }
}
