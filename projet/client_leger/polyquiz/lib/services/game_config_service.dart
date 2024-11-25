import 'package:flutter/material.dart';
import 'package:polyquiz/models/game_info_interface.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/models/user.dart';

class GameConfigService with ChangeNotifier {
  final UserService _userService = UserService();
  User? _currentUser;
  String? hostId;
  String gameType = '';
  int price = 0;
  bool friendsOnly = false;
  bool private = false;
  int prestige = 0;
  bool IA = false;

  GameConfigService([User? user]) {
    if (user != null) {
      _currentUser = user;
      hostId = user.uid;
    } else {
      hostId = 'null';
    }
  }

  void setUser(User user) {
    _currentUser = user;
    hostId = user.uid;
    notifyListeners();
  }

  void setGameType(String gameType) {
    this.gameType = gameType;
    notifyListeners();
  }

  void setPrice(int price) {
    this.price = price;
    notifyListeners();
  }

  void setPrestige(int prestige) {
    this.prestige = prestige;
    notifyListeners();
  }

  void setFriendsOnly(bool isFriends) {
    this.friendsOnly = isFriends;
    notifyListeners();
  }

  void setPrivacy(bool isPrivate) {
    this.private = isPrivate;
    notifyListeners();
  }

  void setIA(bool isAI){
    print('IA: $isAI');
    this.IA = isAI;
    notifyListeners();
  }

  GameConfig getGameConfig() {
    return GameConfig(
      hostUserId: hostId,
      gameType: gameType,
      private: private,
      onGoing: 'false', // this will change to 'true' when sent to server
      price: price,
      friendsOnly: friendsOnly,
      prestige: prestige,
      IA: IA,
    );
  }

  void reset() {
    gameType = '';
    price = 0;
    friendsOnly = false;
    private = false;
    notifyListeners();
  }
}
