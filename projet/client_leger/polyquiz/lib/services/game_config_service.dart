import 'package:polyquiz/models/game_config.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:rxdart/rxdart.dart';

class GameConfigService {
  static final GameConfigService _instance = GameConfigService._internal();

  GameConfigService._internal();

  factory GameConfigService() {
    return _instance;
  }

  late BehaviorSubject<User?> user;
  String? hostId = "";
  String gameType = "";
  int price = 0;
  bool friendsOnly = false;
  bool private = false;

  void init(LoggedInUserService loggedInUserService) {
    this.user = loggedInUserService.user as BehaviorSubject<User?>;
    this.user.listen((User? user) {
      hostId = user?.uid;
    });
  }

  setGameType(String gameType) {
    this.gameType = gameType;
  }

  setPrice(int price) {
    this.price = price;
  }

  setFriendsOnly(bool isFriends) {
    this.friendsOnly = isFriends;
  }

  setPrivacy(bool isPrivate) {
    this.private = isPrivate;
  }

  getGameConfig() {
    return {
      this.hostId,
      this.gameType,
      this.private,
      false, // this will change to true when sent in server
      this.price,
      this.friendsOnly,
    } as GameConfig;
  }

  reset() {
    this.gameType = '';
    this.price = 0;
    this.friendsOnly = false;
  }
}
